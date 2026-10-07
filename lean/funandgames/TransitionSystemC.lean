import Mathlib.Data.Finset.Basic

structure TransitionSystemC where
  State : Type
  Action : Type
  [stateDecidableEq : DecidableEq State]
  initial : State -> Prop
  next : State -> Action -> Finset State

inductive TransitionSystemC.Reachable
    (system : TransitionSystemC) : system.State -> Prop where
  | initial
      {state : system.State}
      (initial : system.initial state) :
      system.Reachable state
  | step
      {before after : system.State}
      {action : system.Action}
      (reachable : system.Reachable before)
      (transition : after ∈ system.next before action) :
      system.Reachable after

def TransitionSystemC.reachableInN
    (system : TransitionSystemC) :
    Nat -> system.State -> Prop
  | 0, state => system.initial state
  | n + 1, state =>
      system.reachableInN n state \/
        exists before action,
          system.reachableInN n before /\
            state ∈ system.next before action
