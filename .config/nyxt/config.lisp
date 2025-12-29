(defvar *web-buffer-modes*
  '(:emacs-mode
    :blocker-mode :force-https-mode
    :reduce-tracking-mode
    :user-script-mode :bookmarklets-mode)
  "The modes to enable in any web-buffer by default.
Extension files (like dark-reader.lisp) are to append to this list.

Why the variable? Because it's too much hassle copying it everywhere.")

(define-configuration :web-buffer
  "Basic modes setup for web-buffer."
  ((default-modes `(,@*web-buffer-modes* ,@%slot-value%))))

(define-configuration :force-https-mode ((glyph "ϕ")))
(define-configuration :user-script-mode ((glyph "u")))
(define-configuration :blocker-mode ((glyph "β")))
(define-configuration :proxy-mode ((glyph "π")))
(define-configuration :reduce-tracking-mode ((glyph "τ")))
(define-configuration :certificate-exception-mode ((glyph "χ")))
(define-configuration :style-mode ((glyph "ϕ")))
(define-configuration :cruise-control-mode ((glyph "σ")))
