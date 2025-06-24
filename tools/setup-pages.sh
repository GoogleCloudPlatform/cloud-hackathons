#!/bin/bash
set -e
TARGET=dist

mkdir -p ${TARGET}/hacks
rsync -av --exclude=${TARGET} --exclude=_site --exclude=tools --exclude=hacks --exclude=.git . ${TARGET}

for HACK in $(ls hacks); do
    GEN=${TARGET}/hacks/${HACK}
    IMG=hacks/${HACK}/images
    mkdir -p ${GEN}
    [ -d $IMG ] && cp -R ${IMG} ${GEN}/images
    python3 tools/split.py --output-dir ${GEN} hacks/${HACK}/README.md
done

# Mimic Github admonitions

NOTE="\\1> <span class=\"info\">{% octicon info %} \&nbsp;Note</span>\\2"
WARN="\\1> <span class=\"alert\">{% octicon alert %} \&nbsp;Warning</span>\\2"
TIPS="\\1> <span class=\"tip\">{% octicon light-bulb %} \&nbsp;Tip</span>\\2"
IMPO="\\1> <span class=\"important\">{% octicon report %} \&nbsp;Important</span>\\2"
CAUT="\\1> <span class=\"caution\">{% octicon stop %} \&nbsp;Caution</span>\\2"


find $TARGET -name '*.md' -print0 | xargs -0 sed -i -r \
        -e "s|^(\s*)> \[!NOTE\](.*)|$NOTE|g" \
        -e "s|^(\s*)> \[!WARNING\](.*)|$WARN|g" \
        -e "s|^(\s*)> \[!TIP\](.*)|$TIPS|g" \
        -e "s|^(\s*)> \[!IMPORTANT\](.*)|$IMPO|g" \
        -e "s|^(\s*)> \[!CAUTION\](.*)|$CAUT|g"

