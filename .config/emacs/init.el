;; elpaca
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; install use-package support
(elpaca elpaca-use-package
  ;; enable use-package :ensure support for elpaca.
  (elpaca-use-package-mode))

;; emacs
(use-package emacs
  :demand t
  :custom
  (x-stretch-cursor t))

;; theme
(load-theme 'modus-operandi-tinted t)
(enable-theme 'modus-operandi-tinted)
(setopt modus-themes-common-palette-overrides
	'((bg-main "#f3ead3")
	  (fg-dim "#939f91")
	  (builtin fg-main) ;code mappings
	  (comment fg-dim)
	  (constant fg-main)
	  (docmarkup fg-main)
	  (docstring fg-main)
	  (fnname fg-main)
	  (keyword fg-main)
	  (preprocessor fg-main)
	  (rx-backslash fg-main)
	  (rx-construct fg-main)
	  (string fg-main)
	  (type fg-main)
	  (variable fg-main)
	  (fg-heading-0 fg-main)
	  (fg-heading-1 fg-main)
	  (fg-heading-2 fg-main)
	  (fg-heading-3 fg-main)
	  (fg-heading-4 fg-main)
	  (fg-heading-5 fg-main)
	  (fg-heading-6 fg-main)
	  (fg-heading-7 fg-main)
	  (fg-heading-8 fg-main)
	  (fg-link fg-main) ;link mappings
	  (underline-link fg-main)
	  (bg-paren-match unspecified) ;paren match
	  (fg-paren-match yellow-intense)))
(custom-set-faces
 '(font-lock-keyword-face ((t (:weight bold))))
 '(font-lock-string-face ((t (:underline t)))))

(use-package treesit
  :ensure nil
  :init
  (add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
  (add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-mod-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode)))

;; lsp
(use-package eglot
  :ensure nil
  :hook ((go-ts-mode . eglot-ensure)
	 (rust-ts-mode . eglot-ensure))
  :config
  (add-hook 'before-save-hook
	    (lambda()
	      (call-interactively 'eglot-code-action-organize-imports))
	    nil t))

;; irc
(use-package erc
  :ensure nil
  :config
  (add-to-list 'erc-modules 'notifications)
  (setq erc-server "irc.oftc.net"
	erc-nick "sfyatee"))

;; sq
(use-package sq :ensure t)

;; got
(use-package vc-got :ensure t)

;; vc
(add-hook 'log-edit-mode-hook
	  (lambda () (setq fill-column 68)
	    (auto-fill-mode 1)))
(add-hook 'log-edit-mode-hook
	  (lambda () (setq display-fill-column-indicator-column 69)
	    (display-fill-column-indicator-mode 1)))
