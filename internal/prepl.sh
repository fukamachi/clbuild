### internal/prepl.sh -- prepl invocation
###
### Part of qlbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/qlbuild || exit 1

ensure_prepl_core() {
    prepl_core=$base/$LISP_IMPLEMENTATION_TYPE-prepl.core
    ensure_quicklisp
    if ! test -f "$prepl_core"; then
	echo qlbuild: core file $prepl_core not found, dumping now...
	dump_core \
	    "$prepl_core" \
	    $eval "(ql:quickload \"hemlock.tty\")"
	echo qlbuild: done dumping the core file
    elif test $ql_setup_lisp -nt $prepl_core; then
	echo qlbuild: Warning: $ql_setup_lisp is newer than $prepl_core.
	echo consider running qlbuild rm-cores
    fi
    with_core_options="$core_option $prepl_core $common_options"
}
