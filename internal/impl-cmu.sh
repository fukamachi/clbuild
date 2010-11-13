### internal/slime.sh -- slime stuff
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

###
_configure_implementation() {
    noinform="-quiet"
    end_toplevel_options="--"
    quit="(ext:quit)"
    eval="-eval"
    core_option="-core"

    if test x"$USER_INIT" = x/dev/null; then
	common_options="-noinit"
    elif test -n "$USER_INIT"; then
	common_options="-init $USER_INIT"
    else
	common_options=""
    fi

    build_options="$noinform -batch $common_options"
    run_options="-batch $common_options"
}
