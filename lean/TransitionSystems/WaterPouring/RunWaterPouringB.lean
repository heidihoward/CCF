import TransitionSystems.TransitionSystemRunner
import TransitionSystems.WaterPouring.WaterPouringB

namespace RunWaterPouringB

open WaterPouringB

def actions : List Action :=
  [
    .fillThree,
    .fillFive,
    .emptyThree,
    .emptyFive,
    .pourThreeToFive,
    .pourFiveToThree
  ]

def showState (state : State) : String :=
  s!"3-litre jug: {state.three}/3, 5-litre jug: {state.five}/5"

def showAction : Action -> String
  | .fillThree => "Fill the 3-litre jug"
  | .fillFive => "Fill the 5-litre jug"
  | .emptyThree => "Empty the 3-litre jug"
  | .emptyFive => "Empty the 5-litre jug"
  | .pourThreeToFive => "Pour the 3-litre jug into the 5-litre jug"
  | .pourFiveToThree => "Pour the 5-litre jug into the 3-litre jug"

def initialState : State :=
  { three := 0, five := 0 }

def interactive : InteractiveSystem where
  system := WaterPouringB.system
  initialState := RunWaterPouringB.initialState
  initial := ⟨rfl, rfl⟩
  actions := actions
  showState := showState
  showAction := showAction
  isGoal state := state.five == 4

end RunWaterPouringB

def main : IO Unit :=
  RunWaterPouringB.interactive.run
