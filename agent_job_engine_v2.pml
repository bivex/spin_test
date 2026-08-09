/*
 * Promela Model v2: Optimized AgentJobEngine / JobObjects Engine
 * 
 * Architectural Improvements Demonstrated:
 * 1. Event-Driven Messaging (no polling loop lag).
 * 2. Hysteresis Thresholds (Freeze at 80%, Thaw at 60% to prevent thrashing).
 * 3. Priority-based Thaw Queue.
 */

#define MAX_AGENTS 3
#define MAX_MEMORY_CAP 100
#define FREEZE_THRESHOLD 80 /* Freeze at 80% RAM */
#define THAW_THRESHOLD 60   /* Thaw at 60% RAM (Hysteresis) */
#define IDLE_RAM 15
#define ACTIVE_RAM 45

byte agent_ram[MAX_AGENTS] = IDLE_RAM;
bool is_frozen[MAX_AGENTS] = false;
byte total_ram = MAX_AGENTS * IDLE_RAM;

/* Event Channel for Instant OS Controller Notification */
mtype = { EVENT_RAM_SPIKE, EVENT_RAM_RELEASE };
chan os_event_chan = [10] of { mtype, byte };

proctype OptimizedAgentWorker(byte id) {
    do
    :: true ->
        /* Step 1: LLM Reasoning Phase (Compress Working Set) */
        atomic {
            if
            :: !is_frozen[id] ->
                total_ram = total_ram - agent_ram[id] + IDLE_RAM;
                agent_ram[id] = IDLE_RAM;
                os_event_chan ! EVENT_RAM_RELEASE, id;
            :: is_frozen[id] -> skip;
            fi;
        }

        /* Step 2: Tool Execution Phase (Expand Working Set) */
        atomic {
            if
            :: (!is_frozen[id] && total_ram + (ACTIVE_RAM - IDLE_RAM) <= MAX_MEMORY_CAP) ->
                total_ram = total_ram - agent_ram[id] + ACTIVE_RAM;
                agent_ram[id] = ACTIVE_RAM;
                os_event_chan ! EVENT_RAM_SPIKE, id;
            :: is_frozen[id] -> skip;
            fi;
        }

        assert(total_ram <= MAX_MEMORY_CAP);
    od;
}

proctype EventDrivenOSController() {
    mtype evt;
    byte sender_id;

    do
    :: os_event_chan ? evt, sender_id ->
        atomic {
            if
            :: (evt == EVENT_RAM_SPIKE && total_ram >= FREEZE_THRESHOLD) ->
                /* Instant Event-Driven Freeze */
                if
                :: (!is_frozen[sender_id]) ->
                    is_frozen[sender_id] = true;
                    printf("OS Event Controller: INSTANT FREEZE Agent[%d] (RAM: %d MB)\n", sender_id, total_ram);
                :: else -> skip;
                fi;

            :: (evt == EVENT_RAM_RELEASE && total_ram <= THAW_THRESHOLD) ->
                /* Hysteresis Thaw Check */
                byte k;
                for (k : 0 .. MAX_AGENTS-1) {
                    if
                    :: is_frozen[k] ->
                        is_frozen[k] = false;
                        printf("OS Event Controller: HYSTERESIS THAW Agent[%d] (RAM: %d MB)\n", k, total_ram);
                        break;
                    :: else -> skip;
                    fi;
                }
            :: else -> skip;
            fi;
        }
    od;
}

init {
    atomic {
        run EventDrivenOSController();
        byte a;
        for (a : 0 .. MAX_AGENTS-1) {
            run OptimizedAgentWorker(a);
        }
    }
}

/* Safety Property: Memory Cap Bound */
ltl ram_bounded_v2 { [] (total_ram <= MAX_MEMORY_CAP) }
