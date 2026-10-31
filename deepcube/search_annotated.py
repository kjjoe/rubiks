"""search.py, annotated line by line.

This is a teaching copy of `astar` in search.py. The logic is identical (it
finds the same solutions); it only adds explanations and an optional
`verbose` trace that prints what happens each round. Run it to watch a solve:

    python -m deepcube.search_annotated --depth 8 --seed 3

------------------------------------------------------------------------------
THE BIG PICTURE
------------------------------------------------------------------------------
Think of every cube state as a node in a giant graph. Each node has 18 edges
(the 18 moves) leading to 18 neighbouring nodes. Solving the cube means
finding a path from the scrambled node to the solved node.

A* keeps two collections:

  * `nodes`  - every state it has seen so far ("the map it has drawn").
               For each one it remembers how many moves it took to get there
               and which state + move it came from, so the path can be
               traced back at the end.

  * `heap`   - the "frontier": states that have been seen but not yet
               expanded (their children not yet generated). It is a priority
               queue, so the most promising state is always on top.

"Most promising" is measured by

    f = weight * g + h

    g = moves already made to reach this state (known exactly)
    h = network's guess of moves still needed (the cost-to-go network)

With weight = 1, f is "estimated total solution length through this state",
which is textbook A*. With weight = 0.6 the search cares less about how long
the path so far is and more about how close the network says it is to solved,
so it dives toward the goal faster but may return a longer solution.

Each round:
  1. take the best ~1000 states off the frontier
  2. generate all 18 children of each (on the GPU, all at once)
  3. if any child is solved -> trace the path back and return it
  4. record the new children, score them with the network (one GPU call)
  5. push them onto the frontier, and repeat

"Batch" A* (doing 1000 at a time instead of 1) is the DeepCubeA trick: a GPU
is slow for one cube but nearly as fast for 18,000 cubes, so batching makes
each network call worth it.

------------------------------------------------------------------------------
A TINY WORKED EXAMPLE (weight = 0.6)
------------------------------------------------------------------------------
Start S, network says h(S) = 7.0                       frontier: [S f=7.0]
Round 1: expand S, children A..R. Say the network rates
    A: h=5.9  -> f = 0.6*1 + 5.9 = 6.5
    B: h=6.4  -> f = 0.6*1 + 6.4 = 7.0
    ... (16 more)                                      frontier: [A 6.5, B 7.0, ...]
Round 2: A is best, expand it. Its children are at g = 2:
    A1: h=4.8 -> f = 1.2 + 4.8 = 6.0
    A2: h=6.9 -> f = 1.2 + 6.9 = 8.1                   frontier: [A1 6.0, B 7.0, ..., A2 8.1]
If A1's children all turn out worse than the network expected, their f values
rise above B's 7.0, and B gets expanded next. That ability to back up and
try another branch is what greedy search (always take the single best child)
lacks.
"""
import argparse
import heapq
import time

import numpy as np
import torch

from .cube import Cube, to_string
from .model import load, predict
from .search import Result


def astar(cube: Cube, net, start, weight=0.6, batch=1000, max_nodes=5_000_000, time_limit=60.0, verbose=False):
    t0 = time.time()

    # `start` is one cube: a tensor of 54 colour numbers. Put it on the same
    # device (GPU) as the move tables.
    start = start.to(cube.device)

    # Already solved? Then the answer is "no moves".
    # (start[None] adds a batch dimension: (54,) -> (1, 54), because the cube
    # functions always work on batches.)
    if cube.is_solved(start[None])[0]:
        return Result([], True, 1, 0.0)

    # ------------------------------------------------------------------
    # Remembering states
    # ------------------------------------------------------------------
    # To ask "have I seen this cube before?" quickly we need a dictionary
    # key. A tensor can't be a key, but its raw bytes can: 54 colours stored
    # as uint8 -> a 54-byte string that is unique for each state.
    def key(s):
        return s.tobytes()

    # The bookkeeping (dictionary, heap) is plain Python, so it lives on the
    # CPU as numpy arrays. Only the heavy maths goes to the GPU.
    start_np = start.to(torch.uint8).cpu().numpy()
    k0 = key(start_np)

    # nodes: key -> (g, parent key, move from parent, state)
    #   g           moves from the start to reach this state (best found so far)
    #   parent key  the state we came from (None for the start)
    #   move        which of the 18 moves led here from the parent
    #   state       the 54 colours, kept so we can expand it later
    nodes = {k0: (0, None, None, start_np)}

    # The frontier. Python's heapq is a min-heap: heappop always returns the
    # entry with the smallest first element, which here is f.
    # Each entry is (f, tie, key, g):
    #   f    priority (lower = more promising)
    #   tie  an ever-increasing counter. If two entries have equal f, Python
    #        compares the next element; the counter keeps that comparison
    #        cheap and makes earlier-pushed entries win ties.
    #   key  which state this entry refers to
    #   g    the g this entry was pushed with (used to detect stale entries)
    h0 = predict(net, start[None]).item()
    heap, tie = [(h0, 0, k0, 0)], 1

    # Rebuild the solution by walking parent links from a state back to the
    # start, collecting moves, then reversing them into forward order.
    def path_to(k):
        moves = []
        while nodes[k][1] is not None:
            _, parent, m, _ = nodes[k]
            moves.append(m)
            k = parent
        return moves[::-1]

    round_no = 0
    while heap:
        round_no += 1

        # Give up if the map has grown too big (memory) or we've run too long.
        if len(nodes) > max_nodes or time.time() - t0 > time_limit:
            break

        # --------------------------------------------------------------
        # 1. Take the best `batch` states off the frontier
        # --------------------------------------------------------------
        # A state can be pushed more than once: if we later find a shorter
        # route to it, we update nodes[k] and push it again with the smaller
        # g. The old heap entry is then "stale". heapq can't delete from the
        # middle, so instead we skip an entry when its g no longer matches
        # the best g recorded in `nodes`.
        popped = []
        best_f = heap[0][0]
        while heap and len(popped) < batch:
            _, _, k, g = heapq.heappop(heap)
            if g == nodes[k][0]:
                popped.append(k)
        if not popped:
            continue

        # --------------------------------------------------------------
        # 2. Generate all 18 children of every popped state, on the GPU
        # --------------------------------------------------------------
        # parents: (B, 54) numpy array, B = number popped (up to `batch`).
        parents = np.stack([nodes[k][3] for k in popped])
        # cube.children applies all 18 move permutations at once:
        # (B, 54) -> (B, 18, 54). kids[b, m] = state popped[b] after move m.
        kids = cube.children(torch.from_numpy(parents).to(cube.device).long())

        # --------------------------------------------------------------
        # 3. Stop as soon as any child is solved
        # --------------------------------------------------------------
        # solved: (B, 18) True/False grid. Checking when a state is
        # *generated* (rather than when it is popped, as textbook A* does)
        # finishes one round sooner. Textbook A* waits so it can guarantee
        # the shortest path; we already gave that up by using a network
        # that can be wrong and weight < 1.
        solved = cube.is_solved(kids).cpu().numpy()
        kids_np = kids.to(torch.uint8).cpu().numpy()  # back to CPU for the bookkeeping

        if solved.any():
            # argwhere lists the (b, m) positions that are True; take the
            # first. The solution = path to parent popped[b], then move m.
            b, m = np.argwhere(solved)[0]
            if verbose:
                print(f"round {round_no}: solved! child of a state at g={nodes[popped[b]][0]}")
            return Result(path_to(popped[b]) + [int(m)], True, len(nodes), time.time() - t0)

        # --------------------------------------------------------------
        # 4. Record the children that are new (or reached by a shorter route)
        # --------------------------------------------------------------
        # This is the CPU-heavy part: a Python loop over B * 18 children.
        # Most children are new; some are states already in the map. Moving
        # a face and then moving it back, for example, returns to the parent
        # at a worse g, so it is ignored.
        new_keys, new_states, new_g = [], [], []
        for b, pk in enumerate(popped):
            g = nodes[pk][0] + 1  # every child is one move further than its parent
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

        # --------------------------------------------------------------
        # 5. Score all new children with ONE network call and push them
        # --------------------------------------------------------------
        # This is where batching pays off: up to 18,000 states go through
        # the network together on the GPU. h[i] = estimated moves left
        # for new_states[i].
        h = predict(net, torch.from_numpy(np.stack(new_states)).to(cube.device).long()).cpu().numpy()
        for k, g, hv in zip(new_keys, new_g, h):
            heapq.heappush(heap, (weight * g + float(hv), tie, k, g))
            tie += 1

        if verbose:
            gs = [nodes[k][0] for k in popped]
            print(
                f"round {round_no:>3}: expanded {len(popped):>4} states (g {min(gs)}-{max(gs)}, best f {best_f:.2f})  "
                f"new {len(new_keys):>5}  lowest h {h.min():.2f}  frontier {len(heap):>7,}  seen {len(nodes):>8,}"
            )

    # Ran out of time/memory (or, in theory, the frontier emptied).
    return Result([], False, len(nodes), time.time() - t0)


def main():
    p = argparse.ArgumentParser(description="Watch A* solve one scramble, round by round.")
    p.add_argument("--ckpt", default="checkpoints/deepcube.pt")
    p.add_argument("--depth", type=int, default=8)
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--weight", type=float, default=0.6)
    p.add_argument("--batch", type=int, default=1000)
    args = p.parse_args()

    device = "cuda" if torch.cuda.is_available() else "cpu"
    cube = Cube(device)
    net, _ = load(args.ckpt, device)
    gen = torch.Generator(device=device).manual_seed(args.seed)
    states, moves = cube.scramble(torch.tensor([args.depth]), generator=gen)

    print(f"scramble: {to_string(moves[0])}")
    print(f"network's estimate for the scramble: {predict(net, states).item():.2f} moves\n")
    r = astar(cube, net, states[0], weight=args.weight, batch=args.batch, verbose=True)
    if r.solved:
        print(f"\nsolution ({len(r.moves)}): {to_string(r.moves)}")
    print(f"{r.nodes:,} states seen in {r.seconds:.2f}s")


if __name__ == "__main__":
    main()
