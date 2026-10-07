---- MODULE TowerOfHanoi3 ----
EXTENDS Naturals

CONSTANTS Left, Middle, Right, Small, Medium, Large

Pegs == {Left, Middle, Right}
Disks == {Small, Medium, Large}

Rank(disk) ==
    CASE disk = Small -> 1
      [] disk = Medium -> 2
      [] disk = Large -> 3

VARIABLE peg

vars == <<peg>>

Init ==
    peg = [disk \in Disks |-> Left]

LegalMove(disk, target) ==
    /\ target \in Pegs
    /\ target # peg[disk]
    /\ \A smaller \in Disks:
        Rank(smaller) < Rank(disk) =>
            /\ peg[smaller] # peg[disk]
            /\ peg[smaller] # target

MoveDisk(disk, target) ==
    /\ disk \in Disks
    /\ LegalMove(disk, target)
    /\ peg' = [peg EXCEPT ![disk] = target]

Next ==
    \E disk \in Disks, target \in Pegs:
        MoveDisk(disk, target)

TypeOK == peg \in [Disks -> Pegs]

Goal == \A disk \in Disks: peg[disk] = Right

Spec == Init /\ [][Next]_vars

====
