### internal/slime.sh -- slime stuff
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

###
_configure_implementation() {
    noinform="--noinform"
    end_toplevel_options="--end-toplevel-options"
    quit="(sb-ext:quit)"
    eval="--eval"
    core_option="--core"

    if test -n "$USER_INIT"; then
	common_options="--userinit $USER_INIT"
    else
	common_options=""
    fi

    build_options="$noinform --noprint --disable-debugger $common_options"
    run_options="--disable-debugger $common_options"
}

_print_core_option() {
    core_name=$1
    echo '(sb-ext:save-lisp-and-die "'$1'")'
}

_compile_implementation() {
    source_dir=$base/source
    target_dir=$base/target
    if ! test -d $source_dir/sbcl; then
	echo "sbcl not found, try running 'clbuild update sbcl'" 1>&2
	exit 1
    fi

    # Enable threads
    if test "$(uname -s)" = Darwin -a "$(uname -p)" = powerpc; then
	darwinppc=1
    else
	darwinppc=""
    fi
    if test -z "$darwinppc"; then
	ctf=$source_dir/sbcl/customize-target-features.lisp
	if test -f $ctf; then
	    echo $ctf already exists
	else
	    echo creating $ctf
	    cat >$ctf <<EOF
(lambda (list)
  (pushnew :sb-thread list)
  list)
EOF
	fi
    fi
    (cd $source_dir/sbcl; sh make.sh "$1"; SBCL_HOME= INSTALL_ROOT=${target_dir} sh install.sh)
    if test -f $target_dir/bin/sbcl; then
	cat <<EOF

SBCL has been compiled and installed to $target_dir.

*** Note that clbuild will not use the newly compiled SBCL by default.
*** Add this code to clbuild.conf to activate it:

cat >>$base/clbuild.conf <<eof
LISP_IMPLEMENTATION_TYPE=sbcl
LISP_BINARY=$target_dir/bin/sbcl
export SBCL_HOME=$target_dir/lib/sbcl/
eof
EOF
    fi
}
