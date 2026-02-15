#!/usr/bin/env -S bash -o errexit -o nounset -o errtrace -o pipefail -O inherit_errexit -O nullglob -O extglob

src_dir=@CMAKE_SOURCE_DIR@
if ! manpages=($(find ${src_dir}/share/man -name "*$1*")) ; then
    printf "${0##*/}: ERROR: No manpage found for %s\n" "$1"
    exit 1
fi

for manpage in "${manpages[@]}" ; do
    ${EDITOR:-vim} ${manpage%.*}.org
done

cmake -S ${src_dir} -B @CMAKE_BINARY_DIR@
cmake --build @CMAKE_BINARY_DIR@
cmake --install @CMAKE_BINARY_DIR@
