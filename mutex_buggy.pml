/*
 * Buggy Mutual Exclusion Algorithm (Intentional Race Condition)
 * 
 * Demonstrates how SPIN finds counterexamples (assertions failures / deadlocks)
 * and generates a .trail file to trace the bug.
 */

bool flag[2] = false;
byte critical_count = 0;

proctype BuggyWorker(byte id) {
    byte other = 1 - id;

    do
    :: true ->
want:   
        /* BUG: Process sets flag, but does NOT set 'turn' or wait properly! */
        flag[id] = true;

        /* Flawed wait condition: only checks other's flag, creating a race condition */
        (flag[other] == false);

in_crit:
        critical_count++;
        printf("Process %d ENTERED critical section (count: %d)\n", id, critical_count);

        /* ASSERTION FAILURE: Both processes enter critical section simultaneously! */
        assert(critical_count <= 1);

        critical_count--;
        flag[id] = false;
    od
}

init {
    atomic {
        run BuggyWorker(0);
        run BuggyWorker(1);
    }
}
