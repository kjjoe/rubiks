"""Solve cubes with a trained network.

    python -m deepcube.solve --depth 20 --seed 1           # one random scramble
    python -m deepcube.solve --scramble "R U R' U' F2"     # your own scramble
    python -m deepcube.solve --bench 100 --depth 30        # solve rate and lengths

Solutions use the same move names as the MATLAB code, so they can be pasted
straight into doAlgorithm / animateSolution.
"""
import argparse
import statistics

import torch

from .cube import Cube, parse, to_string
from .model import load
from .search import astar


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--ckpt", default="checkpoints/deepcube.pt")
    p.add_argument("--scramble", help="move string to solve")
    p.add_argument("--depth", type=int, default=20, help="random scramble length")
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--bench", type=int, default=0, help="solve this many random scrambles and summarise")
    p.add_argument("--weight", type=float, default=0.6, help="A* weight on moves so far (1 = plain A*)")
    p.add_argument("--batch", type=int, default=1000, help="nodes expanded per A* step")
    p.add_argument("--time-limit", type=float, default=60.0)
    args = p.parse_args()

    device = "cuda" if torch.cuda.is_available() else "cpu"
    cube = Cube(device)
    net, _ = load(args.ckpt, device)
    gen = torch.Generator(device=device).manual_seed(args.seed)

    if args.scramble:
        scrambles = [parse(args.scramble)]
    else:
        n = max(args.bench, 1)
        _, moves = cube.scramble(torch.full((n,), args.depth), generator=gen)
        scrambles = [[int(m) for m in row] for row in moves.cpu()]

    lengths, times, n_solved = [], [], 0
    for scr in scrambles:
        start = cube.do_algorithm(cube.solved()[0], to_string(scr))
        r = astar(cube, net, start, weight=args.weight, batch=args.batch, time_limit=args.time_limit)
        if r.solved:
            assert cube.is_solved(cube.do_algorithm(start, to_string(r.moves))[None])[0]
            n_solved += 1
            lengths.append(len(r.moves))
        times.append(r.seconds)
        if not args.bench:
            print(f"scramble ({len(scr)}): {to_string(scr)}")
            if r.solved:
                print(f"solution ({len(r.moves)}): {to_string(r.moves)}")
            else:
                print("no solution found")
            print(f"{r.nodes:,} states generated in {r.seconds:.1f}s")
            if r.solved:
                print("\nMATLAB:")
                print(f'cube = doAlgorithm(newCube(), "{to_string(scr)}");')
                print(f'animateSolution("{to_string(r.moves)}", cube)')

    if args.bench:
        print(f"solved {n_solved}/{len(scrambles)} scrambles of depth {args.depth}")
        if lengths:
            print(f"solution length: mean {statistics.mean(lengths):.1f}, min {min(lengths)}, max {max(lengths)}")
        print(f"time per cube: mean {statistics.mean(times):.1f}s")


if __name__ == "__main__":
    main()
