import funandgames.TransitionSystemB

namespace CounterB

structure State where
  first : Nat
  second : Nat

inductive Action where
  | incrementByOne
  | incrementByTen
  | incrementSecondByOne
  | incrementSecondByTen
  | reset

def initial (state : State) : Prop :=
  state.first = 0 /\ state.second = 0

def incrementByOne (state : State) : Option State :=
  if state.first <= 20 then
    some { state with first := state.first + 1 }
  else
    none

def incrementByTen (state : State) : Option State :=
  if state.first <= 20 then
    some { state with first := state.first + 10 }
  else
    none

def incrementSecondByOne (state : State) : Option State :=
  if state.second <= 20 then
    some { state with second := state.second + 1 }
  else
    none

def incrementSecondByTen (state : State) : Option State :=
  if state.second <= 20 then
    some { state with second := state.second + 10 }
  else
    none

def reset (state : State) : Option State :=
  if state.first > 20 then some { state with first := 0 } else none

def next (state : State) : Action -> Option State
  | .incrementByOne => incrementByOne state
  | .incrementByTen => incrementByTen state
  | .incrementSecondByOne => incrementSecondByOne state
  | .incrementSecondByTen => incrementSecondByTen state
  | .reset => reset state

def system : TransitionSystemB where
  State := State
  Action := Action
  initial := initial
  next := next

end CounterB
