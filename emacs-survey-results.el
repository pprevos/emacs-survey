;;; package --- Visualise Emacs user survey in plain text
;;
;;; Commentary:
;;
;; This code downloads the 2020 CSV results and visualises
;; one question using plan text.
;; See: https://lucidmanager.org/productivity/emacs-survey-results
;;
;;; Code:

(require 'csv)
(require 'f)
(require 'dash)
(require 'chart)

(url-copy-file
 "https://emacs-survey.netlify.app/2020/Emacs-User-Survey-2020-clean.csv"
 "emacs-survey.csv" 1)

(defun csv-parse-file (file)
  "Read CSV FILE and parse its contents."
  (with-temp-buffer
    (insert-file-contents file)
    (csv-parse-buffer t)))

(defun csv-extract-column-number (n csv)
  "Extract values in column N from parsed CSV file into an alist."
  (mapcar #'cdr
          (seq-map (lambda (list) (nth (- n 1) list)) csv)))

(defun csv-extract-column-name (name csv)
  "Extract the values in column with NAME from parsed CSV into a list."
  (mapcar #'cdr
          (seq-map (apply-partially #'assoc name) csv)))

(defun create-frequency-table (data)
  "Generate an ordered frequency table from DATA."
  (sort (-frequencies list)
        (lambda (a b) (> (cdr a) (cdr b)))))

(defun visualise-frequency-table (table n var title)
  "Create a barchart from a frequency TABLE with top N entries.
VAR and TITLE used for display."
  (chart-bar-quickie
   'horizontal
   title
   (mapcar #'car table) var
   (mapcar #'cdr table) "Frequency" n))

(setq emacs-survey
      (csv-parse-file "emacs-survey.csv"))

(visualise-frequency-table
 (create-frequency-table
  (csv-extract-column-number 6 emacs-survey))
 10
 "Responses"
 "Which version of Emacs do you primarily use?")

provide 'emacs-survey-results
;;; emacs-survey-results.el ends here
