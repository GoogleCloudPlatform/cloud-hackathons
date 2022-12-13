#!/bin/bash
TARGET=dist

mkdir -p ${TARGET}/hacks
rsync -av --exclude=${TARGET} --exclude=tools --exclude=hacks --exclude=.git . ${TARGET}
for HACK in $(ls hacks); do
    GEN=${TARGET}/hacks/${HACK}
    IMG=hacks/${HACK}/images
    mkdir -p ${GEN}
    [ -d $IMG ] && cp -R ${IMG} ${GEN}/images
    python3 tools/split.py --output-dir ${GEN} hacks/${HACK}/README.md
done
