from __future__ import print_function
import glob
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
from keras.optimizers import SGD


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

img_left = resize(((img_left - np.amin(img_left))/(np.amax(img_left) - np.amin(img_left))),(img_rows,img_cols,3))*255
img_right = resize(((img_right - np.amin(img_right))/(np.amax(img_right) - np.amin(img_right))),(img_rows,img_cols,3))*255
img_right = np.reshape(img_right,[1,img_rows,img_cols,3]) 
img_left = np.reshape(img_left,[1,img_rows,img_cols,3]) 
num_frame = 1 #321

left_m = np.load('train_l_mean.npy')
left_std = np.load('train_l_std.npy')
right_m = np.load('train_r_mean.npy')
right_std = np.load('train_r_std.npy')

# Data for test

mask_i_test = sorted(glob.glob('C:/Users/tomil/Downloads/test/depth_map/*.jpg', recursive=True))
left_i_test = sorted(glob.glob('C:/Users/tomil/Downloads/test/left/*.jpg', recursive=True))
right_i_test = sorted(glob.glob('C:/Users/tomil/Downloads/test/right/*.jpg', recursive=True))
X_l = np.zeros((len(left_i_test),img_rows,img_cols,3))
X_r = np.zeros((len(right_i_test),img_rows,img_cols,3))
y = np.zeros((len(mask_i_test),img_rows,img_cols,1))
for i in range(len(mask_i_test)):
    X_l[i,]  = resize(imread(left_i_test[i], as_grey=False),(img_rows,img_cols,3))
    X_r[i,]  = resize(imread(right_i_test[i], as_grey=False),(img_rows,img_cols,3))
    y[i,] = resize(imread(mask_i_test[i], as_grey=True),(img_rows,img_cols, 1))
X_l = (X_l*255 - left_m)/left_std
X_r = (X_r*255 - right_m)/right_std

opt = SGD(lr = 0.01, momentum=0.9, decay = 1e-6, nesterov=True)#Adam(lr=0.005, decay= 0.0)
model.compile(optimizer=opt, loss='mean_absolute_error', metrics=[dice_coef]) #Adam(lr=learning_rate) dice_coef
score=model.evaluate([X_l, X_r],y)
print(score)

img_right = (img_right-right_m)/right_std
img_left = (img_left-left_m)/left_std

print('-'*30)
print('Predicting masks on test data...')
print('-'*30)


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