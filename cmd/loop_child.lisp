;imports
(import "cmd/vptest.inc")
;(import "class/lisp.inc")
;(import "sys/lisp.inc")
;
;(import "lib/asm/asm.inc")
;(make '("cmd/vptest.vp"))

;(ffi monitor "cmd/monitor" 0)

(bind '(parent_mbox input) (mail-read (task-mailbox)))
	(print "list:" input " vcpuid: " (monitor))
(if (< (length input) 2) (list
	(mail-send input parent_mbox)
	(mail-send "" parent_mbox)
	) (list
	(defq p (elem 0 input))
	(defq l (filter (rcurry < p) input))
	(defq r (filter (rcurry > p) input))
	(mail-send (list (task-mailbox) l)
		(defq lmbox (open-child "cmd/loop_child.lisp" kn_call_open)))
		;(defq lmbox (open-child "cmd/loop_child.lisp" kn_call_child))
	(defq rtask-mailbox (mail-alloc-mbox))
	(mail-send (list rtask-mailbox r)
		(defq rmbox (open-child "cmd/loop_child.lisp" kn_call_open)))
		;(defq rmbox (open-child "cmd/loop_child.lisp" kn_call_child)))
	(defq ol (mail-read (task-mailbox)))
	(defq our (mail-read rtask-mailbox))
	(mail-send (cat ol (list p) our) parent_mbox)
	(mail-send "" parent_mbox)
	)
)
