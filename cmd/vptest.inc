;imports
(import "class/lisp.inc")
(import "sys/lisp.inc")

(import "lib/asm/asm.inc")
(make '("cmd/vptest.vp"))

(ffi monitor "cmd/monitor" 0)
