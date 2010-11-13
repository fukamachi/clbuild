### internal/download.sh -- the old heart of clbuild
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

###

source_dir=$base/source
system_dir=$base/systems

# The committed "projects" file, and optionally "my-projects".
PROJECT_LISTING_FILES="$base/projects"
if test -f "$base/my-projects"; then
    PROJECT_LISTING_FILES="$base/my-projects $PROJECT_LISTING_FILES"
fi

install_from_upstream() {
        TMPDIR=`mktemp -d /tmp/clbuild.XXXXXXXXXX`
	export TMPDIR

        cleanup() {
	    if test -n "$TMPDIR"; then
		echo clbuild: something went wrong, cleaning up
		rm -rf $TMPDIR
	    fi
        }
        trap cleanup EXIT

	cd "$source_dir"

	for project in $*; do
	    get_project $project
	    register_asd $project
	done

	link_extra_asds
	count_systems
        cd ..

	cat <<EOF
update complete.

Note: clbuild does not install dependencies automatically.
Run
EOF
	for x in $*; do
	    echo "  clbuild quickload $x"
	done
	cat <<EOF
to install any dependencies using quicklisp.
EOF

	rm -rf $TMPDIR
	unset TMPDIR
}


get_project() {
    if ! grep -h "^$1 " $PROJECT_LISTING_FILES >/dev/null; then
       echo Error: cannot download unknown project $1
       exit 1
    fi
    found=`grep -h "^$1 " $PROJECT_LISTING_FILES | cut -d\# -f1`
    get_project_2 $found
}

get_project_2() {
    name="$1"
    action="$2"
    shift
    shift
    ( $action $name "$@" )
}

register_asd() {
    local project="$1"
    local quiet="$2" # any value will stop printing the linked .asd files
    local dir="source/$project"

    register_all_asd_in_path $dir $quiet
}

register_other_asd() {
    local path="source/$1"
    local quiet="quiet"
    local abspath="$base/$path"

    # Test if path given is not a globbed pattern
    if [ -f "$abspath" ]; then
	local name="$2"
	register_single_asd $path ${quiet:-""} $name
    elif [ -d "$abspath" ]; then
	# use given directory to register .asd files
	register_all_asd_in_path $path $quiet
    elif [ "$abspath" == "$(echo $abspath)" ]; then
        # if pattern and expansion are identical, globbing failed
	if [ -z $quiet ]; then
	    echo "Ignoring invalid path: $path"
	fi
    else
	# path must be a valid pattern so register *.asd for each directory
	for path in $(relative_glob "$path"); do
	    if [ -d $path ]; then
		register_all_asd_in_path $path $quiet
	    fi
	done
    fi
}

register_single_asd() {
    local asd_file="$1"
    local quiet="$2" # any value will stop printing the linked .asd files
    local name="$3"  # optionally provide a different name for link

    : ${name:=$(basename $asd_file)} # default to the name of the asd file

    if [ -f "$base/$asd_file" ]; then
	if [ -z $quiet ]; then
	    echo "$asd_file"
	fi
	register_single_asd_as $name $asd_file
    fi
}

register_single_asd_as() {
    local name="$1"
    local asd_file="$2"

    ln -f -s "../$asd_file" "${system_dir}/${name}"
}

link_extra_asds() {
    # some (buggy) projects try to hide their .asd files from us:
    register_other_asd mcclim/Experimental/freetype
    register_other_asd iolib/src
    register_other_asd editor-hints/named-readtables
    register_other_asd "graphic-forms/src/external-libraries/*/*"
    register_other_asd "clg/*"
    register_other_asd "swf2/*"
    register_other_asd eclipse/system.lisp eclipse.asd
}

count_systems() {
    if test $system_dir/*.asd = $system_dir/'*.asd'; then
	echo 0 system definition files registered
    else
	n_asd=`ls -1 "$system_dir"/*.asd | wc -l`
	echo "$n_asd system definition files registered"
    fi
}

relative_glob() {
    cd "$base"
    echo $1
}

register_all_asd_in_path() {
    local path="$1"
    local quiet="$2"

    for file in $(relative_glob "$path/*.asd"); do
	register_single_asd $file $quiet
    done
}

trash() {
    basename=`basename $1`
    today=`date +'%Y-%m-%d'`
    trash="$base/trash/$today"
    if test -e "$trash"; then
	if test -e "$trash/$basename"; then
	    trash=`mktemp -d $base/trash/${today}_${basename}_XXXXXXXXXX`
	fi
    else
	mkdir $trash
    fi
    echo moving "$1" to "$trash/$basename"
    mv "$1" "$trash"
}

clean_links() {
    cd $base/systems
    local quiet="$1"
    for link in $(find "$base/systems" -maxdepth 1 -type l); do
	local link_target=$(readlink "$link")
	if [ ! -e $link_target ]; then
	    if [ -z $quiet ]; then
		echo "removing broken link from $link to $link_target"
	    fi
	    rm -- "$link"
	fi
    done
}

upstream_list() {
    pattern="${1:-.}"

    TMPDIR=`mktemp -d /tmp/clbuild.XXXXXXXXXX`
    export TMPDIR
    
    cleanup() {
        rm -rf $TMPDIR
    }
    trap cleanup EXIT

    cat $PROJECT_LISTING_FILES \
	| sort \
	| grep -i -E "$pattern" \
	| while read project rest
    do
	if test -n "$project" -a x"$project" != 'x#'; then
	    description=`echo $rest | cut -d\# -f2`
	    echo "$status $project" >>$TMPDIR/left
	    echo $description >>$TMPDIR/right
	fi
    done
    paste $TMPDIR/left $TMPDIR/right | expand -t 25
}
