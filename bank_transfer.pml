/*
 * Economic Model: Concurrent Bank Account Transfer System in Promela
 * 
 * Demonstrates:
 * 1. Concurrent money transfers between bank accounts.
 * 2. Deadlock-free account locking (ordered locking).
 * 3. Financial Invariant: Total money across all accounts remains constant.
 */

#define NUM_ACCOUNTS 3
#define INITIAL_BALANCE 100
#define TOTAL_SYSTEM_MONEY 300

int balance[NUM_ACCOUNTS] = INITIAL_BALANCE;
bool lock[NUM_ACCOUNTS] = false;

/* Transfer money from one account to another atomically and safely */
proctype ClientTransfer(byte from; byte to; int amount) {
    byte first_lock;
    byte second_lock;

    /* Enforce lock ordering to prevent deadlock (Resource Ordering strategy) */
    if
    :: (from < to) ->
        first_lock = from;
        second_lock = to;
    :: (from > to) ->
        first_lock = to;
        second_lock = from;
    :: else ->
        first_lock = from;
        second_lock = to;
    fi;

    /* Acquire locks */
    atomic { lock[first_lock] == false -> lock[first_lock] = true; }
    atomic { lock[second_lock] == false -> lock[second_lock] = true; }

    /* Perform transfer if sufficient funds exist */
    atomic {
        if
        :: (balance[from] >= amount) ->
            balance[from] = balance[from] - amount;
            balance[to] = balance[to] + amount;
            printf("Transferred %d from Account[%d] to Account[%d]\n", amount, from, to);
        :: (balance[from] < amount) ->
            printf("Transfer failed: Insufficient funds in Account[%d]\n", from);
        fi;

        /* Financial Invariant Check: Sum of all accounts MUST equal initial total */
        assert(balance[0] + balance[1] + balance[2] == TOTAL_SYSTEM_MONEY);
    }

    /* Release locks */
    lock[second_lock] = false;
    lock[first_lock] = false;
}

init {
    atomic {
        run ClientTransfer(0, 1, 30);
        run ClientTransfer(1, 2, 50);
        run ClientTransfer(2, 0, 20);
        run ClientTransfer(1, 0, 40);
    }
}

/* LTL Verification Property: Financial Conservation Law */
ltl total_money_invariant { [] (balance[0] + balance[1] + balance[2] == TOTAL_SYSTEM_MONEY) }
