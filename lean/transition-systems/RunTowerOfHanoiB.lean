import «transition-systems».TowerOfHanoiB
import «transition-systems».TransitionSystemRunner

namespace RunTowerOfHanoiB

open TowerOfHanoiB

def pegs : List Peg :=
  [.left, .middle, .right]

def actions (n : Nat) : List (Action n) :=
  (List.ofFn fun disk : Fin n => disk).flatMap fun disk =>
    pegs.map fun target => .moveDisk disk target

def initialState (n : Nat) : State n :=
  fun _ => .left

def showPeg : Peg -> String
  | .left => "left"
  | .middle => "middle"
  | .right => "right"

def showState {n : Nat} (state : State n) : String :=
  String.intercalate ", " <|
    List.ofFn fun disk : Fin n =>
      s!"disk {disk.val + 1}: {showPeg (state disk)}"

def showAction {n : Nat} : Action n -> String
  | .moveDisk disk target =>
      s!"Move disk {disk.val + 1} to {showPeg target}"

def isGoal {n : Nat} (state : State n) : Bool :=
  (List.ofFn fun disk : Fin n => state disk == .right).all fun atGoal =>
    atGoal

def interactive (n : Nat) : InteractiveSystem where
  system := TowerOfHanoiB.system n
  initialState := initialState n
  initial := by
    intro disk
    rfl
  actions := actions n
  showState := showState
  showAction := showAction
  isGoal := isGoal

end RunTowerOfHanoiB

def main (args : List String) : IO UInt32 := do
  match args with
  | [diskCount] =>
      match diskCount.toNat? with
      | some n =>
          if n = 0 then
            IO.eprintln "The disk count must be greater than zero."
            pure 1
          else
            (RunTowerOfHanoiB.interactive n).run
            pure 0
      | none =>
          IO.eprintln "The disk count must be a natural number."
          pure 1
  | _ =>
      IO.eprintln "Usage: tower-of-hanoi <disk-count>"
      pure 1
