---- MODULE SafeCounter ----
EXTENDS Naturals

CONSTANT ThreadCount

ASSUME ThreadCount \in Nat \ {0}

Threads == 1..ThreadCount
ThreadStates == {"notStarted", "locked", "read", "written", "done"}
NoThread == 0

VARIABLES counter, lockOwner, phase, observed

vars == <<counter, lockOwner, phase, observed>>

Init ==
    /\ counter = 0
    /\ lockOwner = NoThread
    /\ phase = [thread \in Threads |-> "notStarted"]
    /\ observed = [thread \in Threads |-> 0]

Acquire(thread) ==
    /\ thread \in Threads
    /\ lockOwner = NoThread
    /\ phase[thread] = "notStarted"
    /\ lockOwner' = thread
    /\ phase' = [phase EXCEPT ![thread] = "locked"]
    /\ UNCHANGED <<counter, observed>>

Read(thread) ==
    /\ lockOwner = thread
    /\ phase[thread] = "locked"
    /\ phase' = [phase EXCEPT ![thread] = "read"]
    /\ observed' = [observed EXCEPT ![thread] = counter]
    /\ UNCHANGED <<counter, lockOwner>>

Write(thread) ==
    /\ lockOwner = thread
    /\ phase[thread] = "read"
    /\ counter' = observed[thread] + 1
    /\ phase' = [phase EXCEPT ![thread] = "written"]
    /\ UNCHANGED <<lockOwner, observed>>

Release(thread) ==
    /\ lockOwner = thread
    /\ phase[thread] = "written"
    /\ lockOwner' = NoThread
    /\ phase' = [phase EXCEPT ![thread] = "done"]
    /\ UNCHANGED <<counter, observed>>

Next ==
    \/ \E thread \in Threads: Acquire(thread)
    \/ \E thread \in Threads: Read(thread)
    \/ \E thread \in Threads: Write(thread)
    \/ \E thread \in Threads: Release(thread)

TypeOK ==
    /\ counter \in 0..ThreadCount
    /\ lockOwner \in {NoThread} \cup Threads
    /\ phase \in [Threads -> ThreadStates]
    /\ observed \in [Threads -> 0..ThreadCount]

Completed ==
    \A thread \in Threads:
        phase[thread] = "done"

NoLostUpdates ==
    Completed => counter = ThreadCount

Spec == Init /\ [][Next]_vars

====
