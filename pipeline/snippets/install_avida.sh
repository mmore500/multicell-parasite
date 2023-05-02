AVIDA_REVISION="8cd14b773d4345b2bf612d418e8cc98b80ff9d36"
echo "AVIDA_REVISION ${AVIDA_REVISION}"

while ! [ -L "/tmp/${AVIDA_REVISION}" ]; do

  AVIDA_INSTALL_PATH="$(mktemp -d)"
  echo "AVIDA_INSTALL_PATH ${AVIDA_INSTALL_PATH}"

  git clone https://github.com/devosoft/Avida.git --recursive "${AVIDA_INSTALL_PATH}"

  (
    module purge || :
    module load ccache/3.3.3 GCCcore/11.2.0 CMake/3.22.1 || :
    export CXX="ccache g++"
    cd "${AVIDA_INSTALL_PATH}"
    git checkout --recurse-submodules "${AVIDA_REVISION}"
    git submodule foreach --recursive git status
    ./build_avida
  )

  ln -s "${AVIDA_INSTALL_PATH}" "/tmp/${AVIDA_REVISION}" || :

done

export AVIDA="/tmp/${AVIDA_REVISION}/cbuild/work/avida"
"${AVIDA}" -version
