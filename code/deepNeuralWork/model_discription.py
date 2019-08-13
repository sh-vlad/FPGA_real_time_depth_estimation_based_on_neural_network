import os
from skimage.transform import resize
from skimage.io import imsave
import numpy as np
import keras 
from keras.models import Model
from keras.layers import Input, concatenate, Conv2D, MaxPooling2D, Conv2DTranspose, BatchNormalization, Dropout
from keras.optimizers import Adam
from keras.callbacks import ModelCheckpoint
from keras import backend as K
from keras.utils import plot_model
from keras.optimizers import SGD
#from livelossplot import PlotLossesKeras

smooth = 1e-4
img_rows = 224
img_cols = 224

#--------------------------------------

total_epochs = 10000
learning_rate = 0.002
decay_rate = learning_rate/total_epochs*0



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
power = 5
conv1_left = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(inputs_left)
#conv1_left = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(conv1_left)
#conv1_left = Dropout(.25)(conv1_left)
#conv1_left = BatchNormalization()(conv1_left)
#pool1_left = MaxPooling2D(pool_size=(2, 2))(conv1_left)

# input for the right frames
inputs_right = Input((img_rows, img_cols, 3))
conv1_right = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(inputs_right)
#conv1_right = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(conv1_right)
#conv1_right = Dropout(.25)(conv1_right)
#conv1_right = BatchNormalization()(conv1_right)

conc_lr_1 = concatenate([conv1_left, conv1_right], axis=3)
#conc_lr_1 = Dropout(.25)(conc_lr_1)
#conc_lr_1 = BatchNormalization()(conc_lr_1)

conc_lr_2 = MaxPooling2D(pool_size=(2, 2))(conc_lr_1)
conc_lr_2 = Conv2D(2**(power+1), (3, 3), activation='relu', padding='same')(conc_lr_2)

conc_lr_3 = MaxPooling2D(pool_size=(2, 2))(conc_lr_2)
conc_lr_3 = Conv2D(2**(power+2), (3, 3), activation='relu', padding='same')(conc_lr_3)

conc_lr_4 = MaxPooling2D(pool_size=(2, 2))(conc_lr_3)
conc_lr_4 = Conv2D(2**(power+3), (3, 3), activation='relu', padding='same')(conc_lr_4)

conc_lr_5 = MaxPooling2D(pool_size=(2, 2))(conc_lr_4)
conc_lr_5 = Conv2D(2**(power+4), (3, 3), activation='relu', padding='same')(conc_lr_5)

conc_lr_6 = MaxPooling2D(pool_size=(2, 2))(conc_lr_5)
conc_lr_6 = Conv2D(2**(power+5), (3, 3), activation='relu', padding='same')(conc_lr_6)


conv_fin = Conv2D(2**(power + 6), (3, 3), activation='relu', padding='same')(conc_lr_6)
conv_fin = Conv2D(2**(power + 6), (3, 3), activation='relu', padding='same')(conv_fin)
pool_fin = MaxPooling2D(pool_size=(7, 7))(conc_lr_6)
#pool_fin = BatchNormalization()(pool_fin)

#### _________Upscale part of glasshour____________

up4 = concatenate([Conv2DTranspose(2**(power + 5), (2, 2), strides=(7, 7), padding='same')(pool_fin), conc_lr_6], axis=3)
up4 = Conv2D(2**(power + 5), (1, 1), activation='relu', padding='same')(up4)

up5 = concatenate([Conv2DTranspose(2**(power + 4), (2, 2), strides=(2, 2), padding='same')(up4), conc_lr_5], axis=3)
up5 = Conv2D(2**(power + 4), (1, 1), activation='relu', padding='same')(up5)

up6 = concatenate([Conv2DTranspose(2**(power + 3), (2, 2), strides=(2, 2), padding='same')(up5), conc_lr_4], axis=3)
up6 = Conv2D(2**(power + 3), (1, 1), activation='relu', padding='same')(up6)

up7 = concatenate([Conv2DTranspose(2**(power + 2), (2, 2), strides=(2, 2), padding='same')(up6), conc_lr_3], axis=3)
up7 = Conv2D(2**(power + 2), (1, 1), activation='relu', padding='same')(up7)

up8 = concatenate([Conv2DTranspose(2**(power + 1), (2, 2), strides=(2, 2), padding='same')(up7), conc_lr_2], axis=3)
up8 = Conv2D(2**(power + 1), (1, 1), activation='relu', padding='same')(up8)

up9 = concatenate([Conv2DTranspose(2**(power), (2, 2), strides=(2, 2), padding='same')(up8), conc_lr_1], axis=3)
up9 =  Conv2D(2**(power), (3, 3), activation='relu', padding='same')(up9)

conv11 = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(up9)

conv12 = Conv2D(2**(power-1), (3, 3), activation='relu', padding='same')(conv11)

conv13 = Conv2D(1, (1, 1), activation='sigmoid', padding='same')(up9)

model = Model(inputs=[inputs_left, inputs_right], outputs=[conv13])
opt = SGD(lr = 0.1, momentum=0.1, decay = 0.0, nesterov=True)#Adam(lr=0.005, decay= 0.0)
model.compile(optimizer=opt, loss='mean_squared_error', metrics=[dice_coef]) #Adam(lr=learning_rate)
#model.compile(loss='mean_squared_error',optimizer=Adam(lr=learning_rate, decay = decay_rate),metrics=['accuracy'])
plot_model(model, to_file='model.png', show_shapes=True)
model.summary()
#model.load_weights('C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/weightsDispar', by_name=True)

# left frames load and preprocess
imgs_train_l = np.load('imgs_train_l.npy')
imgs_train_l = preprocess(imgs_train_l)
imgs_train_l = imgs_train_l.astype('float32')
mean = np.mean(imgs_train_l)  # mean for data centering
std = np.std(imgs_train_l)  # std for data normalization
imgs_train_l -= mean
imgs_train_l /= std
# right frames load and preprocess
imgs_train_r = np.load('imgs_train_r.npy')
imgs_train_r = preprocess(imgs_train_r)
imgs_train_r = imgs_train_r.astype('float32')
mean = np.mean(imgs_train_r)  # mean for data centering
std = np.std(imgs_train_r)  # std for data normalization
imgs_train_r -= mean
imgs_train_r /= std

imgs_mask= np.load('imgs_test.npy')

#imgs_mask = preprocess(imgs_mask)
imgs_mask = imgs_mask[..., np.newaxis]

imgs_mask = imgs_mask.astype('float32')
imgs_mask /= np.max(imgs_mask)  # scale masks to [0, 1]
#imgs_mask = np.reshape(imgs_mask,(np.shape(imgs_mask)[0],np.shape(imgs_mask)[1],np.shape(imgs_mask)[2]))


print('-'*30)
print('Creating and compiling model...')
print('-'*30)
model_checkpoint = ModelCheckpoint('weightsDispar', monitor='val_loss', save_best_only=True) #'val_loss'

print('-'*30)
print('Fitting model...')
print('-'*30)

datagen = keras.preprocessing.image.ImageDataGenerator(
    featurewise_center=True,
    brightness_range=(0.3, 0.7),
    featurewise_std_normalization=True,
    rotation_range=5,
    width_shift_range=0.05,
    height_shift_range=0.05,
    horizontal_flip=False,
    validation_split=0.2)
# compute quantities required for featurewise normalization
# (std, mean, and principal components if ZCA whitening is applied)
datagen.fit(imgs_train_l)



#model.fit_generator(datagen.flow([imgs_train_l,imgs_train_r], imgs_mask, batch_size=4), epochs=total_epochs, verbose=1, shuffle=True,
#            callbacks=[model_checkpoint],steps_per_epoch=len(imgs_train_l)//4)

model.fit([imgs_train_l,imgs_train_r], imgs_mask, batch_size=8, epochs=total_epochs, verbose=1, shuffle=True,
            validation_split=0.2,
            callbacks=[model_checkpoint])
model.save_weights('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/weightsDispar')