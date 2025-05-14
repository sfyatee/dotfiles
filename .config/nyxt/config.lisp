;;; Loading files from the same directory.
(define-nyxt-user-system-and-load nyxt-user/basic-config
  :components ("tor"))

;;; Loading extensions and third-party-dependent configs. See the
;;; matching files for where to find those extensions.
(defmacro defextsystem (system &optional file)
  "Helper macro to load configuration for extensions.
Loads a newly-generated ASDF system depending on SYSTEM.
FILE, if provided, is loaded after the generated system successfully
loads."
  `(define-nyxt-user-system-and-load ,(gensym "NYXT-USER/")
     :depends-on (,system) ,@(when file
                               `(:components (,file)))))
