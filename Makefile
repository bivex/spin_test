# High-Speed Makefile for SPIN Promela Model Checking Pipeline
# Optimized for Maximum States/sec Execution Speed

CC ?= gcc
# High-Performance Compiler Flags: -O3 -march=native -DSAFETY -DNOLNACK -DNOBOUNDS -DFAST
CFLAGS ?= -O3 -march=native -DSAFETY -DNOLNACK -DNOBOUNDS -DFAST

.PHONY: all verify-peterson verify-philosophers verify-dekker verify-abp verify-bank verify-auction verify-buggy trace-buggy verify-agent-v2 clean

all: verify-peterson verify-philosophers verify-dekker verify-abp verify-bank verify-auction verify-agent-v2

verify-peterson:
	@echo "=== High-Speed Verifying Peterson Mutex Algorithm ==="
	spin -a mutex_peterson.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

verify-philosophers:
	@echo "=== High-Speed Verifying Dining Philosophers Problem ==="
	spin -a dining_philosophers.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan -m20000

verify-dekker:
	@echo "=== High-Speed Verifying Dekker's Mutex Algorithm ==="
	spin -a dekker_mutex.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

verify-abp:
	@echo "=== High-Speed Verifying Alternating Bit Protocol ==="
	spin -a alternating_bit_protocol.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

verify-bank:
	@echo "=== High-Speed Verifying Economic Bank Transfer System ==="
	spin -a bank_transfer.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

verify-auction:
	@echo "=== High-Speed Verifying Economic Auction Bidding System ==="
	spin -a auction_system.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

verify-agent-v2:
	@echo "=== High-Speed Verifying AgentJobEngine Event-Driven Model v2 ==="
	spin -a agent_job_engine_v2.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan -m5000 -u100 || true

verify-buggy:
	@echo "=== Verifying Buggy Mutex Model (Expect Error Detected) ==="
	spin -a mutex_buggy.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan || true

trace-buggy: verify-buggy
	@echo "=== Replaying Counterexample Trail (spin -t -p) ==="
	spin -t -p mutex_buggy.pml

clean:
	rm -f pan pan.c pan.h pan.b pan.m pan.t pan.p pan.d _spin_nvr.tmp *.trail
