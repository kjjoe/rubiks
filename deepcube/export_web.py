"""Export the trained network to ONNX for the browser demo on the website.

The browser does the one-hot encoding itself, so the exported model takes the
one-hot input directly: (N, 324) floats -> (N,) estimated moves to solved.

    python -m deepcube.export_web --out ../website/assets/rubiks/deepcube.onnx
"""
import argparse

import torch
import torch.nn as nn
import torch.nn.functional as F

from .cube import Cube
from .model import load, predict


class OneHotInput(nn.Module):
    def __init__(self, net):
        super().__init__()
        self.net = net

    def forward(self, x):
        n = self.net
        return n.out(n.res(n.inp(x))).squeeze(-1)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--ckpt", default="checkpoints/deepcube.pt")
    p.add_argument("--out", default="../website/assets/rubiks/deepcube.onnx")
    args = p.parse_args()

    net, _ = load(args.ckpt, "cpu")
    model = OneHotInput(net).eval()
    torch.onnx.export(
        model, torch.zeros(1, 324), args.out,
        input_names=["x"], output_names=["cost"],
        dynamic_axes={"x": {0: "n"}, "cost": {0: "n"}}, opset_version=17,
    )

    # check the exported model against PyTorch on random scrambles
    import onnxruntime as ort

    cube = Cube("cpu")
    states, _ = cube.scramble(torch.randint(1, 31, (500,)))
    expected = predict(net, states).numpy()
    x = F.one_hot(states.long(), 6).flatten(1).float().numpy()
    got = ort.InferenceSession(args.out).run(None, {"x": x})[0]
    print(f"wrote {args.out}; max difference vs PyTorch {abs(got - expected).max():.2e}")


if __name__ == "__main__":
    main()
