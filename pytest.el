(require 'term)

(defvar ctl-x-t-map (make-sparse-keymap)
  "Keymap for subcommands of C-x t.")
(define-key ctl-x-map "t" ctl-x-t-map)
(define-key ctl-x-t-map "t" 'pytest-run-again)
(define-key ctl-x-t-map "f" 'pytest-run-file)

(defvar pytest-run-history nil)

(defun pytest-run (cmdline show-prompt)
  (let ((cmdline (if show-prompt
                     (read-shell-command "Run: " cmdline
                                         'pytest-run-history)
                   cmdline))
        (buffer (get-buffer-create "*pytest*")))
    (switch-to-buffer-other-window buffer)
    (insert cmdline)
    (newline)
    (term-ansi-make-term "*pytest*" "/bin/sh" nil "-c" cmdline)))

(defun pytest-run-file ()
  (interactive)
  (let ((cmdline (concat "py.test " (buffer-file-name))))
    (pytest-run cmdline t)))


(defun pytest-run-again ()
  (interactive)
  (if pytest-run-history
      (let ((cmdline (car pytest-run-history)))
        (pytest-run cmdline nil))
    (message "No preceding pytest commands in history")))
  
