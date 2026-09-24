structure TransitionSystemA where
  State : Type
  Action : Type
  initial : State -> Prop
  next : State -> Action -> State -> Prop

inductive TransitionSystemA.Reachable
    (system : TransitionSystemA) : system.State -> Prop where
  | initial
      {state : system.State}
      (initial : system.initial state) :
      system.Reachable state
  | step
      {before after : system.State}
      {action : system.Action}
      (reachable : system.Reachable before)
      (transition : system.next before action after) :
      system.Reachable after

def TransitionSystemA.reachableInN
    (system : TransitionSystemA) :
    Nat -> system.State -> Prop
  | 0, state => system.initial state
  | n + 1, state =>
      system.reachableInN n state \/
        exists before action,
          system.reachableInN n before /\
            system.next before action state
