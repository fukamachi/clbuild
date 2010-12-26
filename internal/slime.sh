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
    cmd=lisp
    cat <<EOF

;; possibly controversial as a global default, but shipping a lisp
;; that dies trying to talk to slime is stupid, so:
(set-language-environment "UTF-8")
(setq slime-net-coding-system 'utf-8-unix)

(load (expand-file-name "~/quicklisp/slime-helper.el"))
(require 'slime)

(setq inhibit-splash-screen t)
(setq inferior-lisp-program "$base/clbuild $cmd")
(slime-setup '(slime-fancy slime-tramp slime-asdf))
(slime-require :swank-listener-hooks)
(slime)

EOF
}

ensure_slime() {
    ensure_project slime swank
    ensure_project quicklisp-slime-helper
}
