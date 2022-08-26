import torch.nn

ctc_loss = torch.nn.CTCLoss()
log_probs = torch.full((2, 1, 2), 0.2, dtype = torch.float)
targets = torch.full((1, 2), 1, dtype = torch.int)
targets[0, 0] = 0
input_lengths = torch.full((1,), 2, dtype = torch.int)
target_lengths = torch.full((1,), 2, dtype = torch.int)
device = torch.device('cpu')
loss = ctc_loss(log_probs, targets, input_lengths, target_lengths).to(device)
print(loss)
device = torch.device('cuda')
loss = ctc_loss(log_probs, targets, input_lengths, target_lengths).to(device)
print(loss)
