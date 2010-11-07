### internal/slime.sh -- slime stuff
###
### Part of qlbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/qlbuild || exit 1

###
_configure_implementation() {
    noinform="-Q"
    end_toplevel_options="" #fixme
    quit="(ccl:quit)"
    eval="--eval"
    core_option="-I"

    if test x"$USER_INIT" = x/dev/null; then
	# -l /dev/null does not work
	common_options="-n"
    elif test -n "$USER_INIT"; then
	common_options="-n -l $USER_INIT"
    else
	common_options=""
    fi

    # fixme: this doesn't quite match the SBCL version yet:
    build_options="$noinform --batch $common_options"
    run_options="--batch $common_options"
}
