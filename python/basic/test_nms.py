from SSD import _C as C
import numpy as np
import torch


def main():
    input_data = torch.load("nms_input.pt")
    scores_in, offsets, score_sorted, score_sorted_idx, bboxes_in = input_data["scores_in"], input_data["offsets"], input_data["score_sorted"], input_data["score_sorted_idx"], input_data["bboxes_in"]
    criteria = 0.5
    max_num = 200
    bboxes_out, scores_out, labels_out = C.nms(1, # N
                                            scores_in.shape[0],
                                            offsets,
                                            score_sorted,
                                            score_sorted_idx,
                                            bboxes_in, # VITAL otherwise we get bad results :(
                                            criteria,
                                            max_num)
    print(f"[decode_single]\tbboxes_out = {bboxes_out}, scores_out = {scores_out},",
        f"labels_out = {labels_out}")


if __name__ == "__main__":
    main()
