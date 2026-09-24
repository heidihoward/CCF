import funandgames.TransitionSystemA

namespace TowerOfHanoiA

inductive Peg where
  | left
  | middle
  | right
deriving DecidableEq

abbrev State (n : Nat) :=
  Fin n -> Peg

structure Action (n : Nat) where
  disk : Fin n
  target : Peg

def initial {n : Nat} (state : State n) : Prop :=
  forall disk, state disk = .left

def legal {n : Nat} (state : State n) (action : Action n) : Prop :=
  action.target ≠ state action.disk /\
    forall smaller,
      smaller.val < action.disk.val ->
        state smaller ≠ state action.disk /\
          state smaller ≠ action.target

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
  legal before action /\
    after = moveDisk before action.disk action.target

def goal {n : Nat} (state : State n) : Prop :=
  forall disk, state disk = .right

def system (n : Nat) : TransitionSystemA where
  State := State n
  Action := Action n
  initial := initial
  next := next

end TowerOfHanoiA
