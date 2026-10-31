"""Cost-to-go network: estimates how many moves a state is from solved.

Same shape as DeepCubeA (Agostinelli et al. 2019): one-hot stickers ->
two fully connected layers -> residual blocks -> one number.
"""
import torch
import torch.nn as nn
import torch.nn.functional as F

SIZES = {
    "paper": dict(h1=5000, h2=1000, n_res=4),  # DeepCubeA, ~15M params
    "small": dict(h1=1000, h2=500, n_res=2),  # quick experiments
}


class ResBlock(nn.Module):
    def __init__(self, h):
        super().__init__()
        self.fc1, self.bn1 = nn.Linear(h, h), nn.BatchNorm1d(h)
        self.fc2, self.bn2 = nn.Linear(h, h), nn.BatchNorm1d(h)

    def forward(self, x):
        y = F.relu(self.bn1(self.fc1(x)))
        y = self.bn2(self.fc2(y))
        return F.relu(x + y)


class CostToGo(nn.Module):
    def __init__(self, h1=5000, h2=1000, n_res=4):
        super().__init__()
        self.config = dict(h1=h1, h2=h2, n_res=n_res)
        self.inp = nn.Sequential(
            nn.Linear(54 * 6, h1), nn.BatchNorm1d(h1), nn.ReLU(),
            nn.Linear(h1, h2), nn.BatchNorm1d(h2), nn.ReLU(),
        )
        self.res = nn.Sequential(*[ResBlock(h2) for _ in range(n_res)])
        self.out = nn.Linear(h2, 1)

    def forward(self, states):
        x = F.one_hot(states.long(), 6).flatten(1).float()  # (N, 324)
        return self.out(self.res(self.inp(x))).squeeze(-1)


@torch.no_grad()
def predict(net, states, batch=50_000):
    """Evaluate in eval mode and in chunks, so large batches don't run out of memory."""
    was_training = net.training
    net.eval()
    out = torch.cat([net(states[i:i + batch]) for i in range(0, len(states), batch)])
    net.train(was_training)
    return out


def load(path, device):
    ckpt = torch.load(path, map_location=device)
    net = CostToGo(**ckpt["config"]).to(device)
    net.load_state_dict(ckpt["model"])
    net.eval()
    return net, ckpt
