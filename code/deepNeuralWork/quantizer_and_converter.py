import tensorflow as tf
from keras.models import Model,load_model 
import numpy as np


model = load_model('my_model.h5')
#for layer in model.layers: print(layer.get_config(), layer.get_weights())
fname = 'conf_and_weights.txt'
i = 0
for layer in model.layers: 
    i +=1
    if not np.reshape(layer.get_weights()[0],(np.size(layer.get_weights()[0]))):   
        b1= np.reshape(layer.get_weights()[0],(np.size(layer.get_weights()[0])))
        w1= np.reshape(layer.get_weights()[1],(np.size(layer.get_weights()[1])))

#np.savetxt(fname, np.reshape(layer.get_weights()[0],(np.size(layer.get_weights()[0]))))
print('Weights saved!')


saved_model_dir = 'C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/my_model.h5'
converter = tf.lite.TFLiteConverter.from_keras_model_file(saved_model_dir)
converter.post_training_quantize = True
tflite_quantized_model = converter.convert()
open("converted_model.tflite", "wb").write(tflite_quantized_model)
print("convert model to tflite format has done.")


    

