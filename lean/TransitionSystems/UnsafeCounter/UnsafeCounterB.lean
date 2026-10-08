import TransitionSystems.TransitionSystemB

namespace UnsafeCounterB

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
    (state : State n)
    (thread : Fin n) : Option (State n) :=
  if (state.threads thread).phase = .notStarted then
    some
      { state with
        threads := fun current =>
          if current = thread then
            { phase := .read, observed := state.counter }
          else
            state.threads current }
  else
    none

def write
    {n : Nat}
    (state : State n)
    (thread : Fin n) : Option (State n) :=
  if (state.threads thread).phase = .read then
      some
        { counter := (state.threads thread).observed + 1
          threads := fun current =>
            if current = thread then
              { state.threads current with phase := .done }
            else
              state.threads current }
  else
    none

def next {n : Nat} (state : State n) : Action n -> Option (State n)
  | .read thread => read state thread
  | .write thread => write state thread

def completed {n : Nat} (state : State n) : Prop :=
  forall thread, (state.threads thread).phase = .done

def noLostUpdates {n : Nat} (state : State n) : Prop :=
  -- This is intentionally false for some reachable completed states.
  completed state -> state.counter = n

def system (n : Nat) : TransitionSystemB where
  State := State n
  Action := Action n
  initial := initial
  next := next

end UnsafeCounterB
