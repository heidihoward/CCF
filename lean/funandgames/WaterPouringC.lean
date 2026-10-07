import funandgames.TransitionSystemC

namespace WaterPouringC

structure State where
  three : Nat
  five : Nat
deriving DecidableEq

inductive Action where
  | fillThree
  | fillFive
  | emptyThree
  | emptyFive
  | pourThreeToFive
  | pourFiveToThree

def initial (state : State) : Prop :=
  state.three = 0 /\ state.five = 0

def fillThree (state : State) : Finset State :=
  if state.three < 3 then
    {{ state with three := 3 }}
  else
    {}

def fillFive (state : State) : Finset State :=
  if state.five < 5 then
    {{ state with five := 5 }}
  else
    {}

def emptyThree (state : State) : Finset State :=
  if state.three > 0 then
    {{ state with three := 0 }}
  else
    {}

def emptyFive (state : State) : Finset State :=
  if state.five > 0 then
    {{ state with five := 0 }}
  else
    {}

def pourThreeToFive (state : State) : Finset State :=
  if state.three > 0 && state.five < 5 then
    let amount := min state.three (5 - state.five)
    {{
      three := state.three - amount
      five := state.five + amount
    }}
  else
    {}

def pourFiveToThree (state : State) : Finset State :=
  if state.five > 0 && state.three < 3 then
    let amount := min state.five (3 - state.three)
    {{
      three := state.three + amount
      five := state.five - amount
    }}
  else
    {}

def next (state : State) : Action -> Finset State
  | .fillThree => fillThree state
  | .fillFive => fillFive state
  | .emptyThree => emptyThree state
  | .emptyFive => emptyFive state
  | .pourThreeToFive => pourThreeToFive state
  | .pourFiveToThree => pourFiveToThree state

def goal (state : State) : Prop :=
  state.five = 4

def system : TransitionSystemC where
  State := State
  Action := Action
  initial := initial
  next := next

end WaterPouringC
