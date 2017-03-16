#!/bin/bash

ASMFILE="bfc.asm"

PROJDIR=$(pwd)
EXTERN=${PROJDIR}/extern

ASMDIR=${EXTERN}/asm8080
ASM=${ASMDIR}/src/asm8080

TLVMDIR=${EXTERN}/tlvm

cd ${PROJDIR}
${ASM} ${ASMFILE}
${ASM} "hello.asm"
