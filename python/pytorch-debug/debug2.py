from collections import OrderedDict
import torch

forward_dict = {}
backward_dict = {}

def forward_wrapper(name):
    def forward_hook(module, input, output):
        # print(f"[Forward] {name}")
        # if torch.is_tensor(input):
        #     print(f"[Forward] {name}\t ==> input.dtype = {input.dtype}")
        #     # print(f"abs.mean = {input.abs().mean()}, abs.std = {input.abs().std()}, has nan? = {input.isnan().any()}, has inf? = {input.isinf().any()}")
        # else:
        #     for idx, inp in enumerate(input):
        #         print(f"[Forward] {name}\t ==> input{idx}.dtype = {inp.dtype}")
        #         # print(f"abs.mean = {inp.abs().mean()}, abs.std = {inp.abs().std()}, has nan? = {inp.isnan().any()}, has inf? = {inp.isinf().any()}")
        # if torch.is_tensor(output):
        #     print(f"{name}\t ==> output.dtype = {output.dtype}")
        #     # print(f"abs.mean = {output.abs().mean()}, abs.std = {output.abs().std()}, has nan? = {output.isnan().any()}, has inf? = {output.isinf().any()}")
        # else:
        #     for idx, out in enumerate(output):
        #         if out is not None:
        #             print(f"[Forward] {name}\t ==> output{idx}.dtype = {out.dtype}")
                # print(f"abs.mean = {out.abs().mean()}, abs.std = {out.abs().std()}, has nan? = {out.isnan().any()}, has inf? = {out.isinf().any()}")
        # if name == "mbox.3":
        #     forward_dict = OrderedDict()
        #     forward_dict[name] = OrderedDict()
        #     forward_dict[name]["input"] = list(input)
        #     forward_dict[name]["output"] = output
        #     global global_step
        #     np.save(f"bi_ssd_backward_seed{global_step}.npy", forward_dict)
        #     global_step += 1
        forward_dict[name] = OrderedDict()
        forward_dict[name]["input"] = list(input)
        forward_dict[name]["output"] = output
    return forward_hook

def backward_wrapper(name):
    def backward_hook(module, input, output):
        # print(f"[Backward] {name}")
        # if torch.is_tensor(input):
        #     print(f"[Backward] {name}\t ==> input.dtype = {input.dtype}")
        #     # print(f"abs.mean = {input.abs().mean()}, abs.std = {input.abs().std()}, has nan? = {input.isnan().any()}, has inf? = {input.isinf().any()}")
        # else:
        #     for idx, inp in enumerate(input):
        #         print(f"[Backward] {name}\t ==> input{idx}.dtype = {inp.dtype}")
        #         # print(f"abs.mean = {inp.abs().mean()}, abs.std = {inp.abs().std()}, has nan? = {inp.isnan().any()}, has inf? = {inp.isinf().any()}")
        # if torch.is_tensor(output):
        #     print(f"[Backward] {name}\t ==> output.dtype = {output.dtype}")
        #     # print(f"abs.mean = {output.abs().mean()}, abs.std = {output.abs().std()}, has nan? = {output.isnan().any()}, has inf? = {output.isinf().any()}")
        # else:
        #     for idx, out in enumerate(output):
        #         print(f"[Backward] {name}\t ==> output{idx}.dtype = {out.dtype}")
        #         # print(f"abs.mean = {out.abs().mean()}, abs.std = {out.abs().std()}, has nan? = {out.isnan().any()}, has inf? = {out.isinf().any()}")
        backward_dict[name] = OrderedDict()
        backward_dict[name]["input"] = list([i for i in input])
        backward_dict[name]["output"] = output

    return backward_hook