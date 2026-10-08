import TransitionSystems.TransitionSystemB

namespace SafeCounterB

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
    (thread : Fin n) : Option (State n) :=
  if state.lockOwner = none /\
      (state.threads thread).phase = .notStarted then
    some
      { state with
        lockOwner := some thread
        threads := fun current =>
          if current = thread then
            { state.threads current with phase := .locked }
          else
            state.threads current }
  else
    none

def read
    {n : Nat}
    (state : State n)
    (thread : Fin n) : Option (State n) :=
  if state.lockOwner = some thread /\
      (state.threads thread).phase = .locked then
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
  if state.lockOwner = some thread /\
      (state.threads thread).phase = .read then
    some
      { state with
        counter := (state.threads thread).observed + 1
        threads := fun current =>
          if current = thread then
            { state.threads current with phase := .written }
          else
            state.threads current }
  else
    none

def release
    {n : Nat}
    (state : State n)
    (thread : Fin n) : Option (State n) :=
  if state.lockOwner = some thread /\
      (state.threads thread).phase = .written then
    some
      { state with
        lockOwner := none
        threads := fun current =>
          if current = thread then
            { state.threads current with phase := .done }
          else
            state.threads current }
  else
    none

def next {n : Nat} (state : State n) : Action n -> Option (State n)
  | .acquire thread => acquire state thread
  | .read thread => read state thread
  | .write thread => write state thread
  | .release thread => release state thread

def completed {n : Nat} (state : State n) : Prop :=
  forall thread, (state.threads thread).phase = .done

def noLostUpdates {n : Nat} (state : State n) : Prop :=
  completed state -> state.counter = n

def system (n : Nat) : TransitionSystemB where
  State := State n
  Action := Action n
  initial := initial
  next := next

end SafeCounterB
