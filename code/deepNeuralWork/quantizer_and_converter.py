import tensorflow as tf
import numpy as np
from skimage.io import imsave, imread, imshow
from skimage.transform import resize
import glob
import sys
import os
if sys.version_info.major >= 3:
    import pathlib
else:
    import pathlib2 as pathlib
tf.enable_eager_execution() 
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
X_l = np.zeros((10,img_rows,img_cols,3))
X_r = np.zeros((10,img_rows,img_cols,3))

for i in range(10):
  # Get sample input data as a numpy array in a method of your choosing.
  X_l[i,] = resize(imread(left_i_train[i], as_grey=False),(1,img_rows,img_cols,3))
  X_r[i,] = resize(imread(right_i_train[i], as_grey=False),(1,img_rows,img_cols,3))
X_l = (X_l*255 - left_m)/left_std
X_r = (X_r*255 - right_m)/right_std

train = tf.convert_to_tensor(np.array(X_l, dtype='int64')) #np.swapaxes([X_l, X_r], 0,1)
my_ds = tf.data.Dataset.from_tensor_slices((train)).batch(1)
#iter = my_ds.make_initializable_iterator() # create the iterator
#iter = my_ds.make_one_shot_iterator()
#el = iter.get_next()
#POST TRAINING QUANTIZATION
#def representative_dataset_gen():
#    for input_value in my_ds.take(10):
 #     yield [input_value, input_value]
channels= 3
def _gen_input(channels):
    return tf.constant(np.random.uniform(0, 1, size=(1, img_rows, img_cols, channels)), dtype=tf.float32)

def representative_dataset_gen():
    for _ in range(100):
        yield [_gen_input(channels), _gen_input(channels)] #yield [sess.run(input value)]'

saved_model_dir = 'C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/my_model.h5'
#tflite_model_file = tflite_models_dir/"mnist_model.tflite"
converter = tf.lite.TFLiteConverter.from_keras_model_file(saved_model_dir) # from_keras_model_file
#converter.post_training_quantize = True
#converter.optimizations = [tf.lite.Optimize.DEFAULT]
#tflite_quantized_model = converter.convert()
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_dataset_gen
converter.target_ops  = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
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

"""
# Load TFLite model and allocate tensors.
interpreter = tf.lite.Interpreter(model_content=tflite_model)
interpreter.allocate_tensors()

# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Test the TensorFlow Lite model on random input data.
input_shape = input_details[0]['shape']
input_data = np.array(np.random.random_sample(input_shape), dtype=np.float32)
interpreter.set_tensor(input_details[0]['index'], input_data)

interpreter.invoke()

# The function `get_tensor()` returns a copy of the tensor data.
# Use `tensor()` in order to get a pointer to the tensor.
tflite_results = interpreter.get_tensor(output_details[0]['index'])

# Test the TensorFlow model on random input data.
tf_results = model(tf.constant(input_data))

# Compare the result.
for tf_result, tflite_result in zip(tf_results, tflite_results):
  np.testing.assert_almost_equal(tf_result, tflite_result, decimal=5)
  """
    

#interpreter = tf.lite.Interpreter(model_content=tflite_model)
#interpreter.allocate_tensors()

# Get input and output tensors.
#input_details = interpreter.get_input_details()
#output_details = interpreter.get_output_details()

#interpreter.set_tensor(input_details[0]['index'], _gen_input(channels))
#interpreter.invoke()
#tflite_results = interpreter.get_tensor(output_details[0]['index'])