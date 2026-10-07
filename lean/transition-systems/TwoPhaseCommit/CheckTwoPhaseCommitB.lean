import «transition-systems».TransitionSystemModelChecker
import «transition-systems».TwoPhaseCommit.TwoPhaseCommitB

namespace CheckTwoPhaseCommitB

open TwoPhaseCommitB

def initialState : State where
  votes := fun _ => none
  decision := .collecting
  acknowledged := fun _ => false

def actions : List Action := [
  .vote .first false,
  .vote .first true,
  .vote .second false,
  .vote .second true,
  .decideCommit,
  .decideAbort,
  .acknowledge .first,
  .acknowledge .second
]

def sameState (left right : State) : Bool :=
  decide (left.votes .first = right.votes .first) &&
    decide (left.votes .second = right.votes .second) &&
    decide (left.decision = right.decision) &&
    decide (left.acknowledged .first = right.acknowledged .first) &&
    decide (left.acknowledged .second = right.acknowledged .second)

def decisionSafe (state : State) : Bool :=
  match state.decision with
  | .collecting => true
  | .commit =>
      decide (state.votes .first = some true) &&
        decide (state.votes .second = some true)
  | .abort =>
      decide (state.votes .first = some false) ||
        decide (state.votes .second = some false)

def noCommit (state : State) : Bool :=
  decide (Not (state.decision = .commit))

def configFor (invariant : State -> Bool) : ModelCheckingSystem where
  system := system
  initialState := initialState
  initial := by
    simp [TwoPhaseCommitB.system, TwoPhaseCommitB.initial, initialState]
  actions := actions
  sameState := sameState
  invariant := invariant

def config : ModelCheckingSystem :=
  configFor decisionSafe

def showVote : Option Bool -> String
  | none => "pending"
  | some true => "yes"
  | some false => "no"

def showDecision : Decision -> String
  | .collecting => "collecting"
  | .commit => "commit"
  | .abort => "abort"

def showState (state : State) : String :=
  s!"votes=({showVote (state.votes .first)}, " ++
    s!"{showVote (state.votes .second)}), " ++
    s!"decision={showDecision state.decision}, " ++
    s!"acknowledged=({state.acknowledged .first}, " ++
    s!"{state.acknowledged .second})"

def showParticipant : Participant -> String
  | .first => "first"
  | .second => "second"

def showAction : Action -> String
  | .vote participant value =>
      s!"{showParticipant participant} votes {if value then "yes" else "no"}"
  | .decideCommit => "coordinator commits"
  | .decideAbort => "coordinator aborts"
  | .acknowledge participant =>
      s!"{showParticipant participant} acknowledges"

def printSteps :
    Nat -> List (ModelCheckingStep Action State) -> IO Unit
  | _, [] => pure ()
  | index, step :: rest => do
      IO.println s!"Action {index}: {showAction step.action}"
      IO.println s!"State {index}: {showState step.state}"
      printSteps (index + 1) rest

def printTrace (trace : ModelCheckingTrace Action State) : IO Unit := do
  IO.println s!"State 0: {showState trace.initialState}"
  printSteps 1 trace.steps

def runCheck (invariant : State -> Bool) : IO UInt32 := do
  match (configFor invariant).check with
  | .safe statesChecked =>
      IO.println s!"Invariant holds in all {statesChecked} reachable states."
      pure 0
  | .invariantViolation trace =>
      IO.println
        s!"Invariant violation after {trace.steps.length} transition(s)."
      printTrace trace
      pure 1

def run (arguments : List String) : IO UInt32 :=
  if arguments.contains "--demo-counterexample" then
    runCheck noCommit
  else
    runCheck decisionSafe

end CheckTwoPhaseCommitB

def main (arguments : List String) : IO UInt32 :=
  CheckTwoPhaseCommitB.run arguments
