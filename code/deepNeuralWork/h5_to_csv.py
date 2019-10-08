import pandas as pd

with pd.HDFStore('my_model.h5', 'r') as d:
    df = d.get('TheData')
    df.to_csv('myfile.csv')
print('Conversation has done!')
