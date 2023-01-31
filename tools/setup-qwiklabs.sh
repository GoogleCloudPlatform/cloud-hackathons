#!/bin/bash

SRC_DIR=gHacks
DST_DIR=gcp-ce-content

LONG="hack:,slug:"
OPTS=$(getopt -o '' --longoptions ${LONG} -- "$@")

eval set -- "${OPTS}"

while :; do
    case "${1}" in
        --hack  ) HACK="${2}"  ;;
        --slug  ) SLUG="${2}"  ;;
        --      ) shift; break ;;
    esac
    shift
done

if [ -z ${HACK} ] || [ -z ${SLUG} ]; then
    echo "Usage: ${0} --hack=<string> --slug=<string>" 1>&2; exit 1
fi

if [[ ${SLUG} =~ ^ghacks[0-9]{3}$ ]]; then
    SLUG=${SLUG}-${HACK}
fi

if [[ ! ${SLUG} =~ ^ghacks[0-9]{3}-${HACK}$ ]]; then
    echo "Slug '${SLUG}' has to match pattern 'ghacks[0-9]{3}-${HACK}'" 1>&2; exit 1
fi

HACK_DIR="${SRC_DIR}/hacks/${HACK}"

if [ ! -d ${HACK_DIR} ] || [ ! -d ${DST_DIR} ]; then
    echo "${HACK_DIR} and/or ${DST_DIR} missing, are you in the right directory?" 1>&2; exit 1
fi

LAB_DIR="${DST_DIR}/labs/${SLUG}"
mkdir -p ${LAB_DIR}

rsync -av --exclude=solutions.md ${HACK_DIR}/ ${LAB_DIR}/

INST_DIR="${LAB_DIR}/instructions"
mkdir -p ${INST_DIR}
mv ${LAB_DIR}/README.md ${INST_DIR}/en.md
mv ${LAB_DIR}/images ${INST_DIR}/

# git --git-dir="${DST_DIR}/.git" checkout -b ${HACK}
# git --git-dir="${DST_DIR}/.git" commit -am "adding gHacks ${HACK}"
# git --git-dir="${DST_DIR}/.git" push --set-upstream origin ${HACK}

