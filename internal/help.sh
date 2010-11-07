### internal/slime.sh -- print help
###
### Part of qlbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/qlbuild || exit 1

###


help() {
	cat <<EOF
Usage:
  $0 COMMAND [ARGS...]

Commands are:

  Software installation and quicklisp interaction:

    quickload SYSTEM        ensure that SYSTEM has been downloaded
    update-all-dists        update sources downloaded using quicklisp
    update-client           update the quicklisp client

  Software installation from version control (overrides quicklisp):

    clbuild PROJECT...      install projects
    trash PROJECT...        remove project

  Lisp invocation:

    slime                   run Lisp (using Emacs and SLIME)
    lisp                    run Lisp (using the terminal)
    prepl                   run Lisp (with prepl; experimental)

  Housekeeping and utilities:

    rm-cores                clean out previously dumped core files
    slime-configuration     show information on how qlbuild starts slime
    help                    this help
    compile-implementation  compile SBCL
EOF
}
