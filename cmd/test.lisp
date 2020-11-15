(import "class/lisp.inc")
(import "lib/logging/logcommons.inc")
(import "lib/asm/asm.inc")
(make '("sys/kernel/class.vp"))

(defun main ()
	(when (defq stdio (create-stdio))
		(print (length "hogehoge2"))
	)
)

