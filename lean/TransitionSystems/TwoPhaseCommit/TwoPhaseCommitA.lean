import TransitionSystems.TransitionSystemA

namespace TwoPhaseCommitA

inductive Participant where
  | first
  | second
deriving DecidableEq

inductive Decision where
  | collecting
  | commit
  | abort
deriving DecidableEq

structure State where
  votes : Participant -> Option Bool
  decision : Decision
  acknowledged : Participant -> Bool

inductive Action where
  | vote (participant : Participant) (value : Bool)
  | decideCommit
  | decideAbort
  | acknowledge (participant : Participant)

def initial (state : State) : Prop :=
  (forall participant, state.votes participant = none) /\
    state.decision = .collecting /\
    (forall participant, state.acknowledged participant = false)

def recordVote
    (before : State)
    (participant : Participant)
    (value : Bool)
    (after : State) : Prop :=
  before.decision = .collecting /\
    before.votes participant = none /\
    after =
      { before with
        votes := fun current =>
          if current = participant then some value else before.votes current }

def decideCommit (before after : State) : Prop :=
  before.decision = .collecting /\
    before.votes .first = some true /\
    before.votes .second = some true /\
    after = { before with decision := .commit }

def decideAbort (before after : State) : Prop :=
  before.decision = .collecting /\
    (before.votes .first = some false \/
      before.votes .second = some false) /\
    after = { before with decision := .abort }

def acknowledge
    (before : State)
    (participant : Participant)
    (after : State) : Prop :=
  before.decision != .collecting /\
    before.acknowledged participant = false /\
    after =
      { before with
        acknowledged := fun current =>
          if current = participant then true else before.acknowledged current }

def next (before : State) (action : Action) (after : State) : Prop :=
  match action with
  | .vote participant value => recordVote before participant value after
  | .decideCommit => decideCommit before after
  | .decideAbort => decideAbort before after
  | .acknowledge participant => acknowledge before participant after

def completed (state : State) : Prop :=
  state.decision != .collecting /\
    state.acknowledged .first = true /\
    state.acknowledged .second = true

def system : TransitionSystemA where
  State := State
  Action := Action
  initial := initial
  next := next

end TwoPhaseCommitA
