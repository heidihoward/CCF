---- MODULE WaterPouring ----
EXTENDS Naturals

VARIABLES three, five

vars == <<three, five>>

Init ==
    /\ three = 0
    /\ five = 0

FillThree ==
    /\ three < 3
    /\ three' = 3
    /\ UNCHANGED five

FillFive ==
    /\ five < 5
    /\ five' = 5
    /\ UNCHANGED three

EmptyThree ==
    /\ three > 0
    /\ three' = 0
    /\ UNCHANGED five

EmptyFive ==
    /\ five > 0
    /\ five' = 0
    /\ UNCHANGED three

PourThreeToFive ==
    /\ three > 0
    /\ five < 5
    /\ LET amount == IF three < 5 - five THEN three ELSE 5 - five
       IN /\ three' = three - amount
          /\ five' = five + amount

PourFiveToThree ==
    /\ five > 0
    /\ three < 3
    /\ LET amount == IF five < 3 - three THEN five ELSE 3 - three
       IN /\ three' = three + amount
          /\ five' = five - amount

Next ==
    \/ FillThree
    \/ FillFive
    \/ EmptyThree
    \/ EmptyFive
    \/ PourThreeToFive
    \/ PourFiveToThree

TypeOK ==
    /\ three \in 0..3
    /\ five \in 0..5

Goal == five = 4

Spec == Init /\ [][Next]_vars

====
