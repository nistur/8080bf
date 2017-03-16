#!/bin/bash

ASMFILE="bf.asm"

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
${ASM} ${ASMFILE}

