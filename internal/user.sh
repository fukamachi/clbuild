### internal/prepl.sh -- prepl invocation
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

ensure_user_core() {
    user_core=$base/$LISP_IMPLEMENTATION_TYPE-user.core
    ensure_quicklisp
    if ! (valid_core_p "$user_core"); then
	echo clbuild: no valid core file $user_core, dumping now...
	dump_core \
	    "$user_core" \
	    $eval "(load \"$base/internal/user.lisp\")" \
	    $eval "(clbuild::%process-usercore.conf #p\"$base/\")"
	echo clbuild: done dumping the core file
    fi
    with_core_options="$core_option $user_core $common_options"
}

cl_ed() {
    if test -z "$1"; then
	form="(ed)"
    elif echo "$1" | grep -E '^[/.]' >/dev/null || test -f "$1"; then
        # looks like a path
	form="(ed \"$1\")"
    else
        # might be a lisp form
	form="(ed (cl:quote $1))"
    fi
    shift
    run_lisp_with_core "$@" $eval "(progn $form $quit)"
}
