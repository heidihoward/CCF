import TransitionSystems.SafeCounter.SafeCounterB
import TransitionSystems.TransitionSystemModelChecker

namespace CheckSafeCounterB

open SafeCounterB

abbrev ThreadCount := 3

def initialState : State ThreadCount where
  counter := 0
  lockOwner := none
  threads := fun _ => { phase := .notStarted, observed := 0 }

def actionsFor (thread : Fin ThreadCount) : List (Action ThreadCount) := [
  .acquire thread,
  .read thread,
  .write thread,
  .release thread
]

def actions : List (Action ThreadCount) :=
  actionsFor 0 ++ actionsFor 1 ++ actionsFor 2

def sameState
    (left right : State ThreadCount) : Bool :=
  decide (left.counter = right.counter) &&
    decide (left.lockOwner = right.lockOwner) &&
    decide (left.threads 0 = right.threads 0) &&
    decide (left.threads 1 = right.threads 1) &&
    decide (left.threads 2 = right.threads 2)

def noLostUpdates (state : State ThreadCount) : Bool :=
  let allDone :=
    decide ((state.threads 0).phase = .done) &&
      decide ((state.threads 1).phase = .done) &&
      decide ((state.threads 2).phase = .done)
  !allDone || decide (state.counter = ThreadCount)

def config : ModelCheckingSystem where
  system := system ThreadCount
  initialState := initialState
  initial := by
    simp [SafeCounterB.system, SafeCounterB.initial, initialState]
  actions := actions
  sameState := sameState
  invariant := noLostUpdates

def main : IO UInt32 := do
  match config.check with
  | .safe statesChecked =>
      IO.println
        s!"No increments lost in any of {statesChecked} reachable states."
      pure 0
  | .invariantViolation trace =>
      IO.eprintln
        s!"Lost update after {trace.steps.length} transitions."
      pure 1

end CheckSafeCounterB

def main : IO UInt32 :=
  CheckSafeCounterB.main
