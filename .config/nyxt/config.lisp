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

(define-configuration :nosave-buffer
  "Enable proxy in nosave (private, incognito) buffers."
  ((default-modes `(:proxy-mode ,@*web-buffer-modes* ,@%slot-value%))))

(define-configuration :status-buffer
  "Display modes as short glyphs."
  ((glyph-mode-presentation-p t)))

(define-configuration :force-https-mode ((glyph "ϕ")))
(define-configuration :user-script-mode ((glyph "u")))
(define-configuration :blocker-mode ((glyph "β")))
(define-configuration :proxy-mode ((glyph "π")))
(define-configuration :reduce-tracking-mode ((glyph "τ")))
(define-configuration :certificate-exception-mode ((glyph "χ")))
(define-configuration :style-mode ((glyph "ϕ")))
(define-configuration :cruise-control-mode ((glyph "σ")))

; (defmethod format-status-load-status ((status status-buffer))
;   "A fancier load status."
;   (spinneret:with-html-string
;    (:span (if (and (current-buffer)
;                    (web-buffer-p (current-buffer)))
;               (case (slot-value (current-buffer) 'nyxt::status)
;                     (:unloaded "∅")
;                     (:loading "∞")
;                     (:finished ""))
;             ""))))

(define-configuration :status-buffer
  ((height 36)
   (style
    (theme:themed-css (theme *browser*)
      `(*
        :font-size "11px")
      `(body
        :margin "9px"
        :margin-top "11px")
      `("#container"
        :display "flex"
        :white-space "nowrap"
        :overflow "hidden")
      `("#vi-mode, #buffers, #load, #percentage, #url, .tab, #minions, #modes"
        :padding-left "9px")
      `("#modes"
        :color "#a2a9b0")
      `(button
        :all "unset")
      `((:and (:or .button .tab "#url") :hover)
        :font-weight "bold"
        :cursor "pointer")))))
