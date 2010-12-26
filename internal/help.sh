### internal/slime.sh -- print help
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

###


help() {
	cat <<EOF
Usage:
  $0 COMMAND [ARGS...]

Commands are:

  Software installation and quicklisp interaction:

    quickload SYSTEM        ensure that SYSTEM has been downloaded
    system-list             list systems available through quicklisp
    system-apropos FOO      list systems matching FOO
    update-all-dists        update all dists downloaded using quicklisp
    update-dist DIST        update this dist
    update-client           update the quicklisp client

  Software installation from version control (overrides quicklisp):

    install-from-upstream PROJECT...   install projects from upstream
    upstream-list           list projects available from upstream
    upstream-apropos FOO    list projects matching FOO
    trash PROJECT...        remove project

  Lisp invocation:

    prepl                   run Lisp on the terminal (with line editing)
    lisp                    run Lisp on the terminal (raw)
    slime                   run Lisp (using Emacs and SLIME)

  Housekeeping and utilities:

    rm-cores                clean out previously dumped core files
    slime-configuration     show information on how clbuild starts slime
    help                    this help
    compile-implementation  compile SBCL

Important configuration files:

  clbuild.conf  (make a copy of  clbuild.conf.example and edit it)
  conf.lisp     (make a copy of     conf.lisp.example and edit it)
  usercore.conf (make a copy of usercore.conf.example and edit it)
EOF
}
