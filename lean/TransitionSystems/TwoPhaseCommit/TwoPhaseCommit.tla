---- MODULE TwoPhaseCommit ----
CONSTANTS First, Second

Participants == {First, Second}
VoteValues == {"pending", "yes", "no"}
Decisions == {"collecting", "commit", "abort"}

VARIABLES votes, decision, acknowledged

vars == <<votes, decision, acknowledged>>

Init ==
    /\ votes = [participant \in Participants |-> "pending"]
    /\ decision = "collecting"
    /\ acknowledged = {}

Vote(participant, value) ==
    /\ participant \in Participants
    /\ value \in {"yes", "no"}
    /\ decision = "collecting"
    /\ votes[participant] = "pending"
    /\ votes' = [votes EXCEPT ![participant] = value]
    /\ UNCHANGED <<decision, acknowledged>>

DecideCommit ==
    /\ decision = "collecting"
    /\ \A participant \in Participants:
        votes[participant] = "yes"
    /\ decision' = "commit"
    /\ UNCHANGED <<votes, acknowledged>>

DecideAbort ==
    /\ decision = "collecting"
    /\ \E participant \in Participants:
        votes[participant] = "no"
    /\ decision' = "abort"
    /\ UNCHANGED <<votes, acknowledged>>

Acknowledge(participant) ==
    /\ participant \in Participants
    /\ decision # "collecting"
    /\ participant \notin acknowledged
    /\ acknowledged' = acknowledged \cup {participant}
    /\ UNCHANGED <<votes, decision>>

Next ==
    \/ \E participant \in Participants, value \in {"yes", "no"}:
        Vote(participant, value)
    \/ DecideCommit
    \/ DecideAbort
    \/ \E participant \in Participants:
        Acknowledge(participant)

TypeOK ==
    /\ votes \in [Participants -> VoteValues]
    /\ decision \in Decisions
    /\ acknowledged \subseteq Participants

CommitOnlyAfterYes ==
    decision = "commit" =>
        \A participant \in Participants:
            votes[participant] = "yes"

AbortOnlyAfterNo ==
    decision = "abort" =>
        \E participant \in Participants:
            votes[participant] = "no"

Completed ==
    /\ decision # "collecting"
    /\ acknowledged = Participants

Spec == Init /\ [][Next]_vars

====
