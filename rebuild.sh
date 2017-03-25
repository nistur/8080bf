#!/bin/bash

SRCDIR="src/"
BINDIR="bin/"

ASMFILE="bfc"
BFFILE="hello2"

PROJDIR=$(pwd)
EXTERN=${PROJDIR}/extern

ASMDIR=${EXTERN}/asm8080
ASM=${ASMDIR}/src/asm8080

TLVMDIR=${EXTERN}/tlvm

cd ${PROJDIR}

if [ ! -d ${BINDIR} ]; then
    mkdir ${BINDIR}
fi

${ASM} ${SRCDIR}${ASMFILE}.asm -I${SRCDIR} -o${BINDIR}${ASMFILE}
${ASM} ${SRCDIR}${BFFILE}.asm -I${SRCDIR} -o${BINDIR}${BFFILE}
