### internal/utils.sh -- shell utilities
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

###
### Fix up pathnames
###
make_absolute_pn() {
	if [ -n "$1" ] ; then
		(cd "$base"
		echo "$(cd "$(dirname "$1")" ; pwd)/$(basename "$1")")
	fi
}
