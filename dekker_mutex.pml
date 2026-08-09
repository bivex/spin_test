/*
 * Dekker's Algorithm for Mutual Exclusion in Promela
 * Historical first software-based solution for mutual exclusion between 2 processes.
 */

bool want[2] = false;
byte turn = 0;
byte in_critical = 0;

proctype Process(byte id) {
    byte other = 1 - id;

    do
    :: true ->
        want[id] = true;

        do
        :: want[other] ->
            if
            :: turn != id ->
                want[id] = false;
                (turn == id);
                want[id] = true;
            :: else -> skip;
            fi
        :: else -> break;
        od;

        /* Critical Section */
critical:
        in_critical++;
        printf("Process %d inside critical section (count=%d)\n", id, in_critical);

        /* Safety Property check */
        assert(in_critical <= 1);

        in_critical--;

        /* Release */
        turn = other;
        want[id] = false;
    od
}

init {
    atomic {
        run Process(0);
        run Process(1);
    }
}

/* LTL Verification Property: Mutual Exclusion */
ltl dekker_mutex { [] (in_critical <= 1) }
