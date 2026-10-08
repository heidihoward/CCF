import TransitionSystems.TransitionSystemB

namespace TwoPhaseCommitB

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
    (state : State)
    (participant : Participant)
    (value : Bool) : Option State :=
  if state.decision = .collecting /\ state.votes participant = none then
    some
      { state with
        votes := fun current =>
          if current = participant then some value else state.votes current }
  else
    none

def decideCommit (state : State) : Option State :=
  if state.decision = .collecting /\
      state.votes .first = some true /\
      state.votes .second = some true then
    some { state with decision := .commit }
  else
    none

def decideAbort (state : State) : Option State :=
  if state.decision = .collecting /\
      (state.votes .first = some false \/
        state.votes .second = some false) then
    some { state with decision := .abort }
  else
    none

def acknowledge
    (state : State)
    (participant : Participant) : Option State :=
  if state.decision != .collecting /\
      state.acknowledged participant = false then
    some
      { state with
        acknowledged := fun current =>
          if current = participant then true else state.acknowledged current }
  else
    none

def next (state : State) : Action -> Option State
  | .vote participant value => recordVote state participant value
  | .decideCommit => decideCommit state
  | .decideAbort => decideAbort state
  | .acknowledge participant => acknowledge state participant

def completed (state : State) : Prop :=
  state.decision != .collecting /\
    state.acknowledged .first = true /\
    state.acknowledged .second = true

def system : TransitionSystemB where
  State := State
  Action := Action
  initial := initial
  next := next

end TwoPhaseCommitB
