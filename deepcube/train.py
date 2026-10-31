"""Train the cost-to-go network with Deep Approximate Value Iteration (DAVI).

No solved examples are needed. For a scrambled state s the training target is

    J(s) = min over moves m of [1 + J_target(child_m(s))],   J(solved) = 0

where J_target is a frozen copy of the network. Whenever the network fits
those targets well (loss < threshold), the frozen copy is refreshed. Each
refresh lets distance information spread one step further out from solved.

    python -m deepcube.train --size small --iters 20000
"""
import argparse
import copy
import time
from pathlib import Path

import torch
import torch.nn.functional as F

from .cube import N_MOVES, Cube
from .model import SIZES, CostToGo, load, predict

EVAL_DEPTHS = [1, 2, 4, 6, 8, 10, 12, 15, 20, 25, 30]


def davi_targets(cube, target_net, states):
    n = len(states)
    kids = cube.children(states).reshape(-1, 54)
    h = predict(target_net, kids).clamp(min=0)
    h = torch.where(cube.is_solved(kids), 0.0, h).reshape(n, N_MOVES)
    targets = (1 + h).min(1).values
    return torch.where(cube.is_solved(states), 0.0, targets)


def depth_report(cube, net, n=200):
    """Mean predicted cost for scrambles of each depth. Should rise, then flatten near ~18-20."""
    parts = []
    for d in EVAL_DEPTHS:
        states, _ = cube.scramble(torch.full((n,), d))
        parts.append(f"{d}:{predict(net, states).mean():.1f}")
    return " ".join(parts)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--size", choices=SIZES, default="small")
    p.add_argument("--iters", type=int, default=20_000)
    p.add_argument("--batch", type=int, default=10_000)
    p.add_argument("--max-depth", type=int, default=30, help="scramble depths are uniform in 1..max-depth")
    p.add_argument("--lr", type=float, default=1e-3)
    p.add_argument("--lr-decay", type=float, default=0.99999, help="multiplied into lr every iteration")
    p.add_argument("--check-every", type=int, default=500, help="iterations between target-network checks")
    p.add_argument("--loss-thresh", type=float, default=0.05, help="refresh target network when loss is below this")
    p.add_argument("--out", default="checkpoints/deepcube.pt")
    p.add_argument("--resume", help="checkpoint to continue from")
    p.add_argument("--seed", type=int, default=0)
    args = p.parse_args()

    torch.manual_seed(args.seed)
    device = "cuda" if torch.cuda.is_available() else "cpu"
    torch.backends.cuda.matmul.allow_tf32 = True
    torch.backends.cudnn.allow_tf32 = True
    cube = Cube(device)

    start, n_updates = 0, 0
    if args.resume:
        net, ckpt = load(args.resume, device)
        net.train()
        start, n_updates = ckpt["iter"], ckpt["n_updates"]
    else:
        net = CostToGo(**SIZES[args.size]).to(device)
    target_net = copy.deepcopy(net).eval()
    opt = torch.optim.Adam(net.parameters(), lr=args.lr)
    sched = torch.optim.lr_scheduler.ExponentialLR(opt, gamma=args.lr_decay)

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)

    def save(it):
        torch.save(dict(model=net.state_dict(), config=net.config, iter=it, n_updates=n_updates), out)

    print(f"device={device} params={sum(p.numel() for p in net.parameters()) / 1e6:.1f}M")
    window, t0, it = [], time.time(), start
    try:
        for it in range(start + 1, start + args.iters + 1):
            depths = torch.randint(1, args.max_depth + 1, (args.batch,), device=device)
            states, _ = cube.scramble(depths)
            targets = davi_targets(cube, target_net, states)

            loss = F.mse_loss(net(states), targets)
            opt.zero_grad(set_to_none=True)
            loss.backward()
            opt.step()
            sched.step()
            window.append(loss.item())

            if it % args.check_every == 0:
                mean_loss = sum(window) / len(window)
                window = []
                updated = mean_loss < args.loss_thresh
                if updated:
                    target_net.load_state_dict(net.state_dict())
                    n_updates += 1
                print(
                    f"it {it:>7}  loss {mean_loss:.4f}  lr {sched.get_last_lr()[0]:.2e}  "
                    f"target updates {n_updates}{' (updated)' if updated else ''}  "
                    f"{(time.time() - t0) / args.check_every * 1000:.0f} ms/it"
                )
                print(f"           cost by depth  {depth_report(cube, net)}", flush=True)
                save(it)
                t0 = time.time()
    except KeyboardInterrupt:
        print("interrupted")
    save(it)
    print(f"saved {out}")


if __name__ == "__main__":
    main()
