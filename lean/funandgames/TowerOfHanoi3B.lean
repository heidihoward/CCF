import funandgames.TransitionSystemB

namespace TowerOfHanoi3B

inductive Peg where
  | left
  | middle
  | right
deriving DecidableEq

inductive Disk where
  | small
  | medium
  | large

structure State where
  small : Peg
  medium : Peg
  large : Peg

structure Action where
  disk : Disk
  target : Peg

def initial (state : State) : Prop :=
  state.small = .left /\
    state.medium = .left /\
    state.large = .left

def moveSmall (state : State) (target : Peg) : Option State :=
  if target ≠ state.small then
    some { state with small := target }
  else
    none

def moveMedium (state : State) (target : Peg) : Option State :=
  if state.small ≠ state.medium /\
      target ≠ state.medium /\
      state.small ≠ target then
    some { state with medium := target }
  else
    none

def moveLarge (state : State) (target : Peg) : Option State :=
  if state.small ≠ state.large /\
      state.medium ≠ state.large /\
      target ≠ state.large /\
      state.small ≠ target /\
      state.medium ≠ target then
    some { state with large := target }
  else
    none

def next (state : State) (action : Action) : Option State :=
  match action.disk with
  | .small => moveSmall state action.target
  | .medium => moveMedium state action.target
  | .large => moveLarge state action.target

def goal (state : State) : Prop :=
  state.small = .right /\
    state.medium = .right /\
    state.large = .right

def system : TransitionSystemB where
  State := State
  Action := Action
  initial := initial
  next := next

end TowerOfHanoi3B
