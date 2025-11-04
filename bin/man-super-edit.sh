set -x
manpage=$(man -w $1)

if ! [[ ${manpage} == */localinstall/* ]] ; then
    printf "${0##*/}: ERROR: Manpage '${manpage}' is not from one of my packages\n"
    exit 1
fi

src_prefix=${manpage%%/localinstall/*}
manpage_suffix=${manpage#${src_prefix}/localinstall}
src_manpage=${src_prefix}/${manpage_suffix#.*}.org

${EDITOR:-vim} ${src_manpage}
