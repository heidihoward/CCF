import «transition-systems».TransitionSystemB

structure InteractiveSystem where
  system : TransitionSystemB
  initialState : system.State
  initial : system.initial initialState
  actions : List system.Action
  showState : system.State -> String
  showAction : system.Action -> String
  isGoal : system.State -> Bool := fun _ => false

namespace InteractiveSystem

def enabledActions
    (config : InteractiveSystem)
    (state : config.system.State) :
    List (config.system.Action × config.system.State) :=
  config.actions.filterMap fun action =>
    (config.system.next state action).map fun nextState =>
      (action, nextState)

private def printActions
    {Action State : Type}
    (showAction : Action -> String) :
    Nat -> List (Action × State) -> IO Unit
  | _, [] => pure ()
  | index, (action, _) :: rest => do
      IO.println s!"{index}: {showAction action}"
      printActions showAction (index + 1) rest

partial def runFrom
    (config : InteractiveSystem)
    (state : config.system.State) : IO Unit := do
  IO.println ""
  IO.println s!"State: {config.showState state}"
  if config.isGoal state then
    IO.println "Goal reached."
  else
    let enabled := config.enabledActions state
    if enabled.isEmpty then
      IO.println "No actions are enabled."
    else
      IO.println "Choose an action:"
      printActions config.showAction 0 enabled
      IO.println "q: quit"
      IO.print "> "
      let input := (← (← IO.getStdin).getLine).trimAscii.toString
      if input == "q" then
        pure ()
      else
        match input.toNat? with
        | none =>
            IO.println "Enter an action number or q."
            config.runFrom state
        | some index =>
            match enabled[index]? with
            | none =>
                IO.println "That action number is not available."
                config.runFrom state
            | some (_, nextState) =>
                config.runFrom nextState

def run (config : InteractiveSystem) : IO Unit :=
  config.runFrom config.initialState

end InteractiveSystem
