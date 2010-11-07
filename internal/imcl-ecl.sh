### internal/slime.sh -- slime stuff
###
### Part of qlbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/qlbuild || exit 1

###
_configure_implementation() {
    noinform="-q"
    end_toplevel_options="--"
    quit="(cl-user:quit)"
    eval="-eval"
    core_option="-c"
    
    if test -n "$USER_INIT" -a x"$USER_INIT" != x/dev/null; then
        common_options="-load $USER_INIT"
    else
        common_options=""
    fi

    build_options="$noinform $common_options"
    run_options="$common_options"
}
