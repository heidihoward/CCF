import funandgames.TransitionSystemA

namespace WaterPouringA

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

def fillThree (before after : State) : Prop :=
  before.three < 3 /\
    after.three = 3 /\
    after.five = before.five

def fillFive (before after : State) : Prop :=
  before.five < 5 /\
    after.three = before.three /\
    after.five = 5

def emptyThree (before after : State) : Prop :=
  before.three > 0 /\
    after.three = 0 /\
    after.five = before.five

def emptyFive (before after : State) : Prop :=
  before.five > 0 /\
    after.three = before.three /\
    after.five = 0

def pourThreeToFive (before after : State) : Prop :=
  let amount := min before.three (5 - before.five)
  before.three > 0 /\
    before.five < 5 /\
    after.three = before.three - amount /\
    after.five = before.five + amount

def pourFiveToThree (before after : State) : Prop :=
  let amount := min before.five (3 - before.three)
  before.five > 0 /\
    before.three < 3 /\
    after.three = before.three + amount /\
    after.five = before.five - amount

def next (before : State) (action : Action) (after : State) : Prop :=
  match action with
  | .fillThree => fillThree before after
  | .fillFive => fillFive before after
  | .emptyThree => emptyThree before after
  | .emptyFive => emptyFive before after
  | .pourThreeToFive => pourThreeToFive before after
  | .pourFiveToThree => pourFiveToThree before after

def goal (state : State) : Prop :=
  state.five = 4

def system : TransitionSystemA where
  State := State
  Action := Action
  initial := initial
  next := next

end WaterPouringA
