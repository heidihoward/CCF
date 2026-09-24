import funandgames.TransitionSystemA

namespace TowerOfHanoi3A

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

def moveSmall (before : State) (target : Peg) (after : State) : Prop :=
  target ≠ before.small /\
    after = { before with small := target }

def moveMedium (before : State) (target : Peg) (after : State) : Prop :=
  before.small ≠ before.medium /\
    target ≠ before.medium /\
    before.small ≠ target /\
    after = { before with medium := target }

def moveLarge (before : State) (target : Peg) (after : State) : Prop :=
  before.small ≠ before.large /\
    before.medium ≠ before.large /\
    target ≠ before.large /\
    before.small ≠ target /\
    before.medium ≠ target /\
    after = { before with large := target }

def next (before : State) (action : Action) (after : State) : Prop :=
  match action.disk with
  | .small => moveSmall before action.target after
  | .medium => moveMedium before action.target after
  | .large => moveLarge before action.target after

def goal (state : State) : Prop :=
  state.small = .right /\
    state.medium = .right /\
    state.large = .right

def system : TransitionSystemA where
  State := State
  Action := Action
  initial := initial
  next := next

end TowerOfHanoi3A
