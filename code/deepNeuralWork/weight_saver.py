import tensorflow as tf
from keras.models import Model,load_model 
import numpy as np

model = load_model('my_model.h5')
#for layer in model.layers: print(layer.get_config(), layer.get_weights())
w_path = 'C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/weights/'
b_path = 'C:/Users/tomil/Documents/FPGA_real_time_depth_estimation_based_on_neural_network/code/deepNeuralWork/biases/'
fname_w = 'weights.txt'
fname_b = 'biases.txt'
#i = 0
#sz_1 = 0
#sz_2 = 0
#for layer in model.layers: 
#    i +=1
#    if (not layer.get_weights()) == False:   
#        if sz_1 < np.size(layer.get_weights()[0]):
#                sz_1 = np.size(layer.get_weights()[0])
#        if sz_2 < np.size(layer.get_weights()[1]):
#                sz_2 = np.size(layer.get_weights()[1])

#b1 = np.zeros((np.size(model.layers),sz_1 + 1))
#w1 = np.zeros((np.size(model.layers),sz_2 + 1))

i = 0
for layer in model.layers: 
    if (not layer.get_weights()) == False:   
#        b1[i,0] = np.size(layer.get_weights()[0])
#        w1[i,0]= np.size(layer.get_weights()[1])
        if len(layer.weights) == 3:
            b1 = np.reshape(layer.get_weights()[2],(np.size(layer.get_weights()[2])))
            w1_dw = np.reshape(layer.get_weights()[0],(np.size(layer.get_weights()[0])))
            w1_pw = np.reshape(layer.get_weights()[1],(np.size(layer.get_weights()[1])))
            np.savetxt(w_path+layer.weights[0].name.replace('/','_').replace(':','_')+'.txt', w1_dw)
            np.savetxt(w_path+layer.weights[1].name.replace('/','_').replace(':','_')+'.txt', w1_pw)
            np.savetxt(w_path+layer.weights[2].name.replace('/','_').replace(':','_')+'.txt', b1)
        elif len(layer.weights) == 2:
            w1_dw = np.reshape(layer.get_weights()[0],(np.size(layer.get_weights()[0])))
            w1_pw = np.reshape(layer.get_weights()[1],(np.size(layer.get_weights()[1])))
            np.savetxt(w_path+layer.weights[0].name.replace('/','_').replace(':','_')+'.txt', w1_dw)
            np.savetxt(w_path+layer.weights[1].name.replace('/','_').replace(':','_')+'.txt', w1_pw)
        elif len(layer.weights) == 4:
            b2 = np.reshape(layer.get_weights()[3],(np.size(layer.get_weights()[3])))
            b1 = np.reshape(layer.get_weights()[2],(np.size(layer.get_weights()[2])))
            w1_dw = np.reshape(layer.get_weights()[0],(np.size(layer.get_weights()[0])))
            w1_pw = np.reshape(layer.get_weights()[1],(np.size(layer.get_weights()[1])))
            np.savetxt(w_path+layer.weights[0].name.replace('/','_').replace(':','_')+'.txt', w1_dw)
            np.savetxt(w_path+layer.weights[1].name.replace('/','_').replace(':','_')+'.txt', w1_pw)
            np.savetxt(w_path+layer.weights[2].name.replace('/','_').replace(':','_')+'.txt', b1)
            np.savetxt(w_path+layer.weights[3].name.replace('/','_').replace(':','_')+'.txt', b2)




print('Weights saved!')