import TransitionSystems.TransitionSystemB

structure ModelCheckingSystem where
  system : TransitionSystemB
  initialState : system.State
  initial : system.initial initialState
  actions : List system.Action
  sameState : system.State -> system.State -> Bool
  invariant : system.State -> Bool

structure ModelCheckingStep (Action State : Type) where
  action : Action
  state : State

structure ModelCheckingTrace (Action State : Type) where
  initialState : State
  steps : List (ModelCheckingStep Action State)

inductive ModelCheckingResult (Action State : Type) where
  | safe (statesChecked : Nat)
  | invariantViolation (trace : ModelCheckingTrace Action State)
deriving Nonempty

namespace ModelCheckingSystem

private structure PendingState (Action State : Type) where
  state : State
  steps : List (ModelCheckingStep Action State)

private def containsState
    (config : ModelCheckingSystem)
    (visited : List config.system.State)
    (state : config.system.State) : Bool :=
  visited.any fun candidate => config.sameState candidate state

private def addSuccessors
    (config : ModelCheckingSystem)
    (source : PendingState config.system.Action config.system.State)
    (actions : List config.system.Action)
    (queue :
      List (PendingState config.system.Action config.system.State))
    (visited : List config.system.State) :
    List (PendingState config.system.Action config.system.State) ×
      List config.system.State :=
  match actions with
  | [] => (queue, visited)
  | action :: rest =>
      match config.system.next source.state action with
      | none => addSuccessors config source rest queue visited
      | some nextState =>
          if config.containsState visited nextState then
            addSuccessors config source rest queue visited
          else
            let next := {
              state := nextState
              steps := source.steps ++ [{ action := action, state := nextState }]
            }
            addSuccessors config source rest (queue ++ [next])
              (nextState :: visited)

private partial def checkQueue
    (config : ModelCheckingSystem)
    (queue :
      List (PendingState config.system.Action config.system.State))
    (visited : List config.system.State) :
    ModelCheckingResult config.system.Action config.system.State :=
  match queue with
  | [] => .safe visited.length
  | current :: rest =>
      if config.invariant current.state then
        let (nextQueue, nextVisited) :=
          config.addSuccessors current config.actions rest visited
        config.checkQueue nextQueue nextVisited
      else
        .invariantViolation {
          initialState := config.initialState
          steps := current.steps
        }

def check
    (config : ModelCheckingSystem) :
    ModelCheckingResult config.system.Action config.system.State :=
  config.checkQueue
    [{ state := config.initialState, steps := [] }]
    [config.initialState]

end ModelCheckingSystem
