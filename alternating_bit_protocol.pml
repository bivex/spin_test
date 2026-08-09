/*
 * Alternating Bit Protocol (ABP) in Promela
 * Demonstrates modeling protocol verification over an unreliable, lossy network channel.
 */

mtype = { msg0, msg1, ack0, ack1 };

chan to_receiver = [1] of { mtype };
chan to_sender = [1] of { mtype };

byte items_received = 0;

proctype Sender() {
    do
    :: true ->
        /* Send msg0 until ack0 received */
        do
        :: to_receiver ! msg0;
            if
            :: to_sender ? ack0 -> break;
            :: to_sender ? ack1 -> skip; /* ignore stale ack */
            :: timeout -> skip;         /* retransmit on timeout */
            fi;
        od;

        /* Send msg1 until ack1 received */
        do
        :: to_receiver ! msg1;
            if
            :: to_sender ? ack1 -> break;
            :: to_sender ? ack0 -> skip; /* ignore stale ack */
            :: timeout -> skip;         /* retransmit on timeout */
            fi;
        od;
    od;
}

proctype Receiver() {
    do
    :: to_receiver ? msg0 ->
        items_received++;
        printf("Receiver got msg0 (total: %d)\n", items_received);
        to_sender ! ack0;

    :: to_receiver ? msg1 ->
        items_received++;
        printf("Receiver got msg1 (total: %d)\n", items_received);
        to_sender ! ack1;
    od;
}

init {
    atomic {
        run Sender();
        run Receiver();
    }
}

/* LTL Verification Property: Progress / Liveness */
ltl progress { <> (items_received > 0) }
