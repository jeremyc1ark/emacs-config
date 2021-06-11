(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("org"       . "http://orgmode.org/elpa/")
			 ("gnu"       . "http://elpa.gnu.org/packages/")
			 ("MELPA Stable"     . "https://stable.melpa.org/packages/")))

(setq use-package-always-ensure t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(setq straight-use-package-by-default t)

(when window-system
  (set-frame-position (selected-frame) -1 -1)
  (set-frame-size (selected-frame) 140 120))

(menu-bar-mode -1)
(tool-bar-mode -1) 
(blink-cursor-mode -1)
(scroll-bar-mode -1)
(global-hl-line-mode 1) 
(global-visual-line-mode 1)

(setq coding-system-for-read 'utf-8
      coding-system-for-write 'utf-8
      default-file-name-coding-system 'utf-8
      ring-bell-function 'ignore ;; disable the sound of hell
      inhibit-startup-screen +1
      make-backup-files -1
      sentence-end-double-space nil
      default-fill-column 80)		

(set-language-environment 'utf-8)      
(prefer-coding-system 'utf-8)   
(set-default-coding-systems 'utf-8)                                                         
(set-terminal-coding-system 'utf-8)                                                         
(set-keyboard-coding-system 'utf-8)    

;; Treat clipboard input as UTF-8 string first; compound text next, etc.                    
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

(setq user-full-name "Jeremy Clark"
      user-mail-address "jeremyclark456@gmail.com")

(use-package solarized-theme :straight t)
(add-hook 'after-init-hook (lambda () (load-theme 'solarized-light :NO-CONFIRM t)))

(use-package general
  :config (general-evil-setup))
(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-popup-type 'minibuffer))

(defconst jc/global-leader "SPC")
(defconst jc/global-non-normal-leader "C-SPC")
(defconst jc/major-mode-leader ",")
(defconst jc/major-mode-non-normal-leader "C-c")

(defun jc/mode-names->map-names (mode-names)
	 (if mode-names
	     (mapcar (lambda (mode) (intern (concat (symbol-name mode) "-map"))) mode-names)
	    'global-map))

(defun jc/general-key-definer (modes leader non-normal-leader &rest bindings)
  (let ((key (pop bindings))
	(cmd (pop bindings)))
    (while key
      (general-define-key :states '(normal visual insert)
			  :keymaps (jc/mode-names->map-names modes)
			  :prefix leader
			  :non-normal-prefix non-normal-leader
			  key cmd)
      (setq key (pop bindings)
	    cmd (pop bindings)))))

(defun jc/global-definer (&rest bindings)
  (apply 'jc/general-key-definer (append (list nil
					    jc/global-leader
					    jc/global-non-normal-leader)
				      bindings)))

(defun jc/minor-mode-definer (modes &rest bindings)
  (apply 'jc/general-key-definer (append (list modes
					    jc/global-leader
					    jc/global-non-normal-leader)
				      bindings)))

(defun jc/major-mode-definer (modes &rest bindings)
  (apply 'jc/general-key-definer (append (list modes
					    jc/major-mode-leader
					    jc/major-mode-non-normal-leader)
				      bindings)))

(defun jc/general-group-definer (modes leader non-normal-leader group-key group-name &rest bindings)
   (defun jc/define-key-under-group (key cmd alias)
      (jc/general-key-definer modes
			   leader
			   non-normal-leader
			   (format "%s%s" group-key key)
			   (list cmd :which-key alias)))
	  (jc/general-key-definer modes leader non-normal-leader group-key (list :ignore t :which-key group-name))
	  (let ((current-binding (pop bindings)))
	    (while current-binding
	      (let ((key (pop current-binding))
		    (cmd (pop current-binding))
		    (alias (if current-binding (pop current-binding) (symbol-name cmd))))
		(jc/define-key-under-group key cmd alias)
		(setq current-binding (pop bindings))))))

(defun jc/make-major-mode-key-group (group-key group-name modes &rest bindings)
  (apply 'jc/general-group-definer (append (list modes
					      jc/major-mode-leader
					      jc/major-mode-non-normal-leader
					      group-key
					      group-name)
					bindings)))

(defun jc/make-minor-mode-key-group (group-key group-name modes &rest bindings)
  (apply 'jc/general-group-definer (append (list modes
					      jc/global-leader
					      jc/global-non-normal-leader
					      group-key
					      group-name)
					bindings)))

(defun jc/make-global-key-group (group-key group-name &rest bindings)
  (apply 'jc/general-group-definer (append (list nil
					      jc/global-leader
					      jc/global-non-normal-leader
					      group-key
					      group-name)
					bindings)))

(defun jc/reload-config ()
  (interactive)
  (org-babel-load-file jc/literate-config-file-location))

(defconst jc/init-file-location "~/.emacs.default/init.el")
(defconst jc/literate-config-file-location "~/.emacs.default/config.org")
(defun jc/open-init-file ()
  (interactive)
  (switch-to-buffer (find-file-noselect jc/init-file-location)))
(defun jc/open-literate-config-file ()
  (interactive)
  (switch-to-buffer (find-file-noselect jc/literate-config-file-location)))
(jc/make-global-key-group "f" "Files"
			  (list "f" 'find-file "Find file")
			  (list "c" 'copy-file "Copy file")
			  (list "D" 'delete-file "Delete file")
			  (list "R" 'rename-file "Rename file")
			  (list "s" 'save-buffer "Save buffer")
			  (list "i" 'jc/open-init-file "Open init file")
			  (list "l" 'jc/open-literate-config-file "Open literate config")
			  (list "r" 'jc/reload-config "Reload config file"))

(jc/global-definer "SPC" (list 'execute-extended-command :which-key "Execute command"))

(use-package window-numbering
  :straight t
  :init (window-numbering-mode +1)
  :config (setq windmove-wrap-around t)) ;; Makes windows continuous like Pac Man


(defun jc/switch-to-window-with-number (arg)
  (interactive "sWindow to switch to: ")
  (select-window-by-number (string-to-number arg)))
(jc/make-global-key-group "w" "Window"
		       (list "h" 'windmove-left "Move left")
		       (list "j" 'windmove-down "Move down")
		       (list "k" 'windmove-up "Move up")
		       (list "l" 'windmove-right "Move right")
		       (list "d" 'delete-window "Delete window")
		       (list "s" 'split-window-vertically "Split vertical")
		       (list "v" 'split-window-horizontally "Split horizontal")
		       (list "n" 'jc/switch-to-window-with-number "Select window by number")
		       (list "b" 'previous-buffer "Previous buffer"))

(jc/make-global-key-group "b" "Buffer"
			  (list "b" 'switch-to-buffer "Go to buffer")
			  (list "x" 'kill-this-buffer "Kill buffer")
			  (list "r" 'rename-buffer "Rename buffer")
			  (list "p" 'previous-buffer "Previous buffer")
			  (list "n" 'next-buffer "Next buffer"))

(use-package yasnippet
       :ensure t
       :init
       (yas-global-mode 1)
       :config
       (add-to-list 'yas-snippet-dirs (locate-user-emacs-file "snippets")))

(defun jc/autoinsert-yas-expand()
  "Replace text in yasnippet template."
  (yas-expand-snippet (buffer-string) (point-min) (point-max)))

(use-package autoinsert
  :init
  ;; Don't want to be prompted before insertion:
  (setq auto-insert-query nil)
  
  ;; Store all template files in a directory called templates.
  (setq auto-insert-directory (locate-user-emacs-file "templates"))
  (add-hook 'find-file-hook 'auto-insert)
  (auto-insert-mode 1)
  :config
  (define-auto-insert (rx "/advent-of-code/day" (one-or-more digit) ".org" eol)
    ["default-aoc.org" jc/autoinsert-yas-expand]))

(use-package evil
  :init (evil-mode 1)
  :config
  (setq evil-search-module 'evil-search)
  (setq evil-ex-complete-emacs-commands nil)
  (setq evil-emacs-state-modes nil)
  (setq evil-emacs-insert-state-modes nil)
  (setq evil-motion-state-modes nil))

(use-package evil-smartparens
  :config (add-hook 'smartparens-enabled-hook #'evil-smartparens-mode)
  (add-hook #'python-mode-hook #'smartparens-mode))

(use-package orderless
  :straight t
  :config
  (setq completion-styles '(orderless))
  (setq orderless-skip-highlighting (lambda () selectrum-is-active)))

(use-package selectrum
  :straight t
  :init (selectrum-mode)
  :config
  (setq selectrum-prescient-enable-filtering nil)
  (savehist-mode)
  (setq selectrum-highlight-candidates-function #'orderless-highlight-matches))

(use-package selectrum-prescient
  :straight t
  :after selectrum
  :config (selectrum-prescient-mode))

(use-package all-the-icons)
(use-package doom-modeline
  :init (doom-modeline-mode 1))

(use-package lispy
  :straight t
  :defer t
  :hook ((lisp-mode . lispy-mode)
	 (emacs-lisp-mode . lispy-mode)))

(use-package lispyville
  :straight t
  :defer t
  :hook (lispy-mode . lispyville-mode)
  :config
  (lispyville-set-key-theme '((operators normal) ;; These are the functionalities that I have enabled for Lispyville.
			      (atom-motions normal)
			      (additional-movement normal)
			      (commentary normal)
			      (slurp/barf-cp normal)
			      (additional normal visual)
			      (additional-insert normal visual))))

(use-package flycheck
  :straight t
  :init (global-flycheck-mode)
  :custom
  (flycheck-display-errors-delay 2))

(add-hook 'org-mode-hook (lambda ()
			   (setq org-src-fontify-natively t
				 org-src-tab-acts-natively t
				 org-edit-src-content-indentation 0)))

(setq org-src-window-setup 'current-window)

(require 'org-tempo)
(setq org-structure-template-alist '(("s" . "src")))

(use-package geiser-mit
  :config (setq geiser-racket-binary "/usr/bin/racket"
		geiser-active-implementations '(racket)
		geiser-default-implementations '(racket)))

(org-babel-do-load-languages 'org-babel-load-languages '((scheme . t)
							 (python . t)))

(use-package racket-mode
  :config (setq racket-program "/usr/bin/racket"))

(use-package elpy
  :config (add-hook 'python-mode-hook 'elpy-enable)
  (setq elpy-rpc-python-command (file-truename "/usr/bin/python3")))
