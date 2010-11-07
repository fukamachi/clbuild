;;; internal/asdf-setup.lisp -- ASDF setup stuff
;;;
;;; Part of qlbuild, a wrapper script for Lisp invocation with quicklisp
;;; preloaded.  Based on code from clbuild by Luke Gorrie and
;;; contributors.

;;; At this point, quicklisp already been set up.  We count on quicklisp
;;; to load the right version of ASDF.

(defpackage clbuild
  (:use)
  (:export "FIX-CENTRAL-REGISTRY"))

;;;;
;;;; central registry
;;;;

;; In good old clbuild tradition, we clean out all the annoying ~/.sbcl
;; and *d-p-d* junk from the central registry, which usually only
;; conflicts with clbuild and quicklisp for no good reason.
;;
(defun clbuild:fix-central-registry (base-dir)
  (setf asdf:*central-registry*
	(cons (merge-pathnames "systems/" base-dir)
	      (remove-if-not (lambda (x)
			       (let ((y (namestring (eval x))))
				 (search "quicklisp" y)))
			     asdf:*central-registry*))))


;;;;
;;;; source registry
;;;;

;; Only that these days, we also need to clean out the mess found in the
;; source registry, which still contains #+sbcl ~/.sbcl and related
;; insanities.
;;
(setf (asdf::source-registry)
      (remove-if-not (lambda (x)
		       ;; argh!  Contribs used to have their own system
		       ;; definition search function, but it appears
		       ;; that upgrading to new ASDF nukes those and
		       ;; goes through the the source registry instead?
		       (or #+sbcl (search "/sb-" (namestring x))))
		     (asdf::source-registry)))
