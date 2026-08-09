/*
 * Bounded Buffer Producer-Consumer in Promela
 * Demonstrates message channels and deadlock/overflow verification.
 */

#define CAPACITY 3

chan buffer = [CAPACITY] of { int };
byte items_produced = 0;
byte items_consumed = 0;

proctype Producer() {
    int item = 0;
    do
    :: items_produced < 5 ->
        item = items_produced + 100;
        buffer ! item; /* Send item to channel */
        printf("Producer sent: %d\n", item);
        items_produced++;
    :: items_produced >= 5 -> break;
    od;
    printf("Producer finished.\n");
}

proctype Consumer() {
    int data = 0;
    do
    :: items_consumed < 5 ->
        buffer ? data; /* Receive item from channel */
        printf("Consumer received: %d\n", data);
        items_consumed++;
    :: items_consumed >= 5 -> break;
    od;
    printf("Consumer finished.\n");
}

init {
    atomic {
        run Producer();
        run Consumer();
    }
}

/* LTL Property: Eventually all 5 items are consumed */
ltl all_consumed { <> (items_consumed == 5) }
