### internal/ql.sh -- clbuild/quicklisp integration code
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1


###
### find quicklisp
###

qldir="$(echo ~/quicklisp)"
ql_setup_lisp=$qldir/setup.lisp
ql_core="$base"/$LISP_IMPLEMENTATION_TYPE-base.core

###
### project name to project directory lookup
###

find_project() {
    tramp=$qldir/dists/quicklisp/installed/releases/$1.txt
    if test -f "$tramp"; then
	cat "$tramp"
    fi
}

install_quicklisp() {
    qlidir="$base/quicklisp-installer"
    qli="$qlidir/quicklisp.lisp"
    mkdir -p "$qlidir"
    wget -O "$qli" http://beta.quicklisp.org/quicklisp.lisp
    init_asdf_1='(progn)'
    init_asdf_2='(progn)'
    echo "$quit" | \
	run_lisp_raw \
	$eval "(load \"$qli\")" \
	$eval "(progn (quicklisp-quickstart:install) $quit)"
}

ensure_quicklisp() {
    if ! test -f "$ql_setup_lisp"; then
	echo clbuild: quicklisp not found, installing it now... 
	install_quicklisp
	echo clbuild: done installing quicklisp
    fi
}

quickload() {
    if ! test -f "$ql_setup_lisp"; then
	exec 2>&1
	echo "quicklisp not found in ~/quicklisp"
	exit 1
    fi
    echo "$quit" | run_lisp_with_ql $eval "(ql:quickload \"$1\")"
}

# fixme: replace with ensure_system and system_name_to_project_name
ensure_project() {
    project=$1
    system=${2:-$project}
    if  test -z $(find_project $project); then
	echo $project not found, installing now
	quickload $system
    fi
}

ensure_quicklisp_core() {
    ensure_quicklisp
    if ! (valid_core_p "$ql_core"); then
	echo clbuild: no valid core file $ql_core, dumping now...
	dump_core "$ql_core"
	echo clbuild: done dumping the core file
    elif test $ql_setup_lisp -nt $ql_core; then
	echo clbuild: Warning: $ql_setup_lisp is newer than $ql_core.
	echo consider running clbuild rm-cores
    fi
    with_core_options="$core_option $ql_core $common_options"
}

update_all_dists() {
    if ! test -f "$ql_setup_lisp"; then
	echo quicklisp not found, nothing to update
	exit 1
    fi
    rm_cores
    echo "$quit" | run_lisp_with_ql $eval "(ql:update-all-dists)"
}

update_dist() {
    if ! test -f "$ql_setup_lisp"; then
	echo quicklisp not found, nothing to update
	exit 1
    fi
    rm_cores
    echo "$quit" | run_lisp_with_ql $eval "(ql:update-dist \"$1\")"
}

update_client() {
    if ! test -f "$ql_setup_lisp"; then
	echo quicklisp not found, nothing to update
	exit 1
    fi
    rm_cores
    echo "$quit" | run_lisp_with_ql $eval "(ql:update-client)"
}

quicklisp_system_list() {
    echo "$quit" | run_lisp_with_ql $eval "(print (ql:system-list))"
}

quicklisp_system_apropos() {
    echo "$quit" | run_lisp_with_ql $eval "(print (ql:system-apropos \"$1\"))"
}
