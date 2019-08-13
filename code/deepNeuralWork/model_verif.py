from __future__ import print_function

import os
from skimage.transform import resize
from skimage.io import imsave
import numpy as np
from keras.models import Model
from keras.layers import Input, concatenate, Conv2D, MaxPooling2D, Conv2DTranspose, BatchNormalization, Dropout
from keras.optimizers import Adam
from keras.callbacks import ModelCheckpoint
from keras import backend as K



from skimage.io import imsave, imread
import matplotlib.pyplot as plt

def preprocess(imgs):
    img_rows = imgs.shape[1]
    img_cols = imgs.shape[2]
    imgs_p = np.ndarray((imgs.shape[0], img_rows, img_cols,3), dtype=np.uint8)
    for i in range(imgs.shape[0]):
        imgs_p[i] = resize(imgs[i], (img_cols, img_rows,3), preserve_range=True)

 #   imgs_p = imgs_p[..., np.newaxis]
    return imgs_p

smooth = 1.
img_rows = 224
img_cols = 224
#img_left = imread('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/only_for_test/left-right/19_l.jpg',
 #   as_gray=False)
#img_rows = np.shape(img_left)[0]    
#img_cols = np.shape(img_left)[1]   

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
up4 = Conv2D(2**(power + 5), (3, 3), activation='relu', padding='same')(up4)

up5 = concatenate([Conv2DTranspose(2**(power + 4), (2, 2), strides=(2, 2), padding='same')(up4), conc_lr_5], axis=3)
up5 = Conv2D(2**(power + 4), (3, 3), activation='relu', padding='same')(up5)

up6 = concatenate([Conv2DTranspose(2**(power + 3), (2, 2), strides=(2, 2), padding='same')(up5), conc_lr_4], axis=3)
up6 = Conv2D(2**(power + 3), (3, 3), activation='relu', padding='same')(up6)

up7 = concatenate([Conv2DTranspose(2**(power + 2), (2, 2), strides=(2, 2), padding='same')(up6), conc_lr_3], axis=3)
up7 = Conv2D(2**(power + 2), (3, 3), activation='relu', padding='same')(up7)

up8 = concatenate([Conv2DTranspose(2**(power + 1), (2, 2), strides=(2, 2), padding='same')(up7), conc_lr_2], axis=3)
up8 = Conv2D(2**(power + 1), (3, 3), activation='relu', padding='same')(up8)

up9 = concatenate([Conv2DTranspose(2**(power), (2, 2), strides=(2, 2), padding='same')(up8), conc_lr_1], axis=3)
up9 =  Conv2D(2**(power), (3, 3), activation='relu', padding='same')(up9)

conv11 = Conv2D(2**(power), (3, 3), activation='relu', padding='same')(up9)

conv12 = Conv2D(2**(power-1), (3, 3), activation='relu', padding='same')(conv11)

conv13 = Conv2D(1, (1, 1), activation='sigmoid', padding='same')(up9)

model = Model(inputs=[inputs_left, inputs_right], outputs=[conv13])


print('-'*30)
print('Loading saved weights...')
print('-'*30)
model.load_weights('C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/weightsDispar')

# Check the weights
for layer in model.layers:
    weights = layer.get_weights() # list of numpy arrays




# first read the test frame 

img_left = imread('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/only_for_test/left-right/left_frame549.jpg',
    as_gray=False)
img_left = img_left[(np.shape(img_left)[0] - img_rows)//2 : ((np.shape(img_left)[0] - img_rows)//2)+img_rows,
    (np.shape(img_left)[1] - img_cols)//2 : ((np.shape(img_left)[1] - img_cols)//2) + img_cols]
img_left = np.reshape(img_left,[1,img_rows,img_cols,3]) 
img_right = imread('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/only_for_test/left-right/right_frame549.jpg',
    as_gray=False)
img_right = img_right[(np.shape(img_right)[0] - img_rows)//2 : ((np.shape(img_right)[0] - img_rows)//2) + img_rows,
    (np.shape(img_right)[1] - img_cols)//2 : ((np.shape(img_right)[1] - img_cols)//2) + img_cols]    
img_right = np.reshape(img_right,[1,img_rows,img_cols,3]) 


num_frame = 1 #321


print('-'*30)
print('Predicting masks on test data...')
print('-'*30)
pred_dir = 'C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/result'

# left frames load and preprocess
imgs_train_l = np.load('imgs_train_l.npy')
imgs_train_l = preprocess(imgs_train_l)
imgs_train_l = imgs_train_l.astype('float32')
mean = np.mean(imgs_train_l)  # mean for data centering
std = np.std(imgs_train_l)  # std for data normalization
imgs_train_l -= mean
imgs_train_l /= std


#im_r = preprocess(img_right)
im_r = img_right
im_r = im_r.astype('float32')
mean = np.mean(im_r)  # mean for data centering
std = np.std(im_r)  # std for data normalization
im_r -= mean
im_r /= std
#im_l = preprocess(img_left)
im_l = img_left
im_l = im_l.astype('float32')
mean = np.mean(im_l)  # mean for data centering
std = np.std(im_l)  # std for data normalization
im_l -= mean
im_l /= std


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
#mean = np.mean(imgs_test)  # mean for data centering
#td = np.std(imgs_test)  # std for data normalization
#imgs_test -= mean
#imgs_test /= std
imgs_mask_test = model.predict([im_l, im_r], verbose=1)
#imgs_mask_test = model.predict([np.reshape(imgs_train_l[num_frame,:,:,:], [1,img_rows,img_cols,3]), 
#    np.reshape(imgs_train_r[num_frame,:,:,:], [1, img_rows,img_cols, 3])], verbose=1)
image = ((imgs_mask_test[0, :, :, 0] -np.amin(imgs_mask_test[0, :, :, 0]))/
    (np.amax(imgs_mask_test[0, :, :, 0]) - np.amin(imgs_mask_test[0, :, :, 0]))* 255.).astype(np.uint8)
image_id = 4
imsave(os.path.join(pred_dir, str(image_id) + '_pred.png'), image)
plt.figure()
plt.subplot(131)
#plt.imshow(np.reshape(imgs_train_l[num_frame,:,:,:],[img_rows,img_cols,3]))
plt.imshow(img_right[0])
plt.title('Left Frame')
plt.subplot(132)
#plt.imshow(np.reshape(imgs_train_r[num_frame,:,:,:],[img_rows,img_cols,3]))
plt.imshow(img_left[0])
plt.title('Right Frame')
#plt.subplot(143)
#plt.imshow(np.reshape(imgs_mask[num_frame,:,:,:],[img_rows,img_cols]))
#plt.title('Depth Map')
plt.subplot(133)
plt.imshow(np.reshape(image,[img_rows,img_cols]))
plt.title('Output of NN')
plt.show()