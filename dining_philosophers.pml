/*
 * Dining Philosophers Problem in Promela
 * Demonstrates:
 * 1. Resource contention (forks).
 * 2. Asymmetric pick-up strategy to prevent deadlocks.
 * 3. LTL Starvation and Deadlock check.
 */

#define N 5 /* 5 Philosophers */

bool fork[N] = false;
byte eating_count = 0;

proctype Philosopher(byte id) {
    byte left = id;
    byte right = (id + 1) % N;

    do
    :: true ->
        /* Thinking */
        printf("Philosopher %d is thinking\n", id);

hungry:
        printf("Philosopher %d is hungry\n", id);

        /* Asymmetric strategy: even ID picks left then right, odd ID picks right then left */
        if
        :: (id % 2 == 0) ->
            atomic { fork[left] == false -> fork[left] = true; }
            atomic { fork[right] == false -> fork[right] = true; }
        :: (id % 2 != 0) ->
            atomic { fork[right] == false -> fork[right] = true; }
            atomic { fork[left] == false -> fork[left] = true; }
        fi;

eating:
        atomic {
            eating_count++;
            printf("Philosopher %d is EATING (eating count: %d)\n", id, eating_count);
            /* Safety assertion: adjacent philosophers cannot eat at the same time */
            assert(eating_count <= N / 2);
        }

        /* Finish eating */
        atomic {
            eating_count--;
            fork[left] = false;
            fork[right] = false;
            printf("Philosopher %d put down forks\n", id);
        }
    od
}

init {
    byte i = 0;
    atomic {
        for (i : 0 .. N-1) {
            run Philosopher(i);
        }
    }
}

/* LTL Verification Properties */
/* Property 1: Safety - At most N/2 philosophers can eat simultaneously */
ltl max_eating { [] (eating_count <= (N / 2)) }

/* Property 2: Liveness - If Philosopher 0 is hungry, it eventually eats */
ltl no_starvation_phil0 { [] (Philosopher[0]@hungry -> <> Philosopher[0]@eating) }
