import tensorflow as tf
import numpy as np
from skimage.io import imsave, imread, imshow
from skimage.transform import resize
import glob

img_rows = 224
img_cols = 224

mask_i_train = sorted(glob.glob('C:/Users/tomil/Downloads/train/depth_map/*.jpg', recursive=True))
left_i_train = sorted(glob.glob('C:/Users/tomil/Downloads/train/left/*.jpg', recursive=True))
right_i_train = sorted(glob.glob('C:/Users/tomil/Downloads/train/right/*.jpg', recursive=True))
# Std and mean load 
left_m = np.load('train_l_mean.npy')
left_std = np.load('train_l_std.npy')
right_m = np.load('train_r_mean.npy')
right_std = np.load('train_r_std.npy')


def representative_dataset_gen():
  for i in range(10):
    # Get sample input data as a numpy array in a method of your choosing.
    X_l = resize(imread(left_i_train[i], as_grey=False),(1,img_rows,img_cols,3))
    X_r = resize(imread(right_i_train[i], as_grey=False),(1,img_rows,img_cols,3))
    X_l = (X_l*255 - left_m)/left_std
    X_r = (X_r*255 - right_m)/right_std
    yield [X_l, X_r]

dataset = tf.data.Dataset().batch(1).from_generator(representative_dataset_gen,
                                           output_shapes=(tf.TensorShape([None, img_rows,img_cols,3])))
#train = tf.convert_to_tensor(np.array([X_l, X_r], dtype='float32'))
#my_ds = tf.data.Dataset.from_tensor_slices((train)).batch(1)

#POST TRAINING QUANTIZATION
#def representative_dataset_gen():
#    for input_value in range(10):
#        yield [input_value]

saved_model_dir = 'C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/my_model.h5'
#tflite_model_file = tflite_models_dir/"mnist_model.tflite"
converter = tf.lite.TFLiteConverter.from_keras_model_file(saved_model_dir) # from_keras_model_file
#converter.post_training_quantize = True
#converter.optimizations = [tf.lite.Optimize.DEFAULT]
#converter.representative_dataset = representative_dataset_gen
#converter.target_ops  = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
tflite_quantized_model = converter.convert()
open("converted_model.tflite", "wb").write(tflite_quantized_model)
print("convert model to tflite format has done.")


    

