import os
from skimage.transform import resize
from skimage.io import imsave
import numpy as np
import keras 
from keras.models import Model, model_from_json
from keras.layers import Input, concatenate, Conv2D, MaxPooling2D, Conv2DTranspose, BatchNormalization, Dropout, SeparableConv2D, UpSampling2D, Activation
from keras.optimizers import Adam
from keras.callbacks import ModelCheckpoint
from keras import backend as K
from keras.utils import plot_model
from keras.optimizers import SGD
from keras.layers import LeakyReLU, PReLU, ReLU
#from livelossplot import PlotLossesKeras
import glob
from skimage.io import imsave, imread, imshow
from skimage import exposure
import tensorflow as tf
smooth = 1e-4
img_rows = 224
img_cols = 224
do_coeff = 0.5
#--------------------------------------

total_epochs = 10000
learning_rate = 0.002
decay_rate = learning_rate/total_epochs*0
upconv = False
bn = True
l_rlu = False

class DataGenerator(keras.utils.Sequence):
    def __init__(self, mask_p, left_p, right_p, length = 66000, batch_size=16, is_noised = True, frac = 10, image_rows = 224, image_cols = 224):
        self.length = length
        self.batch_size = batch_size
        self.paths_m = mask_p
        self.paths_l = left_p
        self.paths_r = right_p
        self.on_epoch_end()
        self.is_noised = is_noised
        self.frac = frac
        self.image_rows = image_rows
        self.image_cols = image_cols
        self.left_m = np.load('train_l_mean.npy')
        self.left_std = np.load('train_l_std.npy')
        self.right_m = np.load('train_r_mean.npy')
        self.right_std = np.load('train_r_std.npy')
    def __len__(self):
        #return len(self.paths)
        'Denotes the number of batches per epoch'
        return int(np.floor(len(self.paths_m) / self.batch_size)/self.frac)

    def __getitem__(self, index):
        # Generate indexes of the batch
        indexes = self.indexes[index*self.batch_size:(index+1)*self.batch_size]
        
        X_l = np.empty((self.batch_size, img_rows, img_cols, 3))
        X_r = np.empty((self.batch_size, img_rows, img_cols, 3))
        y = np.empty((self.batch_size,  img_rows, img_cols, 1))
        for i in range(self.batch_size):
            X_l[i,]  = resize(imread(self.paths_l[indexes[i]], as_grey=False),(self.image_rows,self.image_cols,3))
            X_r[i,]  =resize(imread(self.paths_r[indexes[i]], as_grey=False),(self.image_rows,self.image_cols,3))

            rand_num_gamma = np.abs(np.random.randn()*2)
            rand_num_log = np.abs(np.random.randn())
            rn = np.abs(np.round(np.random.rand()*6))
            if rn == 0 and self.is_noised:
                X_l[i,] = self.add_noise(X_l[i,])
                X_r[i,] = self.add_noise(X_r[i,])
            if rn == 1 and self.is_noised:
                X_l[i,] = exposure.adjust_gamma(X_l[i,],gamma = rand_num_gamma)
                X_r[i,] = exposure.adjust_gamma(X_r[i,],gamma = rand_num_gamma)
            if rn == 2 and self.is_noised:
                X_l[i,] = exposure.adjust_log(X_l[i,], rand_num_log)
                X_r[i,] = exposure.adjust_log(X_r[i,], rand_num_log)
            if rn == 3 and self.is_noised:
                p2, p98 = np.percentile(X_l[i,], (2, 98))
                X_l[i,] = exposure.rescale_intensity(X_l[i,], in_range=(p2, p98))
                X_r[i,] = exposure.rescale_intensity(X_r[i,], in_range=(p2, p98))
            if rn == 4 and self.is_noised:
                X_l[i,] = exposure.exposure.equalize_hist(X_l[i,])
                X_r[i,] = exposure.exposure.equalize_hist(X_r[i,])
            if rn == 5 and self.is_noised:
                X_l[i,] = exposure.equalize_adapthist(X_l[i,], clip_limit=0.03) #clip_limit=0.03
                X_r[i,] = exposure.equalize_adapthist(X_r[i,], clip_limit=0.03)
            y[i,] = resize(imread(self.paths_m[indexes[i]], as_grey=True),(self.image_rows,self.image_cols, 1))

        #feature = self.feature_extractor(self.paths[index])[np.newaxis, ..., np.newaxis]
        X_l = (X_l*255 - self.left_m)/self.left_std
        X_r = (X_r*255 - self.right_m)/self.right_std
        #X_l = (X_l - np.amin(X_l))/(np.amax(X_l) - np.amin(X_l))
        #X_r = (X_r - np.amin(X_r))/(np.amax(X_r) - np.amin(X_r))

        #y = y/255
        #return feature, keras.utils.to_categorical([self.labels[index]], num_classes=2)
        return [X_l, X_r], y

    def on_epoch_end(self):
        'Updates indexes after each epoch'
        self.indexes = np.arange(len(self.paths_m))
        np.random.shuffle(self.indexes)


    def add_noise(self, data):
        mag_data = np.amax(data) - np.amin(data)
        noise_level = 0.2
        noise = np.random.randn(self.image_rows,self.image_cols, 3)
        data_noise = data + noise_level * mag_data * noise
        return data_noise






#--------------------------------------

def dice_coef(y_true, y_pred):
    y_true_f = K.flatten(y_true)
    y_pred_f = K.flatten(y_pred)
    intersection = K.sum(y_true_f * y_pred_f)
    return (2. * intersection + smooth*0) / (K.sum(y_true_f**2) + K.sum(y_pred_f**2) + smooth)


def dice_coef_loss(y_true, y_pred):
    return 1 - dice_coef(y_true, y_pred)




mobile_net_v2 = keras.applications.MobileNetV2(include_top=False, input_shape=(img_rows,img_cols,3), weights='imagenet',
    pooling='avg') # =[0.95,0.05]

def tricky_loss(y_true, y_pred):
    if y_pred.shape[1] == img_rows and y_true.shape[1] == img_rows:
        vec_true = K.flatten(K.concatenate([mobile_net_v2.predict(y_true), 
                                            mobile_net_v2.predict(y_true),
                                            mobile_net_v2.predict(y_true)],axis = -1)) 
        vec_pred = K.flatten(K.concatenate([mobile_net_v2.predict(y_pred), 
                                            mobile_net_v2.predict(y_pred),
                                            mobile_net_v2.predict(y_pred)],axis = -1)) 
    else: 
        vec_true = K.flatten(y_true)
        vec_pred = K.flatten(y_pred)

    return K.sum((vec_true - vec_pred)**2)**0.5 // 1024

def mse_mod(y_true, y_pred):
    y_true_f = K.flatten(y_true)
    y_pred_f = K.flatten(y_pred)
    return (K.sum((y_true_f - y_pred_f)**2))**0.5


def l1_loss(y_true, y_pred):
    y_true_f = K.flatten(y_true)
    y_pred_f = K.flatten(y_pred)
    return K.sum(K.abs(y_true_f - y_pred_f))

def preprocess(imgs):
    img_rows = imgs.shape[1]
    img_cols = imgs.shape[2]
    imgs_p = np.ndarray((imgs.shape[0], img_rows, img_cols,3), dtype=np.uint8)
    for i in range(imgs.shape[0]):
        imgs_p[i] = resize(imgs[i], (img_cols, img_rows,3), preserve_range=True)

    #imgs_p = imgs_p[..., np.newaxis]
    return imgs_p


print('-'*30)
print('Loading and preprocessing train data...')
print('-'*30)

# input for the left frames
inputs_left = Input((img_rows, img_cols, 3))
power = 3
conv1_left = SeparableConv2D(2**(power+2), (3, 3), padding='same')(inputs_left)
#conv1_left = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(conv1_left)
if bn:
    conv1_left = BatchNormalization()(conv1_left)
if l_rlu:    
    conv1_left = LeakyReLU()(conv1_left)
else:
    conv1_left = ReLU()(conv1_left)
#conv1_left = Dropout(do_coeff)(conv1_left)

#pool1_left = MaxPooling2D(pool_size=(2, 2))(conv1_left)

# input for the right frames
inputs_right = Input((img_rows, img_cols, 3))
conv1_right = SeparableConv2D(2**(power+2), (3, 3), padding='same')(inputs_right)
#conv1_right = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(conv1_right)
if bn:
    conv1_right = BatchNormalization()(conv1_right)
if l_rlu:    
    conv1_right = LeakyReLU()(conv1_right)
else:
    conv1_right = ReLU()(conv1_right)
#conv1_right = Dropout(do_coeff)(conv1_right)

conc_lr_1 = concatenate([conv1_left, conv1_right], axis=3)
#conc_lr_1 = Dropout(.25)(conc_lr_1)
#conc_lr_1 = BatchNormalization()(conc_lr_1)

conc_lr_2 = MaxPooling2D(pool_size=(2, 2))(conc_lr_1)
conc_lr_2 = SeparableConv2D(2**(power+1), (3, 3), padding='same')(conc_lr_2) #, activation='relu'
if bn:
    conc_lr_2 = BatchNormalization()(conc_lr_2)
if l_rlu:    
    conc_lr_2 = LeakyReLU()(conc_lr_2)
else:
    conc_lr_2 = ReLU()(conc_lr_2)
#conc_lr_2 = Dropout(do_coeff)(conc_lr_2)

conc_lr_3 = MaxPooling2D(pool_size=(2, 2))(conc_lr_2)
conc_lr_3 = SeparableConv2D(2**(power+2), (3, 3), padding='same')(conc_lr_3)
if bn:
    conc_lr_3 = BatchNormalization()(conc_lr_3)
if l_rlu:    
    conc_lr_3 = LeakyReLU()(conc_lr_3)
else:
    conc_lr_3 = ReLU()(conc_lr_3)
#conc_lr_3 = Dropout(do_coeff)(conc_lr_3)

conc_lr_4 = MaxPooling2D(pool_size=(2, 2))(conc_lr_3)
conc_lr_4 = SeparableConv2D(2**(power+3), (3, 3),  padding='same')(conc_lr_4)
if bn:
    conc_lr_4 = BatchNormalization()(conc_lr_4)
if l_rlu:    
    conc_lr_4 = LeakyReLU()(conc_lr_4)
else:
    conc_lr_4 = ReLU()(conc_lr_4)
#conc_lr_4 = Dropout(do_coeff)(conc_lr_4)

conc_lr_5 = MaxPooling2D(pool_size=(2, 2))(conc_lr_4)
conc_lr_5 = SeparableConv2D(2**(power+4), (3, 3), padding='same')(conc_lr_5)
if bn:
    conc_lr_5 = BatchNormalization()(conc_lr_5)
if l_rlu:    
    conc_lr_5 = LeakyReLU()(conc_lr_5)
else:
    conc_lr_5 = ReLU()(conc_lr_5)
#conc_lr_5 = Dropout(do_coeff)(conc_lr_5)

conc_lr_6 = MaxPooling2D(pool_size=(2, 2))(conc_lr_5)
conc_lr_6 = SeparableConv2D(2**(power+5), (3, 3), padding='same')(conc_lr_6)

if bn:
    conc_lr_6 = BatchNormalization()(conc_lr_6)
if l_rlu:    
    conc_lr_6 = LeakyReLU()(conc_lr_6)
else:
    conc_lr_6 = ReLU()(conc_lr_6)
#conc_lr_6 = Dropout(do_coeff)(conc_lr_6)


pool_fin = MaxPooling2D(pool_size=(7, 7))(conc_lr_6)
#pool_fin = BatchNormalization()(pool_fin)

#### _________Upscale part of glasshour____________
power = power-1
if upconv:
    up4 = concatenate([UpSampling2D(2**(power + 5), (2, 2), strides=(7, 7), padding='same')(pool_fin), conc_lr_6], axis=3)
else:
    up4 = concatenate([UpSampling2D(size=(7, 7))(pool_fin), conc_lr_6])

up4 = SeparableConv2D(2**(power + 5), (3, 3), padding='same')(up4)
if bn:
    up4 = BatchNormalization()(up4)
if l_rlu:    
    up4 = LeakyReLU()(up4)
else:
    up4 = ReLU()(up4)

if upconv:
    up5 = concatenate([Conv2DTranspose(2**(power + 4), (2, 2), strides=(2, 2), padding='same')(up4), conc_lr_5], axis=3)
else:
    up5 = concatenate([UpSampling2D(size=(2, 2))(up4), conc_lr_5])

up5 = SeparableConv2D(2**(power + 4), (3, 3), padding='same')(up5)
if bn:
    up5 = BatchNormalization()(up5)
if l_rlu:    
    up5 = LeakyReLU()(up5)
else:
    up5 = ReLU()(up5)

if upconv:
    up6 = concatenate([Conv2DTranspose(2**(power + 3), (2, 2), strides=(2, 2), padding='same')(up5), conc_lr_4], axis=3)
else:
    up6 = concatenate([UpSampling2D(size=(2, 2))(up5), conc_lr_4])

up6 = SeparableConv2D(2**(power + 3), (3, 3), padding='same')(up6)
if bn:
    up6 = BatchNormalization()(up6)
if l_rlu:    
    up6 = LeakyReLU()(up6)
else:
    up6 = ReLU()(up6)

if upconv:
    up7 = concatenate([Conv2DTranspose(2**(power + 2), (2, 2), strides=(2, 2), padding='same')(up6), conc_lr_3], axis=3)
else:
    up7 = concatenate([UpSampling2D(size=(2, 2))(up6), conc_lr_3])

up7 = SeparableConv2D(2**(power + 2), (3, 3),  padding='same')(up7)
if bn:
    up7 = BatchNormalization()(up7)
if l_rlu:    
    up7 = LeakyReLU()(up7)
else:
    up7 = ReLU()(up7)

if upconv:
    up8 = concatenate([Conv2DTranspose(2**(power + 1), (2, 2), strides=(2, 2), padding='same')(up7), conc_lr_2], axis=3)
else:
    up8 = concatenate([UpSampling2D(size=(2, 2))(up7), conc_lr_2])

up8 = SeparableConv2D(2**(power + 1), (3, 3), padding='same')(up8)
if bn:
    up8 = BatchNormalization()(up8)
if l_rlu:    
    up8 = LeakyReLU()(up8)
else:
    up8 = ReLU()(up8)

conc_lr_1 = SeparableConv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(conc_lr_1)

if upconv:
    up9 = concatenate([Conv2DTranspose(2**(power), (2, 2), strides=(2, 2), padding='same')(up8), conc_lr_1], axis=3)
else:
    up9 = concatenate([UpSampling2D(size=(2, 2))(up8), conc_lr_1])

up9 =  SeparableConv2D(2**(power), (3, 3), padding='same')(up9)
if bn:
    up9 = BatchNormalization()(up9)
if l_rlu:    
    up9 = LeakyReLU()(up9)
else:
    up9 = ReLU()(up9)

conv13 = SeparableConv2D(1, (3, 3), padding='same')(up9)
if bn:
    conv13 = BatchNormalization()(conv13)
if l_rlu:    
    conv13 = LeakyReLU()(conv13)
else:
    conv13 = ReLU()(conv13)

model = Model(inputs=[inputs_left, inputs_right], outputs=[conv13])

opt = SGD(lr = 0.02, momentum=0.5, decay = 0, nesterov=False)#Adam(lr=0.005, decay= 0.0)
model.compile(optimizer=opt, loss='mean_absolute_error', metrics=['accuracy']) #Adam(lr=learning_rate) dice_coef
#model.compile(loss='mean_squared_error',optimizer=Adam(lr=learning_rate, decay = decay_rate),metrics=['accuracy'])
plot_model(model, to_file='model.png', show_shapes=True)
model.summary()
model.load_weights('C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/weightsDispar', by_name=True)
model.save('my_model.h5')
#saved_model_path = tf.contrib.saved_model.save_keras_model(model, "./saved_models")

# serialize model to JSON
model_json = model.to_json()
with open("model.json", "w") as json_file:
    json_file.write(model_json)

# left frames load and preprocess
#imgs_train_l = np.load('imgs_train_l.npy')
#imgs_train_l = preprocess(imgs_train_l)
#imgs_train_l = imgs_train_l.astype('float32')
#mean = np.mean(imgs_train_l)  # mean for data centering
#std = np.std(imgs_train_l)  # std for data normalization
#imgs_train_l -= mean
#imgs_train_l /= std
# right frames load and preprocess
#imgs_train_r = np.load('imgs_train_r.npy')
#imgs_train_r = preprocess(imgs_train_r)
#imgs_train_r = imgs_train_r.astype('float32')
#mean = np.mean(imgs_train_r)  # mean for data centering
#std = np.std(imgs_train_r)  # std for data normalization
#imgs_train_r -= mean
#imgs_train_r /= std

#imgs_mask= np.load('imgs_test.npy')

#imgs_mask = preprocess(imgs_mask)
#imgs_mask = imgs_mask[..., np.newaxis]

#imgs_mask = imgs_mask.astype('float32')
#imgs_mask /= np.max(imgs_mask)  # scale masks to [0, 1]
#imgs_mask = np.reshape(imgs_mask,(np.shape(imgs_mask)[0],np.shape(imgs_mask)[1],np.shape(imgs_mask)[2]))


print('-'*30)
print('Creating and compiling model...')
print('-'*30)
model_checkpoint = ModelCheckpoint('weightsDispar', monitor='val_loss', save_best_only=True) #'val_loss'

print('-'*30)
print('Fitting model...')
print('-'*30)

##datagen = keras.preprocessing.image.ImageDataGenerator(
#    featurewise_center=True,
#    brightness_range=(0.3, 0.7),
#    featurewise_std_normalization=True,
#    rotation_range=5,
#    width_shift_range=0.05,
#    height_shift_range=0.05,
#    horizontal_flip=False,
#    validation_split=0.2)
# compute quantities required for featurewise normalization
# (std, mean, and principal components if ZCA whitening is applied)
#datagen.fit(imgs_train_l)

#result = model.predict([np.reshape(imgs_train_l[1,:,:,:],[1,224,224,3]), np.reshape(imgs_train_r[1,:,:,:],[1,224,224,3])])

#model.fit_generator(datagen.flow([imgs_train_l,imgs_train_r], imgs_mask, batch_size=4), epochs=total_epochs, verbose=1, shuffle=True,
#            callbacks=[model_checkpoint],steps_per_epoch=len(imgs_train_l)//4)
#mask_i_train = sorted(glob.glob('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/i_need_an_order/data24k/impr_result/*.jpg', recursive=True))
#left_i_train = sorted(glob.glob('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/i_need_an_order/data24k/original_l/*.jpg', recursive=True))
#right_i_train = sorted(glob.glob('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/i_need_an_order/data24k/original_r/*.jpg', recursive=True))


mask_i_train = sorted(glob.glob('C:/Users/tomil/Downloads/train/depth_map/*.jpg', recursive=True))
left_i_train = sorted(glob.glob('C:/Users/tomil/Downloads/train/left/*.jpg', recursive=True))
right_i_train = sorted(glob.glob('C:/Users/tomil/Downloads/train/right/*.jpg', recursive=True))

mask_i_valid = sorted(glob.glob('C:/Users/tomil/Downloads/verification/depth_map/*.jpg', recursive=True))
left_i_valid = sorted(glob.glob('C:/Users/tomil/Downloads/verification/left/*.jpg', recursive=True))
right_i_valid = sorted(glob.glob('C:/Users/tomil/Downloads/verification/right/*.jpg', recursive=True))

training_generator = DataGenerator(mask_i_train,left_i_train,right_i_train,  is_noised = False, frac = 1)
validation_generator = DataGenerator(mask_i_valid,left_i_valid,right_i_valid, is_noised = False, frac = 1)

model.fit_generator(generator=training_generator,
                validation_data=validation_generator,
                use_multiprocessing=False, epochs=total_epochs,
                workers=1, verbose=1,
                callbacks=[model_checkpoint])

#model.fit([imgs_train_l,imgs_train_r], imgs_mask, batch_size=8, epochs=total_epochs, verbose=1, shuffle=True,
#            validation_split=0.2,
#            callbacks=[model_checkpoint])
model.save_weights('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/weightsDispar')