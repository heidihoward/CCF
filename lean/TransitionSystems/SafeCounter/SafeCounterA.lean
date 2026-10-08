import TransitionSystems.TransitionSystemA

namespace SafeCounterA

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
    (before : State n)
    (thread : Fin n)
    (after : State n) : Prop :=
  before.lockOwner = none /\
    (before.threads thread).phase = .notStarted /\
    after =
      { before with
        lockOwner := some thread
        threads := fun current =>
          if current = thread then
            { before.threads current with phase := .locked }
          else
            before.threads current }

def read
    {n : Nat}
    (before : State n)
    (thread : Fin n)
    (after : State n) : Prop :=
  before.lockOwner = some thread /\
    (before.threads thread).phase = .locked /\
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
  before.lockOwner = some thread /\
    (before.threads thread).phase = .read /\
    after =
      { before with
        counter := (before.threads thread).observed + 1
        threads := fun current =>
          if current = thread then
            { before.threads current with phase := .written }
          else
            before.threads current }

def release
    {n : Nat}
    (before : State n)
    (thread : Fin n)
    (after : State n) : Prop :=
  before.lockOwner = some thread /\
    (before.threads thread).phase = .written /\
    after =
      { before with
        lockOwner := none
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
  | .acquire thread => acquire before thread after
  | .read thread => read before thread after
  | .write thread => write before thread after
  | .release thread => release before thread after

def completed {n : Nat} (state : State n) : Prop :=
  forall thread, (state.threads thread).phase = .done

def noLostUpdates {n : Nat} (state : State n) : Prop :=
  completed state -> state.counter = n

def system (n : Nat) : TransitionSystemA where
  State := State n
  Action := Action n
  initial := initial
  next := next

end SafeCounterA
