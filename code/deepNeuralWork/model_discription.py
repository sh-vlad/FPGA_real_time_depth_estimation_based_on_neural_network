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
#from livelossplot import PlotLossesKeras

smooth = 1e-4
img_rows = 224
img_cols = 224

#--------------------------------------

total_epochs = 1000
learning_rate = 0.002
decay_rate = learning_rate/total_epochs*0



#--------------------------------------

def dice_coef(y_true, y_pred):
    y_true_f = K.flatten(y_true)
    y_pred_f = K.flatten(y_pred)
    intersection = K.sum(y_true_f * y_pred_f)
    return (2. * intersection + smooth*0) / (K.sum(y_true_f**2) + K.sum(y_pred_f**2) + smooth)


def dice_coef_loss(y_true, y_pred):
    return -dice_coef(y_true, y_pred)

mobile_net_v2 = keras.applications.MobileNetV2(include_top=False, input_shape=(img_rows,img_cols,3), weights='imagenet',
    pooling='avg') # =[0.95,0.05]

def tricky_loss(y_true, y_pred):

    vec_true = mobile_net_v2.predict(y_true) 
    vec_pred = mobile_net_v2.predict(y_pred) 
    return K.sum((vec_true - vec_pred)**2)**0.5 // 1024


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
power = 4
conv1_left = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(inputs_left)
conv1_left = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(conv1_left)
conv1_left = Dropout(.25)(conv1_left)
conv1_left = BatchNormalization()(conv1_left)
#pool1_left = MaxPooling2D(pool_size=(2, 2))(conv1_left)

# input for the right frames
inputs_right = Input((img_rows, img_cols, 3))
conv1_right = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(inputs_right)
conv1_right = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(conv1_right)
conv1_right = Dropout(.25)(conv1_right)
conv1_right = BatchNormalization()(conv1_right)

#pool1_right = MaxPooling2D(pool_size=(2, 2))(conv1_right)
# combine both preprocessed data
#conc_lr = concatenate([pool1_left, pool1_right], axis=3)
conc_lr_1 = concatenate([conv1_left, conv1_right], axis=3)
conc_lr_1 = Dropout(.25)(conc_lr_1)
conc_lr_1 = BatchNormalization()(conc_lr_1)

#conv2 = Conv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(conc_lr)
#conv2 = Conv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(conv2)
#pool2 = MaxPooling2D(pool_size=(2, 2))(conv2)
conv2_l = Conv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(conv1_left)
conv2_l = Conv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(conv2_l)
conv2_l = Dropout(.25)(conv2_l)
conv2_l = BatchNormalization()(conv2_l)
#conv2_l = Conv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(conv2_l)
pool2_l = MaxPooling2D(pool_size=(2, 2))(conv2_l)

conv2_r = Conv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(conv1_right)
conv2_r = BatchNormalization()(conv2_r)
conv2_r = Dropout(.25)(conv2_r)
#conv2_r = Conv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(conv2_r)
pool2_r = MaxPooling2D(pool_size=(2, 2))(conv2_r)


conc_lr_2 = concatenate([pool2_l, pool2_r], axis=3)
#conc_lr_2 = BatchNormalization()(conc_lr_2)


#conv3 = Conv2D(2**(power + 2), (3, 3), activation='relu', padding='same')(pool2)
#conv3 = Conv2D(2**(power + 2), (3, 3), activation='relu', padding='same')(conv3)
#pool3 = MaxPooling2D(pool_size=(2, 2))(conv3)
conv3_l = Conv2D(2**(power + 2), (3, 3), activation='relu', padding='same')(pool2_l)
conv3_l = Dropout(.25)(conv3_l)
conv3_l = BatchNormalization()(conv3_l)

#conv3_l = Conv2D(2**(power + 2), (3, 3), activation='relu', padding='same')(conv3_l)
pool3_l = MaxPooling2D(pool_size=(2, 2))(conv3_l)

conv3_r = Conv2D(2**(power + 2), (3, 3), activation='relu', padding='same')(pool2_r)
conv3_r = Dropout(.25)(conv3_r)
conv3_r = BatchNormalization()(conv3_r)

#conv3_r = Conv2D(2**(power + 2), (3, 3), activation='relu', padding='same')(conv3_r)
pool3_r = MaxPooling2D(pool_size=(2, 2))(conv3_r)


conc_lr_3 = concatenate([pool3_l, pool3_r], axis=3)
#conc_lr_3 = BatchNormalization()(conc_lr_3)


#conv4 = Conv2D(2**(power + 3), (3, 3), activation='relu', padding='same')(pool3)
#conv4 = Conv2D(2**(power + 3), (3, 3), activation='relu', padding='same')(conv4)
#pool4 = MaxPooling2D(pool_size=(2, 2))(conv4)

conv4_l = Conv2D(2**(power + 3), (3, 3), activation='relu', padding='same')(pool3_l)
#conv4_l = Conv2D(2**(power + 3), (3, 3), activation='relu', padding='same')(conv4_l)
pool4_l = MaxPooling2D(pool_size=(2, 2))(conv4_l)
pool4_l = BatchNormalization()(pool4_l)
conv4_r = Conv2D(2**(power + 3), (3, 3), activation='relu', padding='same')(pool3_r)
#conv4_r = Conv2D(2**(power + 3), (3, 3), activation='relu', padding='same')(conv4_r)
pool4_r = MaxPooling2D(pool_size=(2, 2))(conv4_r)
pool4_r = BatchNormalization()(pool4_r)

conc_lr_4 = concatenate([pool4_l, pool4_r], axis=3)
#conc_lr_4 = BatchNormalization()(conc_lr_4)

conv5 = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(conc_lr_4)
conv5 = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(conv5)


conv5_l = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(pool4_l)
#conv5_l = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(conv5_l)
pool5_l = MaxPooling2D(pool_size=(2, 2))(conv5_l)
pool5_l = BatchNormalization()(pool5_l)
conv5_r = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(pool4_r)
#conv5_r = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(conv5_r)
pool5_r = MaxPooling2D(pool_size=(2, 2))(conv5_r)
pool5_r = BatchNormalization()(pool5_r)

conc_lr_5 = concatenate([pool5_l, pool5_r], axis=3)

conv6 = Conv2D(2**(power + 5), (3, 3), activation='relu', padding='same')(conc_lr_5)
conv6 = Conv2D(2**(power + 5), (3, 3), activation='relu', padding='same')(conv6)

conv6_l = Conv2D(2**(power + 5), (3, 3), activation='relu', padding='same')(pool5_l)
#conv6_l = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(conv6_l)
pool6_l = MaxPooling2D(pool_size=(2, 2))(conv6_l)
pool6_l = BatchNormalization()(pool6_l)
conv6_r = Conv2D(2**(power + 5), (3, 3), activation='relu', padding='same')(pool5_r)
#conv6_r = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(conv6_r)
pool6_r = MaxPooling2D(pool_size=(2, 2))(conv6_r)
pool6_r = BatchNormalization()(pool6_r)

conc_lr_6 = concatenate([pool6_l, pool6_r], axis=-1)


conv_fin = Conv2D(2**(power + 6), (3, 3), activation='relu', padding='same')(conc_lr_6)
conv_fin = Conv2D(2**(power + 6), (3, 3), activation='relu', padding='same')(conv_fin)
pool_fin = MaxPooling2D(pool_size=(7, 7))(conv_fin)
pool_fin = BatchNormalization()(pool_fin)

#### _________Upscale part of glasshour____________

up4 = concatenate([Conv2DTranspose(2**(power + 6), (2, 2), strides=(7, 7), padding='same')(pool_fin), conc_lr_6], axis=3)
up4 = Conv2D(2**(power + 6), (3, 3), activation='relu', padding='same')(up4)

up5 = concatenate([Conv2DTranspose(2**(power + 5), (2, 2), strides=(2, 2), padding='same')(up4), conc_lr_5], axis=3)
up5 = Conv2D(2**(power + 5), (3, 3), activation='relu', padding='same')(up5)

up6 = concatenate([Conv2DTranspose(2**(power + 4), (2, 2), strides=(2, 2), padding='same')(up5), conc_lr_4], axis=3)
up6 = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(up6)

up7 = concatenate([Conv2DTranspose(2**(power + 3), (2, 2), strides=(2, 2), padding='same')(up6), conc_lr_3], axis=3)
up7 = Conv2D(2**(power + 3), (3, 3), activation='relu', padding='same')(up7)

up8 = concatenate([Conv2DTranspose(2**(power + 2), (2, 2), strides=(2, 2), padding='same')(up7), conc_lr_2], axis=3)
up8 = Conv2D(2**(power + 2), (3, 3), activation='relu', padding='same')(up8)

up9 = concatenate([Conv2DTranspose(2**(power + 1), (2, 2), strides=(2, 2), padding='same')(up8), conc_lr_1], axis=3)
up9 =  Conv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(up9)

conv11 = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(up9)

conv12 = Conv2D(2**(power-1), (3, 3), activation='relu', padding='same')(conv11)

conv13 = Conv2D(1, (1, 1), activation='sigmoid', padding='same')(up9)

model = Model(inputs=[inputs_left, inputs_right], outputs=[conv13])

model.compile(optimizer=Adam(lr=learning_rate), loss=[dice_coef_loss], metrics=[dice_coef])
#model.compile(loss='mean_squared_error',optimizer=Adam(lr=learning_rate, decay = decay_rate),metrics=['accuracy'])
plot_model(model, to_file='model.png', show_shapes=True)
model.summary()
#model.load_weights('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/weights', by_name=True)

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
imgs_mask /= 255.  # scale masks to [0, 1]



print('-'*30)
print('Creating and compiling model...')
print('-'*30)
model_checkpoint = ModelCheckpoint('weightsDispar', monitor='val_loss', save_best_only=False) #'val_loss'

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

model.fit_generator(datagen.flow([imgs_train_l,imgs_train_r], imgs_mask, batch_size=4), epochs=total_epochs, verbose=1, shuffle=True,
            callbacks=[model_checkpoint],steps_per_epoch=len(imgs_train_l)//4)

#model.fit([imgs_train_l,imgs_train_r], imgs_mask, batch_size=4, epochs=total_epochs, verbose=1, shuffle=True,
#            validation_split=0.2,
#            callbacks=[model_checkpoint])
model.save_weights('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/weightsDispar')