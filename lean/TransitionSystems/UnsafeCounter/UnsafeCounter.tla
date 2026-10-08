---- MODULE UnsafeCounter ----
EXTENDS Naturals

CONSTANT ThreadCount

ASSUME ThreadCount \in Nat \ {0}

Threads == 1..ThreadCount
ThreadStates == {"notStarted", "read", "done"}

VARIABLES counter, phase, observed

vars == <<counter, phase, observed>>

Init ==
    /\ counter = 0
    /\ phase = [thread \in Threads |-> "notStarted"]
    /\ observed = [thread \in Threads |-> 0]

Read(thread) ==
    \* Save the value that this thread will later increment.
    /\ thread \in Threads
    /\ phase[thread] = "notStarted"
    /\ phase' = [phase EXCEPT ![thread] = "read"]
    /\ observed' = [observed EXCEPT ![thread] = counter]
    /\ UNCHANGED counter

Write(thread) ==
    \* A stale observed value can overwrite another thread's increment.
    /\ thread \in Threads
    /\ phase[thread] = "read"
    /\ counter' = observed[thread] + 1
    /\ phase' = [phase EXCEPT ![thread] = "done"]
    /\ UNCHANGED observed

Next ==
    \/ \E thread \in Threads: Read(thread)
    \/ \E thread \in Threads: Write(thread)

TypeOK ==
    /\ counter \in 0..ThreadCount
    /\ phase \in [Threads -> ThreadStates]
    /\ observed \in [Threads -> 0..ThreadCount]

Completed ==
    \A thread \in Threads:
        phase[thread] = "done"

NoLostUpdates ==
    \* This deliberately fails when concurrent reads lead to lost writes.
    Completed => counter = ThreadCount

Spec == Init /\ [][Next]_vars

====
