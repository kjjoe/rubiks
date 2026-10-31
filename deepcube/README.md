# DeepCube (PyTorch)

A small re-implementation of DeepCubeA (Agostinelli et al., 2019): learn how far
each cube is from solved with no human solutions, then search with that estimate.

| File | What it does |
| --- | --- |
| `cube.py` | 54-sticker cube; every move is a permutation, batched on GPU |
| `model.py` | cost-to-go network (one-hot stickers -> residual MLP -> 1 number) |
| `train.py` | Deep Approximate Value Iteration training |
| `search.py` | batch weighted A* guided by the network |
| `solve.py` | solve one scramble or benchmark many |
| `export_perms.m` | exports the MATLAB move functions to `data/cube_perms.json` |

Move names and directions are the MATLAB ones, so solutions paste straight into
`doAlgorithm` / `animateSolution`.

## Setup (from the repo root)

```
python -m venv .venv
.venv\Scripts\python -m pip install torch --index-url https://download.pytorch.org/whl/cu124
.venv\Scripts\python -m pip install numpy pytest
.venv\Scripts\python -m pytest deepcube/tests
```

## Train and solve

```
.venv\Scripts\python -m deepcube.train --size small --iters 20000
.venv\Scripts\python -m deepcube.solve --depth 20 --seed 1
.venv\Scripts\python -m deepcube.solve --bench 50 --depth 30
```

Use `--hours 2` to cap training by time instead of (or as well as) `--iters`.
The checkpoint (`checkpoints/deepcube.pt`) is saved every `--check-every`
iterations and whenever training stops, including Ctrl+C, and the progress
printout is appended to `checkpoints/deepcube.log`. `--resume checkpoints/deepcube.pt`
continues exactly where it stopped (same target network, learning rate and
optimizer state). Every `--check-every` iterations it prints the mean predicted cost
for scrambles of each depth. That should climb with depth and level off around
18-20, since no position is more than 20 moves from solved.

## How training works

The target for a scrambled state is `1 + min over the 18 moves of J(child)`,
and a solved state is 0. `J` is a frozen copy of the network, refreshed whenever
the network fits its targets (loss below `--loss-thresh`). Each refresh pushes
correct distances one move further from solved, so the number of target updates
is roughly how deep the network "sees".
