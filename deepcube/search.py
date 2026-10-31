"""Batch weighted A* guided by the cost-to-go network.

Each step pops the `batch` lowest-cost nodes, expands all of them at once on
the GPU, and scores every new child in one network call. Node cost is

    f = weight * g + h

with g = moves made so far and h = the network's estimate of moves left.
weight = 1 is plain A*, smaller weights trust the network more and search
faster but find longer solutions. The network can over-estimate, so even
weight = 1 does not guarantee the shortest solution.
"""
import heapq
import time
from dataclasses import dataclass

import numpy as np
import torch

from .cube import Cube
from .model import predict


@dataclass
class Result:
    moves: list  # move indices, empty if not found
    solved: bool
    nodes: int  # states generated
    seconds: float


def astar(cube: Cube, net, start, weight=0.6, batch=1000, max_nodes=5_000_000, time_limit=60.0):
    t0 = time.time()
    start = start.to(cube.device)
    if cube.is_solved(start[None])[0]:
        return Result([], True, 1, 0.0)

    def key(s):
        return s.tobytes()

    start_np = start.to(torch.uint8).cpu().numpy()
    k0 = key(start_np)
    # key -> (g, parent key, move from parent, state)
    nodes = {k0: (0, None, None, start_np)}
    h0 = predict(net, start[None]).item()
    heap, tie = [(h0, 0, k0, 0)], 1

    def path_to(k):
        moves = []
        while nodes[k][1] is not None:
            _, parent, m, _ = nodes[k]
            moves.append(m)
            k = parent
        return moves[::-1]

    while heap:
        if len(nodes) > max_nodes or time.time() - t0 > time_limit:
            break
        # pop up to `batch` nodes, skipping entries made stale by a later shorter path
        popped = []
        while heap and len(popped) < batch:
            _, _, k, g = heapq.heappop(heap)
            if g == nodes[k][0]:
                popped.append(k)
        if not popped:
            continue
        parents = np.stack([nodes[k][3] for k in popped])
        kids = cube.children(torch.from_numpy(parents).to(cube.device).long())  # (B, 18, 54)
        solved = cube.is_solved(kids).cpu().numpy()
        kids_np = kids.to(torch.uint8).cpu().numpy()

        if solved.any():
            b, m = np.argwhere(solved)[0]
            return Result(path_to(popped[b]) + [int(m)], True, len(nodes), time.time() - t0)

        new_keys, new_states, new_g = [], [], []
        for b, pk in enumerate(popped):
            g = nodes[pk][0] + 1
            for m in range(kids_np.shape[1]):
                s = kids_np[b, m]
                k = key(s)
                old = nodes.get(k)
                if old is None or g < old[0]:
                    nodes[k] = (g, pk, m, s)
                    new_keys.append(k)
                    new_states.append(s)
                    new_g.append(g)
        if not new_keys:
            continue
        h = predict(net, torch.from_numpy(np.stack(new_states)).to(cube.device).long()).cpu().numpy()
        for k, g, hv in zip(new_keys, new_g, h):
            heapq.heappush(heap, (weight * g + float(hv), tie, k, g))
            tie += 1

    return Result([], False, len(nodes), time.time() - t0)
