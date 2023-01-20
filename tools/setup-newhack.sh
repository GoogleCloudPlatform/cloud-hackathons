HACK=$1

BASEDIR=hacks/${HACK}
mkdir ${BASEDIR}

mkdir ${BASEDIR}/artifacts
mkdir ${BASEDIR}/resources
mkdir ${BASEDIR}/images

cp faq/template-student-guide.md ${BASEDIR}/README.md
cp faq/template-coach-guide.md ${BASEDIR}/solutions.md

echo "$(whoami)@google.com" > ${BASEDIR}/QL_OWNER
