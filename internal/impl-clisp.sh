### internal/slime.sh -- slime stuff
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

###
_configure_implementation() {
    LISP_BINARY="$LISP_BINARY -repl"

    noinform="" #fixme
    end_toplevel_options="" #fixme
    quit="(ext:quit)"
    eval="-x"
    core_option="-M"

    if test -n "$USER_INIT"; then
	common_options="-norc -i $USER_INIT"
    else
	common_options=""
    fi

    build_options="-on-error exit $common_options"
    run_options="-on-error exit $common_options"
}
