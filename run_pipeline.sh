#!/usr/bin/env bash
# Script demonstrating the SPIN (Simple Promela INterpreter) verification pipeline:
# Promela Model -> spin -a -> pan.c -> gcc -O2 -> ./pan

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

MODEL="mutex_peterson.pml"

echo -e "${CYAN}===================================================================${NC}"
echo -e "${CYAN}          SPIN Model Checker Execution Pipeline                    ${NC}"
echo -e "${CYAN}===================================================================${NC}"
echo ""

echo -e "${YELLOW}[1/4] Input Promela Model (${MODEL}):${NC}"
echo -e "Language: ${MAGENTA}Promela${NC} (Process Meta Language)"
echo -e "Checking file existence..."
if [ ! -f "$MODEL" ]; then
    echo "Error: $MODEL not found!"
    exit 1
fi
echo -e "${GREEN}✓ Model file ready.${NC}"
echo ""

echo -e "${YELLOW}[2/4] Translating Promela to C Code Verifier (SPIN):${NC}"
echo -e "Executing: ${MAGENTA}spin -a ${MODEL}${NC}"
spin -a "${MODEL}"
echo -e "${GREEN}✓ Generated pan.c ($(du -h pan.c | cut -f1)) and pan.h ($(du -h pan.h | cut -f1))${NC}"
echo ""

echo -e "${YELLOW}[3/4] Compiling generated C verifier using GCC/Clang:${NC}"
echo -e "Executing: ${MAGENTA}gcc -O2 -DSAFETY -DNOLNACK -o pan pan.c${NC}"
gcc -O2 -DSAFETY -DNOLNACK -o pan pan.c
echo -e "${GREEN}✓ Compiled executable binary './pan' ($(du -h pan | cut -f1))${NC}"
echo ""

echo -e "${YELLOW}[4/4] Executing High-Speed C Model Checker (./pan):${NC}"
echo -e "Executing: ${MAGENTA}./pan${NC}"
echo -e "${CYAN}-------------------------------------------------------------------${NC}"
./pan
echo -e "${CYAN}-------------------------------------------------------------------${NC}"
echo ""
echo -e "${GREEN}===================================================================${NC}"
echo -e "${GREEN}  SUCCESS: Model Verification Completed via compiled C code!      ${NC}"
echo -e "${GREEN}===================================================================${NC}"
