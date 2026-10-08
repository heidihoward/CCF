import Mathlib.Data.Fintype.Pi
import TransitionSystems.TransitionSystemC

namespace TwoPhaseCommitC

inductive Participant where
  | first
  | second
deriving DecidableEq

instance : Fintype Participant where
  elems := {.first, .second}
  complete participant := by cases participant <;> simp

inductive Decision where
  | collecting
  | commit
  | abort
deriving DecidableEq

structure State where
  votes : Participant -> Option Bool
  decision : Decision
  acknowledged : Participant -> Bool
deriving DecidableEq

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
    (value : Bool) : Finset State :=
  if state.decision = .collecting /\ state.votes participant = none then
    {{
      state with
      votes := fun current =>
        if current = participant then some value else state.votes current
    }}
  else
    {}

def decideCommit (state : State) : Finset State :=
  if state.decision = .collecting /\
      state.votes .first = some true /\
      state.votes .second = some true then
    {{ state with decision := .commit }}
  else
    {}

def decideAbort (state : State) : Finset State :=
  if state.decision = .collecting /\
      (state.votes .first = some false \/
        state.votes .second = some false) then
    {{ state with decision := .abort }}
  else
    {}

def acknowledge
    (state : State)
    (participant : Participant) : Finset State :=
  if state.decision != .collecting /\
      state.acknowledged participant = false then
    {{
      state with
      acknowledged := fun current =>
        if current = participant then true else state.acknowledged current
    }}
  else
    {}

def next (state : State) : Action -> Finset State
  | .vote participant value => recordVote state participant value
  | .decideCommit => decideCommit state
  | .decideAbort => decideAbort state
  | .acknowledge participant => acknowledge state participant

def completed (state : State) : Prop :=
  state.decision != .collecting /\
    state.acknowledged .first = true /\
    state.acknowledged .second = true

def system : TransitionSystemC where
  State := State
  Action := Action
  initial := initial
  next := next

end TwoPhaseCommitC
