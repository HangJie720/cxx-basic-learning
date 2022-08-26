'''
Description: 
Author: Liwei Dai
Date: 2021-06-22 09:53:04
LastEditors: VSCode
LastEditTime: 2021-06-22 10:06:19
'''
import torch
import unittest


def local_foreach_non_finite_check_and_unscale_(grads, found_inf, inv_scale):
    """
    Check if any grad tensor in the grads list has inf, then set found_inf to 1.0, else unscale the grad.
    """

    for grad in grads:
        if torch.isinf(torch.sum(grad)) | torch.isnan(torch.sum(grad)):
            found_inf[0] = 1.0
            return
    for grad in grads:
        grad *= inv_scale
    return


class TestGradUnscale(unittest.TestCase):
    def test_grad_scaling_unscale(self, dtype=torch.float):
            inv_scale = torch.full((1,), 0.25, dtype=torch.float, device="cuda:0")
            found_inf = torch.full((1,), 0.0, dtype=torch.float, device="cuda:0")

            size = 10
            g = torch.full((size, size), 4.0, dtype=dtype, device="cuda:0")
            ginf = g.clone()
            ginf[2, 2] = float('inf')
            gnan = g.clone()
            gnan[2, 2] = float('nan')

            # Tries selected combinations of
            #  - contiguous grads
            #  - g.clone().t() which is not contiguous but still non overlapping and dense
            #  - variants of g.clone()[:, :5] which are not non overlapping and dense
            # Non overlapping and dense grads route into a multi tensor apply kernel,
            # others use a fallback per-tensor kernel, so we should try both.
            cases = (
                ([g.clone(), g.clone()], False),
                ([g.clone(), g.clone().t()], False),
                ([g.clone(), g.clone()[:, :5]], False),
                ([g.clone()[:, :5], g.clone()[:, :5]], False),
                ([g.clone(), ginf.clone()], True),
                ([g.clone(), gnan.clone()], True),
                ([g.clone(), ginf.clone()[:, :5]], True),
                ([g.clone(), gnan.clone()[:, :5]], True),
                ([ginf.clone(), g.clone()[:, :5]], True),
                ([ginf.clone()[:, :5], g.clone()[:, :5]], True),
            )

            for grads, has_inf in cases:
                found_inf.zero_()
                torch._amp_foreach_non_finite_check_and_unscale_(grads, found_inf, inv_scale)
                # local_foreach_non_finite_check_and_unscale_(grads, found_inf, inv_scale)
                if has_inf:
                    self.assertEqual(found_inf, 1.0)
                else:
                    self.assertEqual(found_inf, 0.0)
                    for grad in grads:
                        self.assertTrue(torch.allclose(grad, torch.ones_like(grad), atol=1e-7))


if __name__ == "__main__":
    unittest.main()
