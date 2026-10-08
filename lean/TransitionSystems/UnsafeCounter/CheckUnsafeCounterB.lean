import TransitionSystems.TransitionSystemModelChecker
import TransitionSystems.UnsafeCounter.UnsafeCounterB

namespace CheckUnsafeCounterB

open UnsafeCounterB

abbrev ThreadCount := 3

def initialState : State ThreadCount where
  counter := 0
  threads := fun _ => { phase := .notStarted, observed := 0 }

def actions : List (Action ThreadCount) := [
  .read 0,
  .write 0,
  .read 1,
  .write 1,
  .read 2,
  .write 2
]

def sameState
    (left right : State ThreadCount) : Bool :=
  decide (left.counter = right.counter) &&
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
    simp [UnsafeCounterB.system, UnsafeCounterB.initial, initialState]
  actions := actions
  sameState := sameState
  invariant := noLostUpdates

def showPhase : Phase -> String
  | .notStarted => "not started"
  | .read => "read"
  | .done => "done"

def showThreadState (state : ThreadState) : String :=
  s!"phase={showPhase state.phase}, observed={state.observed}"

def showState (state : State ThreadCount) : String :=
  s!"counter={state.counter}, threads=(" ++
    s!"{showThreadState (state.threads 0)}, " ++
    s!"{showThreadState (state.threads 1)}, " ++
    s!"{showThreadState (state.threads 2)})"

def showAction : Action ThreadCount -> String
  | .read thread => s!"thread {thread.val} reads"
  | .write thread => s!"thread {thread.val} writes"

def printSteps :
    Nat ->
      List (ModelCheckingStep (Action ThreadCount) (State ThreadCount)) ->
      IO Unit
  | _, [] => pure ()
  | index, step :: rest => do
      IO.println s!"Action {index}: {showAction step.action}"
      IO.println s!"State {index}: {showState step.state}"
      printSteps (index + 1) rest

def main : IO UInt32 := do
  match config.check with
  | .safe statesChecked =>
      IO.eprintln
        s!"No lost update found in {statesChecked} reachable states."
      pure 1
  | .invariantViolation trace =>
      -- Finding this counterexample is the expected result for the unsafe model.
      IO.println
        s!"Lost update found after {trace.steps.length} transitions."
      IO.println s!"State 0: {showState trace.initialState}"
      printSteps 1 trace.steps
      pure 0

end CheckUnsafeCounterB

def main : IO UInt32 :=
  CheckUnsafeCounterB.main
