#!/usr/bin/env -S bash -o errexit -o nounset -o errtrace -o pipefail -O inherit_errexit -O nullglob -O extglob

sections=(
       "1   Executable programs or shell commands"
       "2   System calls (functions provided by the kernel)"
       "3   Library calls (functions within program libraries)"
       "4   Special files (usually found in /dev)"
       "5   File formats and conventions eg /etc/passwd"
       "6   Games"
       "7   Miscellaneous (including macro packages and conventions), e.g.  man(7), groff(7)"
       "8   System administration commands (usually only for root)"
       "9   Kernel routines [Non standard]"
)


new_section=$1
new_name=$2
file=${3:-}
if [[ ${new_section} == '?' ]] ; then
    printf "Select a section\n"
    select section_line in "${sections[@]}" ; do
        if [[ -n "${section_line}" ]] ; then
            new_section=${section_line%% *}
            break
        fi
    done
fi

src_dir=@CMAKE_SOURCE_DIR@
manpages=($(find ${src_dir}/share/man -name "*$2*"))
if ((${#manpages[@]})) ; then
    printf "${0##*/}: ERROR: Manpages already exist with this name: (%s)\n" "${manpages[*]}"
    exit 1
fi
mkdir -p ${src_dir}/share/man/man${new_section}
new_page=${src_dir}/share/man/man${new_section}/${new_name}.org
cp ${src_dir}/manpage-template.org ${new_page}

${EDITOR:-vim} ${new_page}

cmake -S @CMAKE_SOURCE_DIR@ -B @CMAKE_BINARY_DIR@
cmake --build @CMAKE_BINARY_DIR@
cmake --install @CMAKE_BINARY_DIR@
quickstow -R ${src_dir##*/}
