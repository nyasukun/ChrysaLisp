;imports
(import "cmd/vptest.inc")
;(import "class/lisp.inc")
;(import "sys/lisp.inc")
;
;(import "lib/asm/asm.inc")
;(make '("cmd/vptest.vp"))
;
;(ffi monitor "cmd/monitor" 0)

(defun main ()
    (print (task-mailbox))
    (mail-send (list (task-mailbox) '(9 8 7 10 2 100 20 1 2 3 4))
        (defq mbox (open-child "cmd/loop_child.lisp" kn_call_open)))
    (when (defq stdio (create-stdio))
        (print (mail-read (task-mailbox)))
        )
    )
