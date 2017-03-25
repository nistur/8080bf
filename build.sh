#!/bin/bash

SRCDIR="src/"
BINDIR="bin/"

ASMFILE="bfc"
BFFILE="hello"

PROJDIR=$(pwd)
EXTERN=${PROJDIR}/extern

ASMDIR=${EXTERN}/asm8080
ASM=${ASMDIR}/src/asm8080

TLVMDIR=${EXTERN}/tlvm

cd ${ASMDIR}
sh ./autogen.sh
./configure
make

cd ${TLVMDIR}
premake5 gmake
make

cd ${PROJDIR}

if [ ! -d ${BINDIR} ]; then
    mkdir ${BINDIR}
fi

${ASM} ${SRCDIR}${ASMFILE}.asm -I${SRCDIR} -o${BINDIR}${ASMFILE}
${ASM} ${SRCDIR}${BFFILE}.asm -I${SRCDIR} -o${BINDIR}${BFFILE}

