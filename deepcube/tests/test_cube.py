import json

import torch

from deepcube.cube import DATA, MOVE_NAMES, Cube, parse, to_string

cube = Cube()


def test_matches_matlab_scramble():
    case = json.loads((DATA / "cube_testcase.json").read_text())
    state = cube.do_algorithm(cube.solved()[0], case["algo"])
    assert torch.equal(state, torch.tensor(case["colors"]) - 1)


def test_move_orders_and_inverses():
    s = cube.solved()
    for m, name in enumerate(MOVE_NAMES):
        order = 2 if name.endswith("2") else 4
        t = s
        for _ in range(order):
            t = cube.apply(t, torch.tensor([m]))
        assert cube.is_solved(t).all(), name
        undone = cube.apply(cube.apply(s, torch.tensor([m])), cube.inverse[[m]])
        assert cube.is_solved(undone).all(), name


def test_children_and_scramble():
    depths = torch.tensor([0, 1, 5, 20])
    states, moves = cube.scramble(depths)
    assert cube.is_solved(states[:1]).all()
    assert not cube.is_solved(states[1:2]).any()  # one move is never solved
    for s, mv in zip(states, moves):
        assert torch.equal(cube.do_algorithm(cube.solved()[0], to_string(mv)), s)
    assert cube.children(states).shape == (4, 18, 54)


def test_parse_round_trip():
    algo = "R U' F2 B D' L2"
    assert to_string(parse(algo)) == algo
