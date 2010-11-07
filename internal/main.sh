### internal/main.sh -- command line arguments
###
### Part of qlbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/qlbuild || exit 1

###

command=$1
shift
case $command in
    rm-cores)
	rm_cores
        ;;
    lisp)
	ensure_quicklisp_core
        run_lisp_with_core "$@"
        ;;
    prepl)
	source $internal/prepl.sh
	ensure_prepl_core
        run_lisp_with_core "$@" $eval "(hemlock:repl)"
        ;;
    slime)
	ensure_quicklisp_core
	emacs_args="$@"
	emacs=${EMACS-emacs}
	write_slime_configuration >"$base/.start-slime.el"
	ensure_slime
	$emacs -l "$base/.start-slime.el" ${emacs_args}
	;;
    slime-configuration)
	echo ';; add this to your ~/.emacs to use qlbuild and its slime:'
	echo ';;'
	write_slime_configuration
	;;
    pwd)
	echo $base
	;;
    quickload)
	ensure_quicklisp_core
        quickload "$@"
        ;;
    update-all-dists)
	update_all_dists
        ;;
    update-client)
	update_client
	;;
    help|-H|""|--help|-h|--long-help)
	source $internal/help.sh
	help
	;;
    compile-implementation)
	rm_cores
	compile_implementation
	;;
    clbuild)
	. $internal/get-misc.sh
	. $internal/download.sh
	clbuild $*
	;;
    trash)
	. $internal/get-misc.sh
	. $internal/download.sh
	if test $# -lt 1; then
	    echo 'usage: $1 [PROJECT...]'
	    exit 1
	fi
	while test $# -ge 1; do
	    d="$source_dir/$1"
	    if test -d "$d"; then
		trash "$d"
		clean_links "quiet"
	    else
		echo "cannot trash non-existing directory $d"
	    fi
	    shift
	done
	;;
    *)
	echo "invalid command $command, try --help for help"
	exit 1
esac
