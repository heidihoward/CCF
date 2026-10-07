# Transition system examples

This directory contains two small transition-system representations.

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

The interactive runner therefore uses `TransitionSystemB`. The paired examples
show how the same puzzle can be expressed using either representation.
