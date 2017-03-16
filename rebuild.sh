#!/bin/bash

ASMFILE="bfc.asm"
BFFILE="hello.asm"

PROJDIR=$(pwd)
EXTERN=${PROJDIR}/extern

ASMDIR=${EXTERN}/asm8080
ASM=${ASMDIR}/src/asm8080

TLVMDIR=${EXTERN}/tlvm

cd ${PROJDIR}
${ASM} ${ASMFILE}
${ASM} ${BFFILE}