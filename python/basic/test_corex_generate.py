import argparse
from pathlib import Path


def get_torch_corex(corex_arch):
    if "ivcore" in corex_arch:
        corex = True
    else:
        corex = False
    return corex

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate torch/corex.py from build and environment metadata.")
    parser.add_argument("--corex_arch", type=str)

    args = parser.parse_args()

    assert args.corex_arch is not None
    print("args.corex_arch is: ", args.corex_arch)
    corex = get_torch_corex(args.corex_arch)
    print("corex is: ", corex)

    with open("corex.py", 'w') as f:
       f.write("corex = {}\n".format(repr(bool(corex))))
       f.write("corex_arch = {}\n".format(repr(args.corex_arch)))

