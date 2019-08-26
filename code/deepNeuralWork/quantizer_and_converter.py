import tensorflow as tf
saved_model_dir = 'C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/my_model.h5'
converter = tf.lite.TFLiteConverter.from_keras_model_file(saved_model_dir)
converter.post_training_quantize = True
tflite_quantized_model = converter.convert()
open("converted_model.tflite", "wb").write(tflite_quantized_model)
print("convert model to tflite format done.")

