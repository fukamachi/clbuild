### internal/slime.sh -- slime stuff
###
### Part of clbuild, a wrapper script for Lisp invocation with quicklisp
### preloaded.  Based on code from clbuild by Luke Gorrie and
### contributors.

test -f $base/clbuild || exit 1

###
### write_slime_configuration
###

write_slime_configuration() {
    if test -n "$START_SLIME_USING_CORE"; then
	cmd=preloaded
    else
	cmd=lisp
    fi
    cat <<EOF

;; possibly controversial as a global default, but shipping a lisp
;; that dies trying to talk to slime is stupid, so:
(set-language-environment "UTF-8")
(setq slime-net-coding-system 'utf-8-unix)

(load (expand-file-name "~/quicklisp/slime-helper.el"))
(require 'slime)

;;; old clbuild code following, most of it now unneeded
;;; (setq load-path (cons "${source_namestring}slime" load-path))
;;; (setq load-path (cons "${source_namestring}slime/contrib" load-path))
;;; (setq slime-backend "$base/.swank-loader.lisp")
(setq inhibit-splash-screen t)
;;; (load "${source_namestring}slime/slime")
(setq inferior-lisp-program "$base/clbuild $cmd")
(slime-setup '(slime-fancy slime-tramp slime-asdf))
(slime-require :swank-listener-hooks)
(slime)

EOF
#     # while we're at it, also write the swank loader
#     cat >$base/.swank-loader.lisp <<EOF
# (unless (find-package 'swank-loader)
#   (load "$slime_dir/swank-loader.lisp"))
# EOF
}

ensure_slime() {
    ensure_project slime swank
    ensure_project quicklisp-slime-helper
}
