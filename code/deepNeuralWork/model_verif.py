from __future__ import print_function

import os
from skimage.transform import resize
from skimage.io import imsave
import numpy as np
from keras.models import Model,load_model 
from keras.layers import Input, concatenate, Conv2D, MaxPooling2D, Conv2DTranspose, BatchNormalization, Dropout, SeparableConv2D, UpSampling2D, Activation
from keras.optimizers import Adam
from keras.callbacks import ModelCheckpoint
from keras import backend as K
from skimage.transform import resize
from keras.layers import LeakyReLU, PReLU
import tensorflow as tf
from skimage.io import imsave, imread
import matplotlib.pyplot as plt

def dice_coef(y_true, y_pred):
    y_true_f = K.flatten(y_true)
    y_pred_f = K.flatten(y_pred)
    intersection = K.sum(y_true_f * y_pred_f)
    return (2. * intersection + smooth*0) / (K.sum(y_true_f**2) + K.sum(y_pred_f**2) + smooth)

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
do_coeff = 0.5
upconv = False

print('-'*30)
print('Loading saved model...')
print('-'*30)

model = load_model('my_model.h5')

print('-'*30)
print('Loading saved weights...')
print('-'*30)
model.load_weights('C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/weightsDispar')

# Check the weights
for layer in model.layers:
    weights = layer.get_weights() # list of numpy arrays

# first read the test frame 
img_left = imread('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/only_for_test/left-right/left_frame19862.jpg',
    as_gray=False)

img_right = imread('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/only_for_test/left-right/right_frame19862.jpg',
    as_gray=False)

img_left = resize(((img_left - np.amin(img_left))/(np.amax(img_left) - np.amin(img_left))*255).astype(np.uint8),(img_rows,img_cols,3))
img_right = resize(((img_right - np.amin(img_right))/(np.amax(img_right) - np.amin(img_right))*255).astype(np.uint8),(img_rows,img_cols,3))
img_right = np.reshape(img_right,[1,img_rows,img_cols,3]) 
img_left = np.reshape(img_left,[1,img_rows,img_cols,3]) 
num_frame = 1 #321


print('-'*30)
print('Predicting masks on test data...')
print('-'*30)
pred_dir = 'C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/result'
imgs_mask= np.load('imgs_test.npy')
imgs_mask = imgs_mask[..., np.newaxis]

imgs_mask = imgs_mask.astype('float32')
imgs_mask /= 255.  # scale masks to [0, 1]

imgs_mask_test = model.predict([img_left, img_right], verbose=1)

image = ((imgs_mask_test[0, :, :, 0] -np.amin(imgs_mask_test[0, :, :, 0]))/
    (np.amax(imgs_mask_test[0, :, :, 0]) - np.amin(imgs_mask_test[0, :, :, 0]))* 255.).astype(np.uint8)
image_id = 4

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