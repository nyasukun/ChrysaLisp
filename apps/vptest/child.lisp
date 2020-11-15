;imports
(import "sys/lisp.inc")
(import "class/lisp.inc")
(import "gui/lisp.inc")

(defun cpucolor (x y x1 y1 w h cx cy z)
	;return a square coloured by CPU number
	(defq col (% (>> (task-mailbox) 32) 64))
	(write-int (defq reply (string-stream (cat ""))) (list x y x1 y1))
	(setq y (dec y))
	(while (/= (setq y (inc y)) y1)
		(defq xp (dec x))
		(while (/= (setq xp (inc xp)) x1)
			(write-char reply col)))
	(mail-send (str reply) mbox))

(defun rect (mbox x y x1 y1 w h cx cy z tot)
	(cond
		((> (setq tot (/ tot 4)) 0)
			;split into more tasks
			(defq farm (open-farm "apps/vptest/child.lisp" 3 kn_call_child)
				x2 (/ (+ x x1) 2) y2 (/ (+ y y1) 2))
			(mail-send (array mbox x y x2 y2 w h cx cy z tot) (elem 0 farm))
			(mail-send (array mbox x2 y x1 y2 w h cx cy z tot) (elem 1 farm))
			(mail-send (array mbox x y2 x2 y1 w h cx cy z tot) (elem 2 farm))
			(rect mbox x2 y2 x1 y1 w h cx cy z tot))
		(t	;do here
			(cpucolor x y x1 y1 w h cx cy z))))

(defun main ()
	;read work request
	(defq msg (string-stream (mail-read (task-mailbox))))
	(apply rect (map (lambda (_) (read-long msg)) (range 0 11))))
