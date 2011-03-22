### internal/slime.sh -- slime stuff
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

###
_configure_implementation() {
    noinform="" #fixme
    end_toplevel_options="" #fixme
    quit="(excl:exit)"
    eval="-e"
    core_option="-I"

    if test -n "$USER_INIT"; then
	common_options="-qq -L $USER_INIT"
    else
	common_options=""
    fi

    # fixme
    build_options="$common_options"
    run_options="$common_options"
}

_print_core_option() {
    core_name=$1
    echo '(unwind-protect (excl:dumplisp :name "'$1'") (excl:exit))'
}
