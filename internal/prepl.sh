### internal/prepl.sh -- prepl invocation
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

ensure_prepl_core() {
    prepl_core=$base/$LISP_IMPLEMENTATION_TYPE-prepl.core
    ensure_quicklisp
    if ! (valid_core_p "$prepl_core"); then
	echo clbuild: no valid core file $prepl_core, dumping now...
	dump_core \
	    "$prepl_core" \
	    $eval "(ql:quickload \"hemlock.tty\")"
	echo clbuild: done dumping the core file
    fi
    with_core_options="$core_option $prepl_core $common_options"
}
