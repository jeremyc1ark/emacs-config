(setq custom-file "~/.emacs.vanilla/null.el")

(defun jc/tangle-org-file ()
  (when (string= buffer-file-name (file-truename "~/.emacs.default/config.org"))
    (org-babel-tangle)))
(add-hook 'after-save-hook 'jc/tangle-org-file)

(org-babel-load-file "~/.emacs.default/config.org")
