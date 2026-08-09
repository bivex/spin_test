/*
 * Peterson's Mutual Exclusion Algorithm in Promela
 * 
 * Demonstrates SPIN model checking:
 * 1. Mutual Exclusion: At most one process in critical section.
 * 2. Freedom from Deadlock / Starvation.
 */

bool flag[2] = false;
byte turn = 0;
byte critical_count = 0;

proctype Worker(byte id) {
    byte other = 1 - id;

    do
    :: true ->
        /* Non-critical section */
        printf("Process %d in non-critical section\n", id);

        /* Want to enter critical section */
want:   flag[id] = true;
        turn = id;

        /* Wait until it's safe to enter */
        (flag[other] == false || turn == other);

        /* Critical section */
in_crit:
        critical_count++;
        printf("Process %d ENTERED critical section (active count: %d)\n", id, critical_count);

        /* Safety Assertion: Mutual Exclusion check */
        assert(critical_count <= 1);

        /* Simulating work in critical section */
        skip;

        critical_count--;
        printf("Process %d EXITED critical section\n", id);

        /* Exit critical section */
        flag[id] = false;
    od
}

init {
    atomic {
        run Worker(0);
        run Worker(1);
    }
}

/* LTL Formulas for Verification */
/* Property 1: Safety - Mutual exclusion always holds */
ltl mutex { [] (critical_count <= 1) }

/* Property 2: Liveness - If P(0) wants to enter, it will eventually enter */
ltl liveness0 { [] (Worker[1]@want -> <> Worker[1]@in_crit) }
