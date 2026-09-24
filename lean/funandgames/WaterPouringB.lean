import funandgames.TransitionSystemB

namespace WaterPouringB

structure State where
  three : Nat
  five : Nat

inductive Action where
  | fillThree
  | fillFive
  | emptyThree
  | emptyFive
  | pourThreeToFive
  | pourFiveToThree

def initial (state : State) : Prop :=
  state.three = 0 /\ state.five = 0

def fillThree (state : State) : Option State :=
  if state.three < 3 then
    some { state with three := 3 }
  else
    none

def fillFive (state : State) : Option State :=
  if state.five < 5 then
    some { state with five := 5 }
  else
    none

def emptyThree (state : State) : Option State :=
  if state.three > 0 then
    some { state with three := 0 }
  else
    none

def emptyFive (state : State) : Option State :=
  if state.five > 0 then
    some { state with five := 0 }
  else
    none

def pourThreeToFive (state : State) : Option State :=
  if state.three > 0 && state.five < 5 then
    let amount := min state.three (5 - state.five)
    some {
      three := state.three - amount
      five := state.five + amount
    }
  else
    none

def pourFiveToThree (state : State) : Option State :=
  if state.five > 0 && state.three < 3 then
    let amount := min state.five (3 - state.three)
    some {
      three := state.three + amount
      five := state.five - amount
    }
  else
    none

def next (state : State) : Action -> Option State
  | .fillThree => fillThree state
  | .fillFive => fillFive state
  | .emptyThree => emptyThree state
  | .emptyFive => emptyFive state
  | .pourThreeToFive => pourThreeToFive state
  | .pourFiveToThree => pourFiveToThree state

def goal (state : State) : Prop :=
  state.five = 4

def system : TransitionSystemB where
  State := State
  Action := Action
  initial := initial
  next := next

end WaterPouringB
