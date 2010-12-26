;;; internal/user.lisp -- usercore.conf parsing code
;;;
;;; Part of clbuild, a wrapper script for Lisp invocation with quicklisp
;;; preloaded.  Based on code from clbuild by Luke Gorrie and
;;; contributors.

(in-package :clbuild)

(defun parse-usercore.conf (pathname)
  (with-open-file (s pathname :if-does-not-exist nil)
    (if s
	(values (remove ""		;no iterate here :-(
			(loop
			   for line = (read-line s nil)
			   while line
			   collect (string-trim
				    " "
				    (let ((pos (position #\# line)))
				      (if pos
					  (subseq line 0 pos)
					  line))))
			:test 'equal)
		t)
	(values nil nil))))

(defun process-usercore.conf (pathname)
  (fresh-line)
  (terpri)
  (multiple-value-bind (entries foundp)
      (parse-usercore.conf pathname)
    (cond
      ((not foundp)
       (format t "*** File ~A not found.~%" (namestring pathname))
       (format t "*** user.core will not differ from base.core.~%")
       (format t "*** Dumping it anyway.~%"))
      ((null entries)
       (format t "*** File ~A is empty.~%" (namestring pathname))
       (format t "*** user.core will not differ from base.core.~%")
       (format t "*** Dumping it anyway.~%"))
      (t
       (dolist (entry entries)
	 (format t "*** quickloading ~A.~%" entry)
	 (ql:quickload entry)))))
  (force-output))

(defun %process-usercore.conf (base-directory)
  (process-usercore.conf (merge-pathnames "usercore.conf" base-directory)))
