import torch
import torch.nn.functional as F
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import unittest

class TestFastLayerNorm(unittest.TestCase):
    def setUp(self, seed=1234):
        seed = 1234
        torch.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
    # def test_ln_fp32(self):
    #     self.run_test_layer_norm(torch.float32, atol=1e-4)
    def test_ln_fp16(self):
        self.run_test_layer_norm(torch.float16, atol=1e-2, rtol=1e-3)

    def run_test_layer_norm(self, dtype, atol, rtol=1e-5):
        device = torch.device('cuda')
        s = 512
        b = 32
        hidden_size = 1024
        epsilon = 1e-5

        x = torch.randn((s,b,hidden_size), dtype=dtype, device=device)  
        beta = torch.randn(hidden_size, dtype=dtype, device=device)  
        gamma = torch.randn(hidden_size, dtype=dtype, device=device)
        x.requires_grad = True
        beta.requires_grad = True
        gamma.requires_grad = True

        dummy_label = torch.randn_like(x)

        y = F.layer_norm(x, [hidden_size], gamma, beta, eps=epsilon)

        diff = y-dummy_label
        l = (diff * diff).sum() / b
        l.backward()

        #torch.save(beta.grad, "beta_grad_nv.pt")
        y_nv = torch.load("y_nv.pt")
        x_grad_nv = torch.load("x_grad_nv.pt")
        beta_grad_nv = torch.load("beta_grad_nv.pt")
        gamma_grad_nv = torch.load("gamma_grad_nv.pt")

        index_max = torch.argmax(torch.abs(beta_grad_nv-beta.grad))
        print("index_max: ", index_max)
        print("beta_grad_nv[index_max]: ", beta_grad_nv.view(-1)[index_max])
        print("beta.grad[index_max]: ", beta.grad.view(-1)[index_max])
        data = pd.DataFrame({'nv': beta_grad_nv.flatten().tolist(), 'bi': beta.grad.flatten().tolist()})
        plt.figure(figsize=(12, 8))
        sns.scatterplot(x='nv', y='bi', data=data)
        plt.title(f"Grad elem-wise comparison")
        plt.savefig(f"Grad elem-wise comparison_layernorm.png")
        plt.show()
        # print("beta_grad_nv mean is: ", torch.mean(beta_grad_nv))
        # print("beta_grad_nv var is: ", torch.var(beta_grad_nv))
        # print("beta.grad mean is: ", torch.mean(beta.grad))
        # print("beta.grad var is: ", torch.var(beta.grad))
        # print("y: ", y)
        # print("y_nv:", y_nv)
        # print("x.grad: ", x.grad)
        # print("x_grad_nv: ", x_grad_nv)
        # index_max = torch.argmax(torch.abs(x_grad_nv-x.grad))
        # print("index_max: ", index_max)
        # print("x_grad_nv[index_max]: ", x_grad_nv.view(-1)[index_max])
        # print("x.grad[index_max]: ", x.grad.view(-1)[index_max])
        self.assertTrue(torch.allclose(y_nv, y, atol=atol, rtol=rtol))
        self.assertTrue(torch.allclose(x_grad_nv, x.grad, atol=atol, rtol=rtol))
        self.assertTrue(torch.allclose(beta_grad_nv, beta.grad, atol=atol, rtol=rtol))
        self.assertTrue(torch.allclose(gamma_grad_nv, gamma.grad, atol=atol, rtol=rtol))

if __name__ == '__main__':
    unittest.main()