import TransitionSystems.TransitionSystemA

namespace UnsafeCounterA

inductive Phase where
  | notStarted
  | read
  | done
deriving DecidableEq

/- Each thread keeps its phase and last observed counter value separately.
   Another thread may update the counter between the read and write phases. -/
structure ThreadState where
  phase : Phase
  observed : Nat
deriving DecidableEq

structure State (n : Nat) where
  counter : Nat
  threads : Fin n -> ThreadState

inductive Action (n : Nat) where
  | read (thread : Fin n)
  | write (thread : Fin n)

def initial {n : Nat} (state : State n) : Prop :=
  state.counter = 0 /\
    forall thread,
      state.threads thread = { phase := .notStarted, observed := 0 }

def read
    {n : Nat}
    (before : State n)
    (thread : Fin n)
    (after : State n) : Prop :=
  (before.threads thread).phase = .notStarted /\
    after =
      { before with
        threads := fun current =>
          if current = thread then
            { phase := .read, observed := before.counter }
          else
            before.threads current }

def write
    {n : Nat}
    (before : State n)
    (thread : Fin n)
    (after : State n) : Prop :=
  (before.threads thread).phase = .read /\
    after =
      { counter := (before.threads thread).observed + 1
        threads := fun current =>
          if current = thread then
            { before.threads current with phase := .done }
          else
            before.threads current }

def next
    {n : Nat}
    (before : State n)
    (action : Action n)
    (after : State n) : Prop :=
  match action with
  | .read thread => read before thread after
  | .write thread => write before thread after

def completed {n : Nat} (state : State n) : Prop :=
  forall thread, (state.threads thread).phase = .done

def noLostUpdates {n : Nat} (state : State n) : Prop :=
  -- This is intentionally false for some reachable completed states.
  completed state -> state.counter = n

def system (n : Nat) : TransitionSystemA where
  State := State n
  Action := Action n
  initial := initial
  next := next

end UnsafeCounterA
