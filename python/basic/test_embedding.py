import torch
    
def create_embedding(device):
    # Seed RNG so we get the same Embedding each time
    torch.manual_seed(0)
    return torch.nn.Embedding(
        num_embeddings=20,
        embedding_dim=64,
        max_norm=1.0).to(device)

if __name__ == '__main__':
    ix = torch.arange(2, device='cpu', dtype=torch.long).repeat(2000)
    ix = ix.to('cuda')
    out = create_embedding('cuda')(ix)
    # print("out is: ", out)
