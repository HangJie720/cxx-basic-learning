# Guide
## Quickly Start
### inference
- run on bi:
```
import debug
model = Net(**config)
debug.builder(model, arch="bi", hook_type="inference", if_compare=False, name="model_name", skip=skip_num)
...
debug.run()
```
Then bi_debug.npy will exisit in current directory and copy it to nv environment.
- run on nv
```
import debug
model = Net(**config)
debug.builder(model, arch="nv", hook_type="inference", if_compare=True, name="model_name", skip=skip_num)
...
debug.run()
```
Then debug.csv will exisit in current directory.
- notice
```
skip_num means script only save data by step. For example, if skip=2 script will only save 0,2,4,6...'s output.
```
#### backward
change "inference" to "backward"
#### loss graph
change "inference" to "loss"
# Notice
debug.set_fullbackward():
eg: O = AX + B
full_backward_register means getting A and B's grad
not full means getting AX's grad and B's grad 
fullbackward for inplace op(relu__..._) is not supported in pytorch yet.
## Test
1.Turn on the test switch:
```
test_paraser()
```
2.Use code following to verify the tool
```
python debug.py -i -b -l -p nv   
python debug.py -i -b -l -p bi -c   
```
There will be inference.csv, backward.csv, l1.csv, loss_l1.jpg in current directory.
## Analysis on saved data
if you make sure .npy is in current directory, you can use debug without running model.
```
debug.builder(...)
debug.run()

``` 
