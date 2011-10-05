(require 'term)

(defvar ctl-x-t-map (make-sparse-keymap)
  "Keymap for subcommands of C-x t.")
(define-key ctl-x-map "t" ctl-x-t-map)
(define-key ctl-x-t-map "t" 'pytest-run-again)
(define-key ctl-x-t-map "f" 'pytest-run-file)
(define-key ctl-x-t-map "m" 'pytest-run-method)

(defvar pytest-run-history nil)

(defconst pytest-def-re "def \\(test_[A-Za-z0-9]+\\)")

(defun pytest-term-sentinel (proc msg)
  (term-sentinel proc msg)
  (when (memq (process-status proc) '(signal exit))
    (setq buffer-read-only t)
    (local-set-key "q" 'quit-window)))

(defun pytest-run (cmdline show-prompt)
  (let ((cmdline (if show-prompt
                     (read-shell-command "Run: " cmdline
                                         'pytest-run-history)
                   cmdline))
        (buffer (get-buffer-create "*pytest*")))
    (switch-to-buffer-other-window buffer)
    (insert cmdline)
    (newline)
    (term-ansi-make-term "*pytest*" "/bin/sh" nil "-c" cmdline)
    (let ((proc (get-buffer-process buffer)))
      ; override the default sentinel set by term-ansi-make-term
      (set-process-sentinel proc 'pytest-term-sentinel))))


(defun pytest-arg-from-buffer-name (buffer-name)
  (if (string-match "test_.*\\.py$" buffer-name)
      buffer-name
    (file-name-directory buffer-name)))

(defun pytest-current-function-name ()
  (save-excursion
    (if (search-backward-regexp pytest-def-re)
        (match-string 1)
      nil)))

(defun pytest-run-file ()
  (interactive)
  (let ((cmdline (format "py.test %s" 
                         (pytest-arg-from-buffer-name (buffer-file-name)))))
    (pytest-run cmdline t)))

(defun pytest-run-method ()
  (interactive)
  (let ((cmdline (format "py.test %s -k %s" 
                         (pytest-arg-from-buffer-name (buffer-file-name))
                         (pytest-current-function-name))))
    (pytest-run cmdline t)))

(defun pytest-run-again ()
  (interactive)
  (if (not pytest-run-history)
      (message "No preceding pytest commands in history")
    (let ((cmdline (car pytest-run-history)),
          (show-prompt (equal current-prefix-arg '(4))))
      (pytest-run cmdline show-prompt))))  
