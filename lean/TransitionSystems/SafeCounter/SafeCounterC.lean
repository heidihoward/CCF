import Mathlib.Data.Fintype.Pi
import TransitionSystems.TransitionSystemC

namespace SafeCounterC

inductive Phase where
  | notStarted
  | locked
  | read
  | written
  | done
deriving DecidableEq

structure ThreadState where
  phase : Phase
  observed : Nat
deriving DecidableEq

structure State (n : Nat) where
  counter : Nat
  lockOwner : Option (Fin n)
  threads : Fin n -> ThreadState
deriving DecidableEq

inductive Action (n : Nat) where
  | acquire (thread : Fin n)
  | read (thread : Fin n)
  | write (thread : Fin n)
  | release (thread : Fin n)

def initial {n : Nat} (state : State n) : Prop :=
  state.counter = 0 /\
    state.lockOwner = none /\
    forall thread,
      state.threads thread = { phase := .notStarted, observed := 0 }

def acquire
    {n : Nat}
    (state : State n)
    (thread : Fin n) : Finset (State n) :=
  if state.lockOwner = none /\
      (state.threads thread).phase = .notStarted then
    {{
      state with
      lockOwner := some thread
      threads := fun current =>
        if current = thread then
          { state.threads current with phase := .locked }
        else
          state.threads current
    }}
  else
    {}

def read
    {n : Nat}
    (state : State n)
    (thread : Fin n) : Finset (State n) :=
  if state.lockOwner = some thread /\
      (state.threads thread).phase = .locked then
    {{
      state with
      threads := fun current =>
        if current = thread then
          { phase := .read, observed := state.counter }
        else
          state.threads current
    }}
  else
    {}

def write
    {n : Nat}
    (state : State n)
    (thread : Fin n) : Finset (State n) :=
  if state.lockOwner = some thread /\
      (state.threads thread).phase = .read then
    {{
      state with
      counter := (state.threads thread).observed + 1
      threads := fun current =>
        if current = thread then
          { state.threads current with phase := .written }
        else
          state.threads current
    }}
  else
    {}

def release
    {n : Nat}
    (state : State n)
    (thread : Fin n) : Finset (State n) :=
  if state.lockOwner = some thread /\
      (state.threads thread).phase = .written then
    {{
      state with
      lockOwner := none
      threads := fun current =>
        if current = thread then
          { state.threads current with phase := .done }
        else
          state.threads current
    }}
  else
    {}

def next {n : Nat} (state : State n) : Action n -> Finset (State n)
  | .acquire thread => acquire state thread
  | .read thread => read state thread
  | .write thread => write state thread
  | .release thread => release state thread

def completed {n : Nat} (state : State n) : Prop :=
  forall thread, (state.threads thread).phase = .done

def noLostUpdates {n : Nat} (state : State n) : Prop :=
  completed state -> state.counter = n

def system (n : Nat) : TransitionSystemC where
  State := State n
  Action := Action n
  initial := initial
  next := next

end SafeCounterC
