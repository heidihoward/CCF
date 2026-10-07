# Transition system examples

This directory contains three small transition-system representations.

## `TransitionSystemA`

`TransitionSystemA.next` is a relation:

```lean
State -> Action -> State -> Prop
```

It describes which successor states are allowed. One state and action may have
zero, one, or many successors, so this representation naturally supports
nondeterministic specifications and mathematical proofs. It is not directly
executable because a proposition does not provide a way to enumerate its
solutions.

## `TransitionSystemB`

`TransitionSystemB.next` is a partial function:

```lean
State -> Action -> Option State
```

It returns one successor or `none` when an action is disabled. This makes the
system deterministic and directly executable, but it cannot represent multiple
possible successors for the same state and action.

## `TransitionSystemC`

`TransitionSystemC.next` returns a finite set of successors:

```lean
State -> Action -> Finset State
```

It is executable and supports finite nondeterminism. Unlike
`TransitionSystemA`, it cannot directly describe infinitely many successors.
Unlike `TransitionSystemB`, the same state and action may produce several
possible next states.

The interactive runner therefore uses `TransitionSystemB`. The A, B, and C
examples show how the same puzzle can be expressed using each representation.

## Exhaustive model checker

`TransitionSystemModelChecker.lean` provides a breadth-first model checker for
`TransitionSystemB`. It takes a concrete initial state, a complete list of
actions, an executable state-equivalence function, and a Boolean invariant. It
returns success only after exhausting the reachable state graph. If the
invariant fails, it returns a shortest trace from the initial state to the
failing state.

The reachable state space must be finite, and `actions` must contain every
action that should be checked. The checker is intentionally simple and stores
visited states in a list, so it is intended for small examples rather than
large state spaces.

The two-phase commit example checks that commit follows two yes votes and abort
follows at least one no vote:

```sh
cd lean
lake exe check-two-phase-commit
```

Run `lake exe check-two-phase-commit -- --demo-counterexample` to check the
deliberately false claim that commit is unreachable and print its shortest
counterexample.

## TLA+ examples

Each model family has its own subdirectory containing the Lean variants, a
TLA+ specification, and a small TLC configuration:

- `Counter/`
- `WaterPouring/`
- `TowerOfHanoi3/`
- `TowerOfHanoi/`
- `TwoPhaseCommit/`

The TLA+ modules mirror the transition relations in the corresponding Lean
examples. `TowerOfHanoi.tla` is parameterized by `DiskCount`, which is set to
three in `TowerOfHanoi.cfg`.

The two-phase commit example has one coordinator and two participants. Each
participant votes once, after which the coordinator commits if both votes are
yes or aborts if either vote is no. Participants can then acknowledge the
decision. Its TLC configuration checks that commit follows two yes votes and
abort follows at least one no vote.

After installing the repository's TLA+ dependencies, run TLC from the
repository's `tla` directory. For example:

```sh
./tlc.py mc ../lean/transition-systems/Counter/Counter.tla
./tlc.py mc ../lean/transition-systems/WaterPouring/WaterPouring.tla
./tlc.py mc ../lean/transition-systems/TowerOfHanoi3/TowerOfHanoi3.tla
./tlc.py mc ../lean/transition-systems/TowerOfHanoi/TowerOfHanoi.tla
./tlc.py mc ../lean/transition-systems/TwoPhaseCommit/TwoPhaseCommit.tla
```
