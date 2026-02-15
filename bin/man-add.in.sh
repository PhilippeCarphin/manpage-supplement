#!/usr/bin/env -S bash -o errexit -o nounset -o errtrace -o pipefail -O inherit_errexit -O nullglob -O extglob

src_dir=@CMAKE_SOURCE_DIR@
bin_dir=@CMAKE_BINARY_DIR@

usage(){
    cat <<-EOF
	USAGE:
	    man-add SECTION NAME
	Create and edit a manpage for the manpage supplement repo
	EOF
}

main(){
    if (( $# < 2 )) ; then
        usage
        echo "ERROR: Not enough arguments"
        return 2
    fi

    new_section=$1
    new_name=$2
    if [[ ${new_section} == '?' ]] ; then
        printf "Select a section\n"
        select section_line in "${sections[@]}" ; do
            if [[ -n "${section_line}" ]] ; then
                new_section=${section_line%% *}
                break
            fi
        done
    fi

    manpages=($(find ${src_dir}/share/man/man${new_section} -name "*$new_name*"))
    if ((${#manpages[@]})) ; then
        printf "%s: ERROR: A manpage already exists in section %d of manpage-supplement with the name %s\n" \
            "${0##*/}" "${new_section}" "${new_name}"
        exit 1
    fi

    manpages=($(man -wa ${new_section} ${new_name}))
    if ((${#manpages[@]})) ; then
        printf "${0##*/}: ERROR: A manpage already exists outside of manpage-supplement with the same name and section: %s\n" \
            "${manpages[*]}"
        exit 1
    fi

    manpages=($(man -wa ${new_name}))
    if ((${#manpages[@]})) ; then
        printf "${0##*/}: WARNING: A manpage already exists outside of manpage-supplement with the same name but different section: %s\n" \
            "${manpages[*]}"
    fi


    mkdir -p ${src_dir}/share/man/man${new_section}
    new_page=${src_dir}/share/man/man${new_section}/${new_name}.org
    cp ${src_dir}/manpage-template.org ${new_page}

    ${EDITOR:-vim} ${new_page}

    cmake -S "${src_dir}" -B "${bin_dir}"
    cmake --build "${bin_dir}"
    cmake --install "${bin_dir}"
    quickstow -R ${src_dir##*/}
}
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

main "$@"
