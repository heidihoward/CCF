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
