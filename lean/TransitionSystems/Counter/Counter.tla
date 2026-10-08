---- MODULE Counter ----
EXTENDS Naturals

VARIABLES first, second

vars == <<first, second>>

Init ==
    /\ first = 0
    /\ second = 0

IncrementByOne ==
    /\ first <= 20
    /\ first' = first + 1
    /\ UNCHANGED second

IncrementByTen ==
    /\ first <= 20
    /\ first' = first + 10
    /\ UNCHANGED second

IncrementSecondByOne ==
    /\ second <= 20
    /\ second' = second + 1
    /\ UNCHANGED first

IncrementSecondByTen ==
    /\ second <= 20
    /\ second' = second + 10
    /\ UNCHANGED first

Reset ==
    /\ first > 20
    /\ first' = 0
    /\ UNCHANGED second

Next ==
    \/ IncrementByOne
    \/ IncrementByTen
    \/ IncrementSecondByOne
    \/ IncrementSecondByTen
    \/ Reset

TypeOK ==
    /\ first \in Nat
    /\ second \in Nat

Spec == Init /\ [][Next]_vars

====
