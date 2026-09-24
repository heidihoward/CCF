import funandgames.TransitionSystemB

namespace TowerOfHanoiB

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

def smallerDisksClear
    {n : Nat}
    (state : State n)
    (disk : Fin n)
    (target : Peg) : Nat -> Bool
  | 0 => true
  | count + 1 =>
      if within : count < disk.val then
        let smaller : Fin n :=
          ⟨count, Nat.lt_trans within disk.isLt⟩
        decide (state smaller ≠ state disk) &&
          decide (state smaller ≠ target) &&
          smallerDisksClear state disk target count
      else
        false

def legal {n : Nat} (state : State n) (action : Action n) : Bool :=
  decide (action.target ≠ state action.disk) &&
    smallerDisksClear state action.disk action.target action.disk.val

def moveDisk
    {n : Nat}
    (state : State n)
    (disk : Fin n)
    (target : Peg) : State n :=
  fun current => if current = disk then target else state current

def next {n : Nat} (state : State n) (action : Action n) : Option (State n) :=
  if legal state action then
    some (moveDisk state action.disk action.target)
  else
    none

def goal {n : Nat} (state : State n) : Prop :=
  forall disk, state disk = .right

def system (n : Nat) : TransitionSystemB where
  State := State n
  Action := Action n
  initial := initial
  next := next

end TowerOfHanoiB
