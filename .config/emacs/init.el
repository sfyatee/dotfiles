;; sq
;; (use-package sq :ensure t)

;; got
;; (use-package vc-got :ensure t)

;; vc
(add-hook 'log-edit-mode-hook
	  (lambda () (setq fill-column 68)
	    (auto-fill-mode 1)))
(add-hook 'log-edit-mode-hook
	  (lambda () (setq display-fill-column-indicator-column 69)
	    (display-fill-column-indicator-mode 1)))
