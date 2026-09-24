import funandgames.TransitionSystemA

namespace CounterA

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

def incrementByOne (before after : State) : Prop :=
  before.first <= 20 /\
    after.first = before.first + 1 /\
    after.second = before.second

def incrementByTen (before after : State) : Prop :=
  before.first <= 20 /\
    after.first = before.first + 10 /\
    after.second = before.second

def incrementSecondByOne (before after : State) : Prop :=
  before.second <= 20 /\
    after.first = before.first /\
    after.second = before.second + 1

def incrementSecondByTen (before after : State) : Prop :=
  before.second <= 20 /\
    after.first = before.first /\
    after.second = before.second + 10

def reset (before after : State) : Prop :=
  before.first > 20 /\
    after.first = 0 /\
    after.second = before.second

def next (before : State) (action : Action) (after : State) : Prop :=
  match action with
  | .incrementByOne => incrementByOne before after
  | .incrementByTen => incrementByTen before after
  | .incrementSecondByOne => incrementSecondByOne before after
  | .incrementSecondByTen => incrementSecondByTen before after
  | .reset => reset before after

def system : TransitionSystemA where
  State := State
  Action := Action
  initial := initial
  next := next

end CounterA
