import torch
import random
import numpy as np
def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True
set_seed(100)

FUSION_GROUP = 'prim::CudaFusionGroup'

def _getSubgraphInFusion(graph):
        num_node = 0
        subgraph = None

        def count(block, ret):
            for n in block.nodes():
                if n.kind() == FUSION_GROUP:
                    ret[0] = ret[0] + 1
                    self.assertTrue(n.hasAttribute('Subgraph'))
                    ret[1] = n.g('Subgraph')
                for block in n.blocks():
                    count(block, ret)
        ret = [num_node, subgraph]
        count(graph, ret)
        #self.assertEqual(ret[0], 1)
        return ret[1]

def t(x: torch.Tensor, y: torch.Tensor, z: float):
            o = x + y
            o = o + z
            return o
t_jit = torch.jit.script(t)
print(t_jit)

x = torch.randn(1, dtype=torch.float, device="cuda")
print(x)
y = torch.randn(1, dtype=torch.float, device="cuda")
print(y)
jit_o = t_jit(x, y, 2.0)
print(jit_o)

jit_graph = t_jit.graph_for(x, y, 2.0)
print(jit_graph)

subgraph = _getSubgraphInFusion(jit_graph)
print(subgraph)
