import TransitionSystems.TransitionSystemA

namespace TowerOfHanoiA

inductive Peg where
  | left
  | middle
  | right
deriving DecidableEq

abbrev State (n : Nat) :=
  Fin n -> Peg

inductive Action (n : Nat) where
  | moveDisk (disk : Fin n) (target : Peg)

def initial {n : Nat} (state : State n) : Prop :=
  forall disk, state disk = .left

def legal {n : Nat} (state : State n) : Action n -> Prop
  | .moveDisk disk target =>
      target ≠ state disk /\
        forall smaller,
          smaller.val < disk.val ->
            state smaller ≠ state disk /\
              state smaller ≠ target

def moveDisk
    {n : Nat}
    (state : State n)
    (disk : Fin n)
    (target : Peg) : State n :=
  fun current => if current = disk then target else state current

def next
    {n : Nat}
    (before : State n)
    (action : Action n)
    (after : State n) : Prop :=
  match action with
  | .moveDisk disk target =>
      legal before action /\
        after = moveDisk before disk target

def goal {n : Nat} (state : State n) : Prop :=
  forall disk, state disk = .right

def system (n : Nat) : TransitionSystemA where
  State := State n
  Action := Action n
  initial := initial
  next := next

end TowerOfHanoiA
