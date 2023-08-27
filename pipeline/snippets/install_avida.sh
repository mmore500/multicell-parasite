#!/bin/bash

export TMPDIR="${HOME}/scratch/tmp"
mkdir -p "${TMPDIR}"

AVIDA_REVISION="64f1b03ce30c5aa341e9704d4ff0f6109a375f1f"
echo "AVIDA_REVISION ${AVIDA_REVISION}"

while ! [ -L "${TMPDIR}/${AVIDA_REVISION}" ]; do

  AVIDA_INSTALL_PATH="$(mktemp -d)"
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
    if [ "${RUNMODE}" == "TESTING" ]; then
        ./build_avida -DCMAKE_BUILD_TYPE=Debug
    else
        ./build_avida
    fi
  )

  ln -s "${AVIDA_INSTALL_PATH}" "${TMPDIR}/${AVIDA_REVISION}" || :

done

export AVIDA="${TMPDIR}/${AVIDA_REVISION}/cbuild/work/avida"
"${AVIDA}" -version

unset TMPDIR
