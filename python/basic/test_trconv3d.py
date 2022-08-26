from collections import OrderedDict
import numpy as np
import time
from tqdm import trange
import torch


num_repeats = 100

def gen_np_args(*input_shape):
    value_range=[-10, 10]
    np.random.seed(0)
    x = np.random.randn(*input_shape)* \
                      (value_range[0] - value_range[1]) + value_range[1]
    x = x.astype(np.float32)
    return x
class TestConv3d(torch.nn.Module):
    def __init__(
        self, input_shape, conv_args,
        value_range=[-10, 10], half=False, device="cuda:0"
    ):
        super(TestConv3d, self).__init__()
        self.conv3d = torch.nn.Conv3d(**conv_args, bias=False)
        # self.input  = torch.rand(*input_shape) * \
        #               (value_range[0] - value_range[1]) + value_range[1]
        # self.input.requires_grad=True
        np_arr = gen_np_args(*input_shape) 
        self.input  =  torch.tensor(np_arr,dtype=torch.float32,requires_grad=True,device=device)
        self.conv3d = self.conv3d.to(device)
        if half:
            self.input  = self.input.half()
            self.conv3d = self.conv3d.half()

    def forward(self, x=None):
        return self.conv3d(self.input)
class TestConvTranspose3d(torch.nn.Module):
    def __init__(
    self, input_shape, conv_args,
    value_range=[-10, 10], half=False, device="cuda:0"
    ):
        super(TestConvTranspose3d, self).__init__()
        self.ConvTranspose3d = torch.nn.ConvTranspose3d(**conv_args, bias=False)
        # self.input  = torch.rand(*input_shape) * \
        #               (value_range[0] - value_range[1]) + value_range[1]
        # self.input.requires_grad=True
        np_arr = gen_np_args(*input_shape) 
        self.input  =  torch.tensor(np_arr,dtype=torch.float32,requires_grad=True,device=device)
        self.ConvTranspose3d = self.ConvTranspose3d.to(device)
        if half:
            self.input  = self.input.half()
            self.ConvTranspose3d = self.ConvTranspose3d.half()

    def forward(self, x=None):
        return self.ConvTranspose3d(self.input)
class TestInstanceNorm3d(torch.nn.Module):
    def __init__(
    self, input_shape,
    value_range=[-10, 10], half=False, device="cuda:0"
    ):
        super(TestInstanceNorm3d, self).__init__()
        # self.ConvTranspose3d = torch.nn.ConvTranspose3d(**conv_args, bias=False)
        self.InstanceNorm3d = torch.nn.InstanceNorm3d(input_shape[1],affine=True)
        # self.InstanceNorm3d = torch.nn.BatchNorm3d(input_shape[1])
        # self.input  = torch.rand(*input_shape) * \
        #               (value_range[0] - value_range[1]) + value_range[1]
        # self.input.requires_grad=True
        np_arr = gen_np_args(*input_shape) 
        self.input  =  torch.tensor(np_arr,dtype=torch.float32,requires_grad=True,device=device)
        self.InstanceNorm3d = self.InstanceNorm3d.to(device)
        if half:
            self.input  = self.input.half()
            self.InstanceNorm3d = self.InstanceNorm3d.half()

    def forward(self, x=None):
        return self.InstanceNorm3d(self.input)


if __name__=="__main__":
    cuda_device = "cuda:0"

    arg_cases = [
 
        {
            "input_shape": (1, 32, 64, 64, 64),
            "half": False,
            "conv_args": {
                            "in_channels": 32,
                            "out_channels": 64,
                            "kernel_size": (3, 3, 3),
                            "stride": (1, 1, 1),
                            "padding": (1, 1, 1)}
        }

    ]
    arg_cases_trans = [
 
        {
            "input_shape": (1, 32, 64, 64, 64),
            "half": False,
            "conv_args": {
                            "in_channels": 32,
                            "out_channels": 64,
                            "kernel_size": (2, 2, 2),
                            "stride": (2, 2, 2),
                            "padding": (0, 0, 0)}
        }

    ]
    arg_cases_instancenorm = [
 
        {
            "input_shape": (1, 32, 64, 64, 64),
            "half": False,
            # "conv_args": {
            #                 "in_channels": 32,
            #                 "out_channels": 64,
            #                 "kernel_size": (2, 2, 2),
            #                 "stride": (2, 2, 2),
            #                 "padding": (0, 0, 0)}
        }

    ]

    seed = 1234
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = False
    torch.backends.cudnn.benchmark = True
    test_results = OrderedDict()
    case_idx = 0
    # for arg_case in arg_cases:
    for arg_case in arg_cases_instancenorm:
        case_str = str(arg_case)
        case_idx += 1
        print(f'{case_idx}. {case_str}')
        test_results[case_str] = dict()
        # test_func = TestConv3d(**arg_case)
        # test_func = TestConvTranspose3d(**arg_case)
        test_func = TestInstanceNorm3d(**arg_case)
        # warmup
        
        output = test_func()
        # torch.cuda.synchronize()
        loss = (output*output).sum()
        loss.backward()
        # grad = torch.rand_like(output)
        # output.backward(grad)
        print('**************output***************')
        print(output[0,0,0,0,:])
        print('**************grad***************')
        print(test_func.input.grad[0,0,0,0,:])

