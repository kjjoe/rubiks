"""Sticker-array Rubik's cube, batched with PyTorch.

A cube is a length-54 vector of colours 0-5. The sticker order and the move
permutations are exported from the MATLAB code (export_perms.m), so move
names and directions match doAlgorithm.m exactly. Every move is a fixed
permutation, so applying it is just a gather: new_state = state[perm].
"""
import json
from pathlib import Path

import torch

DATA = Path(__file__).parent / "data"
FACES = "UDLRFB"
MOVE_NAMES = [f + s for f in FACES for s in ("", "'", "2")]  # 18 half-turn-metric moves
N_MOVES = len(MOVE_NAMES)


def _load_perms():
    d = json.loads((DATA / "cube_perms.json").read_text())
    perms = []
    for f in FACES:
        q = torch.tensor(d[f])
        qp = torch.tensor(d[f + "_prime"])
        perms += [q, qp, q[q]]  # quarter, prime, double (= quarter applied twice)
    solved = torch.tensor(d["solved_colors"]) - 1
    return torch.stack(perms), solved


class Cube:
    """Holds the move tables on a device and works on batches of states (N, 54)."""

    def __init__(self, device="cpu"):
        perms, solved = _load_perms()
        self.device = torch.device(device)
        self.perms = perms.to(self.device)  # (18, 54)
        self.goal = solved.to(self.device)  # (54,)
        ident = torch.arange(54, device=self.device)
        # inverse[m] is the move that undoes m
        self.inverse = torch.tensor(
            [next(j for j in range(N_MOVES) if torch.equal(p[self.perms[j]], ident)) for p in self.perms],
            device=self.device,
        )

    def solved(self, n=1):
        return self.goal.expand(n, 54).clone()

    def is_solved(self, states):
        return (states == self.goal).all(-1)

    def apply(self, states, moves):
        """Apply one move per state. states (N, 54), moves (N,) of move indices."""
        return states.gather(1, self.perms[moves])

    def children(self, states):
        """All 18 successors of each state: (N, 54) -> (N, 18, 54)."""
        return states[:, self.perms]

    def scramble(self, depths, generator=None):
        """Random scrambles, one per entry of depths (N,). Returns states and moves (N, max_depth), -1 = unused."""
        depths = torch.as_tensor(depths, device=self.device)
        n, max_d = len(depths), int(depths.max())
        moves = torch.randint(0, N_MOVES, (n, max_d), device=self.device, generator=generator)
        states = self.solved(n)
        for t in range(max_d):
            active = depths > t
            states = torch.where(active[:, None], self.apply(states, moves[:, t]), states)
        moves[torch.arange(max_d, device=self.device) >= depths[:, None]] = -1
        return states, moves

    def do_algorithm(self, state, algo):
        """Apply a MATLAB-style move string ("R U' F2") to a single state (54,)."""
        for m in parse(algo):
            state = state[self.perms[m]]
        return state


def parse(algo):
    """Move string -> list of move indices."""
    return [MOVE_NAMES.index(tok) for tok in str(algo).split()]


def to_string(moves):
    """Move indices -> MATLAB-style move string, skipping -1 padding."""
    return " ".join(MOVE_NAMES[int(m)] for m in moves if int(m) >= 0)
