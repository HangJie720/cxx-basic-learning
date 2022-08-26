graph = [['0', '1', 'X', 'X', '0.1'], ['1', '1', 'J', '<eps>', '0.1'],['0', '0', 'X', 'X', '1'],['0', '0', 'oov', 'oov', '1']]

def search(start_state,word):
    need_path = [path for path in graph if path[0]==start_state]  
    for path in need_path:
        if path[2]==word:
            print(path[1],word)
            return path[1]

    start_state = '0'
    weight = 0.0
    a = search(start_state,word)
    return a

all_dict = 'XJ'
input_sen = 'XJA'
start_state = '0'
for word in input_sen:
    if word not in all_dict:
        word = 'oov'
    start_state = search(start_state,word)
    print('output:',start_state)
