import tensorflow as tf
import numpy as np
from skimage.io import imsave, imread, imshow
from skimage.transform import resize
import glob
import sys
import os
from keras.models import Model,load_model 
if sys.version_info.major >= 3:
    import pathlib
else:
    import pathlib2 as pathlib
import matplotlib.pyplot as plt
tf.enable_eager_execution() 
img_rows = 224
img_cols = 224

full_quant = False
isrand = False
not_rand_dataset = False

mask_i_train = sorted(glob.glob('C:/Users/tomil/Downloads/train/depth_map/*.jpg', recursive=True))
left_i_train = sorted(glob.glob('C:/Users/tomil/Downloads/train/left/*.jpg', recursive=True))
right_i_train = sorted(glob.glob('C:/Users/tomil/Downloads/train/right/*.jpg', recursive=True))
# Std and mean load 
left_m = np.load('train_l_mean.npy')
left_std = np.load('train_l_std.npy')
right_m = np.load('train_r_mean.npy')
right_std = np.load('train_r_std.npy')
num_sample = 100
if not_rand_dataset: 
  X_l = np.zeros((num_sample,img_rows,img_cols,3))
  X_r = np.zeros((num_sample,img_rows,img_cols,3))

  for i in range(num_sample):
    # Get sample input data as a numpy array in a method of your choosing.
    X_l[i,] = resize(imread(left_i_train[i], as_grey=False),(1,img_rows,img_cols,3))
    X_r[i,] = resize(imread(right_i_train[i], as_grey=False),(1,img_rows,img_cols,3))
  X_l = (X_l*255 - left_m)/left_std
  X_r = (X_r*255 - right_m)/right_std

  train_l = tf.convert_to_tensor(np.array(X_l, dtype='float32')) #np.swapaxes([X_l, X_r], 0,1)
  my_ds_l = tf.data.Dataset.from_tensor_slices((train_l)).batch(1)
  #iter = my_ds.make_initializable_iterator() # create the iterator
  iter_l = my_ds_l.make_one_shot_iterator()
  el_l = iter_l.get_next()

  train_r = tf.convert_to_tensor(np.array(X_r, dtype='float32')) #np.swapaxes([X_l, X_r], 0,1)
  my_ds_r = tf.data.Dataset.from_tensor_slices((train_r)).batch(1)
  #iter = my_ds.make_initializable_iterator() # create the iterator
  iter_r = my_ds_r.make_one_shot_iterator()
  el_r = iter_r.get_next()

  #POST TRAINING QUANTIZATION
  #def representative_dataset_gen():
  #    for input_value in my_ds.take(num_sample):
  #     yield [input_value, input_value]
  def _gen_input():
      return [tf.constant(el_l, dtype=tf.float32), tf.constant(el_r, dtype=tf.float32)]

  def representative_dataset_gen():
    for _ in range(num_sample):
        #yield [_gen_input(), _gen_input()] #yield [sess.run(input value)]'
        yield _gen_input() #yield [sess.run(input value)]'
else:

  def _gen_input():
      #return tf.constant(np.random.uniform(0, 1, size=(1, img_rows, img_cols, 3)), dtype=tf.float32)
      return tf.constant(np.random.uniform(0, 1, size=(1, img_rows, img_cols, 3)), dtype=tf.float32)

  def representative_dataset_gen():
      for _ in range(num_sample):
          yield [_gen_input(), _gen_input()] #yield [sess.run(input value)]'


saved_model_dir = 'C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/my_model.h5'
#tflite_model_file = tflite_models_dir/"mnist_model.tflite"
converter = tf.lite.TFLiteConverter.from_keras_model_file(saved_model_dir) # from_keras_model_file


if full_quant:
  converter.optimizations = [tf.lite.Optimize.OPTIMIZE_FOR_SIZE]
else:
  #converter.post_training_quantize = True
  converter.optimizations = [tf.lite.Optimize.DEFAULT]
  converter.representative_dataset = representative_dataset_gen
  #converter.target_ops  = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
  #converter.inference_type = tf.contrib.lite.constants.QUANTIZED_UINT8
  
tflite_quantized_model = converter.convert()
print("Convert model to tflite format has done!")
# Save the tflite model
tflite_models_dir_0 = 'C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/'
tflite_models_dir = pathlib.Path("tflite_models_dir_0")
tflite_models_dir.mkdir(exist_ok=True, parents=True)
tflite_model_file = tflite_models_dir/"depth_map_quantized.tflite"
tflite_model_file.write_bytes(tflite_quantized_model)
#open("converted_model.tflite", "wb").write(tflite_quant_model)
print("Saving tflite model has done!")


# Load TFLite model and allocate tensors.
interpreter = tf.lite.Interpreter(model_content=tflite_quantized_model)
interpreter.allocate_tensors()

# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Test the TensorFlow Lite model on random input data.
input_shape = input_details[0]['shape']
if isrand:
  input_data_l = np.array(np.random.random_sample(input_shape), dtype=np.float32)
  input_data_r = np.array(np.random.random_sample(input_shape), dtype=np.float32)
else:
  img_left = imread('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/only_for_test/left-right/left_frame9743.jpg',
      as_gray=False)

  img_right = imread('C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/only_for_test/left-right/right_frame9743.jpg',
      as_gray=False)

  img_left = resize(((img_left - np.amin(img_left))/(np.amax(img_left) - np.amin(img_left))),(img_rows,img_cols,3))*255
  img_right = resize(((img_right - np.amin(img_right))/(np.amax(img_right) - np.amin(img_right))),(img_rows,img_cols,3))*255
  img_right = np.reshape(img_right,[1,img_rows,img_cols,3]) 
  img_left = np.reshape(img_left,[1,img_rows,img_cols,3]) 
  img_right = (img_right-right_m)/right_std
  img_left = (img_left-left_m)/left_std
  input_data_l = np.array(img_left, dtype=np.float32)
  input_data_r = np.array(img_right, dtype=np.float32)
  #interpreter.set_tensor(input_details[0]['index'], input_data_l)
 # interpreter.set_tensor(input_details[1]['index'], input_data_r)

interpreter.set_tensor(input_details[0]['index'], input_data_l)
interpreter.set_tensor(input_details[1]['index'], input_data_r)

interpreter.invoke()

# The function `get_tensor()` returns a copy of the tensor data.
# Use `tensor()` in order to get a pointer to the tensor.
tflite_results = interpreter.get_tensor(output_details[0]['index'])
plt.imshow(tflite_results[0,:,:,0])
plt.show()
#print('-'*30)
#print('Loading saved model...')
#print('-'*30)

#model = load_model('my_model.h5')


# Test the TensorFlow model on random input data.
#tf_results = model([tf.constant(input_data), tf.constant(input_data)])

# Compare the result.


    

#interpreter = tf.lite.Interpreter(model_content=tflite_model)
#interpreter.allocate_tensors()

# Get input and output tensors.
#input_details = interpreter.get_input_details()
#output_details = interpreter.get_output_details()

#interpreter.set_tensor(input_details[0]['index'], _gen_input(channels))
#interpreter.invoke()
#tflite_results = interpreter.get_tensor(output_details[0]['index'])