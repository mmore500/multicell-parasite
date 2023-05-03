export TMPDIR="${HOME}/scratch/tmp"
mkdir -p "${TMPDIR}"

AVIDA_REVISION="895874591d3fa9ac147e9f73a33d7f58759bd49d"
echo "AVIDA_REVISION ${AVIDA_REVISION}"

while ! [ -L "${TMPDIR}/${AVIDA_REVISION}" ]; do

  AVIDA_INSTALL_PATH="$(mktemp -d)"
  echo "AVIDA_INSTALL_PATH ${AVIDA_INSTALL_PATH}"

  git clone https://github.com/devosoft/Avida.git "${AVIDA_INSTALL_PATH}"

  (
    module purge || :
    module load ccache/3.3.3 GCCcore/11.3.0 CMake/3.23.1 git/2.36.0-nodocs || :
    export CXX="ccache g++"
    cd "${AVIDA_INSTALL_PATH}"
    git checkout "${AVIDA_REVISION}"
    git submodule update --init --recursive
    git submodule foreach --recursive git status
    ./build_avida
  )

  ln -s "${AVIDA_INSTALL_PATH}" "${TMPDIR}/${AVIDA_REVISION}" || :

done

export AVIDA="${TMPDIR}/${AVIDA_REVISION}/cbuild/work/avida"
"${AVIDA}" -version

unset TMPDIR
