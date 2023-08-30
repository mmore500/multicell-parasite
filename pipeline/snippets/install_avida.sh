#!/bin/bash

RUNMODE=${RUNMODE:-PRODUCTION}
echo "RUNMODE ${RUNMODE}"

export TMPDIR="${HOME}/scratch/tmp"
mkdir -p "${TMPDIR}"

AVIDA_REVISION="63da83f0d72cf501ae97f57b563673e4bf48ddaa"
echo "AVIDA_REVISION ${AVIDA_REVISION}"

while ! [ -L "${TMPDIR}/${AVIDA_REVISION}-${RUNMODE}" ]; do

  AVIDA_INSTALL_PATH="$(mktemp -d)"  # uses $TMPDIR
  echo "AVIDA_INSTALL_PATH ${AVIDA_INSTALL_PATH}"

  git clone https://github.com/devosoft/Avida.git "${AVIDA_INSTALL_PATH}"

  (
    module purge || :
    module load ccache/3.3.3 GCCcore/11.3.0 CMake/3.23.1 git/2.36.0-nodocs binutils/2.39 || :
    export CXX="ccache g++"
    cd "${AVIDA_INSTALL_PATH}"
    git checkout "${AVIDA_REVISION}"
    git submodule update --init --recursive
    git submodule foreach --recursive git status
    if [ "${RUNMODE}" == "testing" ]; then
        ./build_avida -DCMAKE_BUILD_TYPE=Debug
    else
        ./build_avida
    fi
  )

  ln -s "${AVIDA_INSTALL_PATH}" "${TMPDIR}/${AVIDA_REVISION}-${RUNMODE}" || :

done

export AVIDA="${TMPDIR}/${AVIDA_REVISION}-${RUNMODE}/cbuild/work/avida"
"${AVIDA}" -version

unset TMPDIR
