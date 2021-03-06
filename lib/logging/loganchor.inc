;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; loganchor - Logging Service Anchor support
; Log Service - a flexible log event
; system for commands, applicaations and
; libraries.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import "lib/logging/logging.inc")

(defun log-anchor (name)
  ; (log-anchor) -> properties
  ; Wrapper to (create-log-anchor name) to
  ; setup environment and deserialze logger
  ; properties string
  (data-xdeser
    (write (string-stream (cat ""))
      (create-log-anchor name (penv (env))))))
