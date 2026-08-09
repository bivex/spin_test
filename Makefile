# Makefile for SPIN Promela Model Checking Pipeline
#
# Pipeline steps:
# 1. Promela model (.pml)
# 2. SPIN compiler (spin -a) -> pan.c, pan.h, pan.b, pan.m, pan.t
# 3. GCC compiler (gcc -O2 -o pan pan.c)
# 4. Verifier execution (./pan)

MODEL ?= mutex_peterson.pml
CC ?= gcc
CFLAGS ?= -O2 -DSAFETY -DNOLNACK

.PHONY: all simulate generate compile verify clean help

all: verify

# 1. Simulate Promela model (random execution simulation)
simulate:
	@echo "=== Step 1: Simulating Promela model ($(MODEL)) ==="
	spin $(MODEL)

# 2. Generate C verifier code using SPIN
generate:
	@echo "=== Step 2: Generating C code verifier (spin -a $(MODEL)) ==="
	spin -a $(MODEL)
	@ls -l pan.c pan.h

# 3. Compile pan.c into binary verifier pan
compile: generate
	@echo "=== Step 3: Compiling C code verifier ($(CC) $(CFLAGS) -o pan pan.c) ==="
	$(CC) $(CFLAGS) -o pan pan.c

# 4. Execute C verifier binary
verify: compile
	@echo "=== Step 4: Running SPIN verifier binary (./pan) ==="
	./pan

# Verify LTL Property 'mutex'
verify-ltl:
	@echo "=== Compiling verifier with LTL support ==="
	spin -a -N mutex $(MODEL)
	$(CC) -O2 -DXUSAFE -o pan pan.c
	./pan

clean:
	@echo "=== Cleaning generated verifier C files and binary ==="
	rm -f pan pan.c pan.h pan.b pan.m pan.t pan.p pan.d *.trail
