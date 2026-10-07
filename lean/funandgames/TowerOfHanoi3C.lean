import funandgames.TransitionSystemC

namespace TowerOfHanoi3C

inductive Peg where
  | left
  | middle
  | right
deriving DecidableEq

structure State where
  small : Peg
  medium : Peg
  large : Peg
deriving DecidableEq

inductive Disk where
  | small
  | medium
  | large

inductive Action where
  | moveDisk (disk : Disk) (target : Peg)

def initial (state : State) : Prop :=
  state.small = .left /\
    state.medium = .left /\
    state.large = .left

def moveSmall (state : State) (target : Peg) : Finset State :=
  if target ≠ state.small then
    {{ state with small := target }}
  else
    {}

def moveMedium (state : State) (target : Peg) : Finset State :=
  if state.small ≠ state.medium /\
      target ≠ state.medium /\
      state.small ≠ target then
    {{ state with medium := target }}
  else
    {}

def moveLarge (state : State) (target : Peg) : Finset State :=
  if state.small ≠ state.large /\
      state.medium ≠ state.large /\
      target ≠ state.large /\
      state.small ≠ target /\
      state.medium ≠ target then
    {{ state with large := target }}
  else
    {}

def next (state : State) (action : Action) : Finset State :=
  match action with
  | .moveDisk .small target => moveSmall state target
  | .moveDisk .medium target => moveMedium state target
  | .moveDisk .large target => moveLarge state target

def goal (state : State) : Prop :=
  state.small = .right /\
    state.medium = .right /\
    state.large = .right

def system : TransitionSystemC where
  State := State
  Action := Action
  initial := initial
  next := next

end TowerOfHanoi3C
