### internal/impl.sh -- start a lisp implementation
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

# When this code runs, LISP_IMPLEMENTATION_TYPE and LISP_BINARY have
# already been set by config file or command line option.
#
# In deviation from old clbuild code, no attempt is made to guess values
# for these variables -- we only do as the user says.  (Keep it simple,
# stupid.)

USER_INIT="$(make_absolute_pn "$USER_INIT")"

configure_implementation() {
    implscript=$internal/impl-$LISP_IMPLEMENTATION_TYPE.sh
    if ! test -f "$implscript"; then
        echo "Unknown implementation '$implementation'" 1>&2
        exit 1
    fi
    . $implscript
    assert_function _configure_implementation
    _configure_implementation
    asdf_setup_lisp=$internal/asdf-setup.lisp
    init_asdf_1="(progn (load \"$ql_setup_lisp\") (load \"$asdf_setup_lisp\"))"
    init_asdf_2="(clbuild:fix-central-registry #p\"$base/\")"
    with_core_options=$common_options
}

assert_function() {
    fun=$1
    if test "$(type -t $fun)" != function; then
	echo failed to find version of $fun for $LISP_IMPLEMENTATION_TYPE
	exit 1
    fi
}

print_core_option() {
    assert_function _print_core_option
    _print_core_option "$@"
}

compile_implementation() {
    assert_function _compile_implementation
    _compile_implementation "$@"
}

run_lisp_raw() {
    $LISP_BINARY \
	$common_options \
	"$@"
}

run_lisp_with_core() {
    $LISP_BINARY \
	$with_core_options \
	"$@"
}

run_lisp_with_ql() {
    $LISP_BINARY \
	$common_options \
	$eval "$init_asdf_1" \
	$eval "$init_asdf_2" \
	"$@"
}

dump_core() {
    core_name=$1
    shift
    dump_core_option=$(print_core_option "$core_name")
    rm -f $core_name
    $LISP_BINARY \
	$common_options \
	$eval "$init_asdf_1" \
	$eval "$init_asdf_2" \
	"$@" \
	$eval "$dump_core_option"
}

rm_cores() {
    echo cleaning cores
    for core in base prepl user; do
	p=$base/$LISP_IMPLEMENTATION_TYPE-${core}.core
	echo -n checking ${p}...
	if test -f "$p"; then
	    rm -f "$p"
	    echo " deleted"
	else
	    echo " nothing to do"
	fi
    done
}

valid_core_p() {
    if ! test -f "$1"; then exit 1; fi
    for f in "$base/clbuild.conf" "$base/conf.lisp" "$base/internal/asdf-setup.lisp" "$base/usercore.conf" "$ql_setup_lisp"
    do
	if test -f "$f" -a ! "$1" -nt "$f"; then exit 1; fi
    done
}
