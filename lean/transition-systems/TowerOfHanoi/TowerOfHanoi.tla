---- MODULE TowerOfHanoi ----
EXTENDS Naturals

CONSTANTS DiskCount, Left, Middle, Right

ASSUME DiskCount \in Nat \ {0}

Pegs == {Left, Middle, Right}
Disks == 1..DiskCount

VARIABLE peg

vars == <<peg>>

Init ==
    peg = [disk \in Disks |-> Left]

LegalMove(disk, target) ==
    /\ target \in Pegs
    /\ target # peg[disk]
    /\ \A smaller \in Disks:
        smaller < disk =>
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
