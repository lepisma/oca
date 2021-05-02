;;; oca.el --- Org Capture for non Org storage -*- lexical-binding: t; -*-

;; Copyright (c) 2021 Abhinav Tushar

;; Author: Abhinav Tushar <abhinav@lepisma.xyz>
;; Version: 0.0.1
;; Package-Requires: ((emacs "27"))
;; URL: https://github.com/lepisma/oca

;;; Commentary:

;; Org Capture for non Org storage
;; This file is not a part of GNU Emacs.

;;; License:

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Code:

(require 'org)

(defvar-local oca-push-function nil
  "Function taking the parsed Org entry and pushing to the final
destination. This is set locally by the oca function while
capturing.")

(defcustom oca-buffer-prefix "oca-"
  "Prefix for oca-buffer names.")

(defun oca-visit (push-function)
  "Visiting function for capturing."
  (find-file (make-temp-file oca-buffer-prefix))
  (erase-buffer)
  (org-mode)
  (setq-local oca-push-function push-function))

(defun oca--buffer-p (buffer)
  (string-prefix-p oca-buffer-prefix (buffer-name buffer)))

(defun oca-prepare-finalize-fn ()
  "Function to be added to `org-capture-prepare-finalize-hook'.
This runs the buffer-local push function first item parsed from
`org-element-parse-buffer'."
  (if (null oca-push-function)
      (error "`oca-push-function' not set for the current buffer.")
    (funcall oca-push-function (car (org-element-contents (org-element-parse-buffer))))))

(defun oca-after-finalize-fn ()
  "Cleanup function to be added to `org-capture-after-finalize-hook'."
  (dolist (buf (buffer-list))
    (when (oca--buffer-p buf)
      (kill-buffer buf))))

(defun oca-push-message (element)
  "Simple push function to print the element."
  (print element))

;;;###autoload
(defun oca-setup ()
  "Set up hooks needed for oca to work."
  (add-hook 'org-capture-prepare-finalize-hook #'oca-prepare-finalize-fn)
  (add-hook 'org-capture-after-finalize-hook #'oca-after-finalize-fn))

(provide 'oca)

;;; oca.el ends here
