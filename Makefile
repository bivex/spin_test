# Makefile for SPIN Promela Model Checking Pipeline

CC ?= gcc
CFLAGS ?= -O2 -DSAFETY -DNOLNACK

.PHONY: all verify-peterson verify-philosophers verify-dekker verify-abp verify-bank verify-auction verify-buggy trace-buggy clean

all: verify-peterson verify-philosophers verify-dekker verify-abp verify-bank verify-auction

verify-peterson:
	@echo "=== Verifying Peterson Mutex Algorithm ==="
	spin -a mutex_peterson.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

verify-philosophers:
	@echo "=== Verifying Dining Philosophers Problem ==="
	spin -a dining_philosophers.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan -m20000

verify-dekker:
	@echo "=== Verifying Dekker's Mutex Algorithm ==="
	spin -a dekker_mutex.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

verify-abp:
	@echo "=== Verifying Alternating Bit Protocol ==="
	spin -a alternating_bit_protocol.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

verify-bank:
	@echo "=== Verifying Economic Bank Transfer System ==="
	spin -a bank_transfer.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

verify-auction:
	@echo "=== Verifying Economic Auction Bidding System ==="
	spin -a auction_system.pml
	$(CC) $(CFLAGS) -o pan pan.c
	./pan

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
