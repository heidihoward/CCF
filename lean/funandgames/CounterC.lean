import funandgames.TransitionSystemC

namespace CounterC

structure State where
  first : Nat
  second : Nat
deriving DecidableEq

inductive Action where
  | incrementByOne
  | incrementByTen
  | incrementSecondByOne
  | incrementSecondByTen
  | reset

def initial (state : State) : Prop :=
  state.first = 0 /\ state.second = 0

def incrementByOne (state : State) : Finset State :=
  if state.first <= 20 then
    {{ state with first := state.first + 1 }}
  else
    {}

def incrementByTen (state : State) : Finset State :=
  if state.first <= 20 then
    {{ state with first := state.first + 10 }}
  else
    {}

def incrementSecondByOne (state : State) : Finset State :=
  if state.second <= 20 then
    {{ state with second := state.second + 1 }}
  else
    {}

def incrementSecondByTen (state : State) : Finset State :=
  if state.second <= 20 then
    {{ state with second := state.second + 10 }}
  else
    {}

def reset (state : State) : Finset State :=
  if state.first > 20 then {{ state with first := 0 }} else {}

def next (state : State) : Action -> Finset State
  | .incrementByOne => incrementByOne state
  | .incrementByTen => incrementByTen state
  | .incrementSecondByOne => incrementSecondByOne state
  | .incrementSecondByTen => incrementSecondByTen state
  | .reset => reset state

def system : TransitionSystemC where
  State := State
  Action := Action
  initial := initial
  next := next

end CounterC
