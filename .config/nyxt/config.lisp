(in-package #:nyxt-user)

(defvar *web-buffer-modes*
  '(:emacs-mode
    :blocker-mode :force-https-mode
    :reduce-tracking-mode
    :user-script-mode :bookmarklets-mode)
  "The modes to enable in any web-buffer by default.
Extension files (like dark-reader.lisp) are to append to this list.

Why the variable? Because it's too much hassle copying it everywhere.")

;;; Loading files from the same directory.
(define-nyxt-user-system-and-load nyxt-user/basic-config
  :components ("status"))

(define-configuration :web-buffer
  "Basic modes setup for web-buffer."
  ((default-modes `(,@*web-buffer-modes* ,@%slot-value%))))

(define-configuration :nosave-buffer
  "Enable proxy in nosave (private, incognito) buffers."
  ((default-modes `(:proxy-mode ,@*web-buffer-modes* ,@%slot-value%))))
