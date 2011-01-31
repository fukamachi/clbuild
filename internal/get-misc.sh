### internal/get-misc.sh -- various old clbuild routines for VC interaction
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

###

blank_line="                                                                  "
tail_last() {
    if tty 0>&1 >/dev/null; then
	while read line; do
	    echo -e '\r\c'
	    echo -n "$blank_line"
	    echo -e '\r\c'
	    echo -n $line | cut -b 1-65 | tr -d '\n'
	done
	echo -e '\r\c'
	echo -n "$blank_line"
	echo -e '\r\c'
    else
	while read line; do
	    echo $line
	done
    fi
}

dribble_get() {
    label="$1"
    name="$2"

    if [ -d $name ]; then
	echo -n "UPDATE "
    else
	echo -n "NEW "
    fi
    echo "$label $name"
}

darcs_record_import() {
    local name="$1"
    local url="$2"

    IMPORT_MESSAGE="Imported $name from $url on $(date)"

    darcs record -a -l -A clbuild -m "$IMPORT_MESSAGE"
}

dry_run_ok() {
   if test -n "$dry_run"; then
       echo "OK: $1"
   fi
}

dry_run_missing() {
   if test -n "$dry_run"; then
       echo "MISSING: $1"
   fi
}

get_hg() {
    local name="$1"
    local url="$2"

    if [ -d $name ]; then
	local actual=$(cd $name && hg showconfig paths.default)
	if [ "x$actual" = "x$url" ]; then
	    dry_run_ok $name
	else
	    echo "MISMATCH: $name was installed from $actual, current is $url"
	fi
    else
	dry_run_missing $name
    fi
    if [ -n "$dry_run" ]; then
	exit 0
    fi

    if [ -d $name ]; then
	dribble_get "hg pull" $name
	(
	    cd $name
	    if [ ! -d ".hg" ]; then
		echo "ERROR: not a mercurial repository"
		exit 1
	    fi
	    hg pull --update
	    )
    else
	dribble_get "hg clone" $name
	hg clone $url $name
    fi
}

get_darcs() {
    name="$1"
    url="$2"

    if [ -d $name ]; then
	actual="`cat $name/_darcs/prefs/defaultrepo`"
	if test "x$actual" = "x$url"; then
	    dry_run_ok $1
	else
	    echo "MISMATCH: $1 was installed from $actual, current is $url"
	fi
    else
	dry_run_missing $1
    fi
    if test -n "$dry_run"; then
	exit 0
    fi

    # don't use tail_last, since darcs already has this kind of progress bar
    if [ -d $name ]; then
	dribble_get "darcs pull" $name
	(
	    cd $name
	    if ! test -d _darcs; then
		echo ERROR: not a darcs repository
		exit 1
	    fi
	    darcs pull --all
	    )
    else
	dribble_get "darcs get" $name
	darcs get --lazy $url $name
    fi
}

get_git() {
    name="$1"
    url="$2"

    if [ -d $name ]; then
	actual="`cd $name && git config --get remote.origin.url`"
	if test "x$actual" = "x$url"; then
	    dry_run_ok $1
	else
	    echo "MISMATCH: $1 was installed from $actual, current is $url"
	fi
    else
	dry_run_missing $1
    fi
    if test -n "$dry_run"; then
	exit 0
    fi

    if [ -d $name ]; then
	dribble_get "git pull" $name
	(
	    cd $name
	    if ! test -d .git; then
		echo ERROR: not a git repository
		exit 1
	    fi
	    git pull
	    )
    else
	dribble_get "git clone" $name
	git clone $url $name
    fi
}

get_svn() {
    name="$1"
    url="$2"

    if [ -d $name ]; then
	actual="`cd $name && svn info | grep ^URL: | awk '{print $2;}'`"
	if test "x$actual" = "x$url"; then
	    dry_run_ok $1
	else
	    echo "MISMATCH: $1 was installed from $actual, current is $url"
	fi
    else
	dry_run_missing $1
    fi
    if test -n "$dry_run"; then
	exit 0
    fi

    dribble_get "svn co" $name

    svn co $url $name | tail_last
}

get_cvs_aux() {
    module="$1"
    repository="$2"
    target_directory="$3"

    if [ -d $module ]; then
	actual="`cat $module/CVS/Root`"
	if test "x$actual" = "x$repository"; then
	    dry_run_ok $1
	else
	    echo "MISMATCH: $1 was installed from $actual, current is $repository"
	fi
    else
	dry_run_missing $1
    fi
    if test -n "$dry_run"; then
	exit 0
    fi

    dribble_get "cvs co" $module

    cvs -d $repository co ${3+-d "$3"} $module | tail_last
}

get_cvs_full() {
    get_cvs_aux $3 $2 $1
}

get_tarball() {
    local name="$1"
    local url="$2"
    local flags="${3:-z}"

    if [ -d $name ]; then
	dry_run_ok $name
    else
	dry_run_missing $name
    fi
    if [ -n "$dry_run" ]; then
	exit 0
    fi

    # if repository does not exist, then create and populate one
    if [ ! -d "$name/_darcs" ]; then
       	(
	    darcs init --repodir=$name
	    cd $name
	    darcs_record_import $name $url
	    )
    fi

    # pull repository into temporary directory
    dribble_get "wget" $name
    (
	local tmp="${name}.tar.gz"

	cd $TMPDIR

	# clone the original directory
	darcs get "${source_dir}/${name}"

	wget \
	    --no-check-certificate \
	    --progress=dot \
	    -O "$tmp" \
	    $url \
	    2>&1 | tail_last
	tar v${flags}xf "$tmp" | tail_last
	rm $tmp

	# if directory names differ, copy into main directory
	local other_dir=$(echo ${name}?*/ | awk '{print $1}')
	if [ -d $other_dir ]; then
	    cp -R ${other_dir}* $name
	fi
	)

    # record any changes and pull back into original directory
    (
	cd $TMPDIR/$name
	darcs_record_import $name $url
	darcs push -a -p "$IMPORT_MESSAGE" "$source_dir/$name"
	)
}

get_svn_clnet() {
    name="$1"
    path="$2"

    get_svn $name svn://common-lisp.net/project/$name/svn/$2
}

get_cvs_clnet() {
    module="$1"
    project="${2:-$1}"

    get_cvs_aux $module ${CLNET_USER:-:pserver:anonymous:anonymous}@common-lisp.net:/project/$project/cvsroot
}

get_cvs_clnet_full() {
    clbuildproject="$1"
    clnetproject="${2:-$1}"
    path="$3"

    get_cvs_aux $path ${CLNET_USER:-pserver:anonymous:anonymous}@common-lisp.net:/project/$clnetproject/cvsroot $clbuildproject
}

get_cvs_sfnet() {
    module="$1"
    project="${2:-$1}"

    get_cvs_aux $module ${SF_USER}@$project.cvs.sourceforge.net:/cvsroot/$project
}

get_ediware() {
    get_darcs $1 http://common-lisp.net/~loliveira/ediware/$1
}

get_clbuild_mirror() {
    get_darcs $1 http://common-lisp.net/project/clbuild/mirror/$1
}

get_tarball_bz2() {
    get_tarball "$1" "$2" j
}

get_github() {
    project="$1"
    user="$2"
    repo="${3:-$1}"
    if test "$GITHUB_USER" = $user; then
        if test -n "$GITHUB_USE_HTTP"; then
            get_git $project https://$user@github.com/$user/$repo.git
        else
            get_git $project git@github.com:$user/$repo.git
        fi
    else
        if test -n "$GITHUB_USE_HTTP"; then
            get_git $project http://github.com/$user/$repo.git
        else
            get_git $project git://github.com/$user/$repo.git
        fi
    fi
}
