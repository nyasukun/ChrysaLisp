;imports
(import "class/lisp.inc")
(import "sys/lisp.inc")
(import "gui/lisp.inc")

(structure '+event 0
	(byte 'close+))

(defq canvas_width 512 canvas_height 512 canvas_scale 1 then nil area 0 select nil
	center_x 0.0 center_y 0.0 zoom 1.0)

(defq cpucolors (list
	+argb_black+ +argb_white+ +argb_red+ +argb_green+
	+argb_blue+ +argb_cyan+ +argb_yellow+ +argb_magenta+
	+argb_grey1+ +argb_grey2+ +argb_grey3+ +argb_grey4+
	+argb_grey5+ +argb_grey6+ +argb_grey7+ +argb_grey8+
	+argb_grey9+ +argb_grey10+ +argb_grey11+ +argb_grey12+
	+argb_grey13+ +argb_grey14+ +argb_grey15+))

(ui-window mywindow ()
	(ui-title-bar _ "VPTest" (0xea19) +event_close+)
	(ui-canvas canvas canvas_width canvas_height canvas_scale))

(defun reset ()
	(if select (mail-free-mbox (elem 1 select)))
	(setq then (time) select (array (task-mailbox) (mail-alloc-mbox))
		area (* canvas_width canvas_height canvas_scale canvas_scale))
	(mail-send (array (elem 1 select) 0 0 (* canvas_width canvas_scale) (* canvas_height canvas_scale)
		(* canvas_width canvas_scale) (* canvas_height canvas_scale) center_x center_y zoom (* (length (mail-devices)) 4))
		(open-child "apps/vptest/child.lisp" kn_call_child)))

(defun tile (canvas data)
	; (tile canvas data) -> area
	(defq data (string-stream data) x (read-int data) y (read-int data)
		x1 (read-int data) y1 (read-int data) yp (dec y))
	(while (/= (setq yp (inc yp)) y1)
		(defq xp (dec x))
		(while (/= (setq xp (inc xp)) x1)
			(defq col (elem (% (read-char data) (length cpucolors)) cpucolors))
			(canvas-plot (canvas-set-color canvas col) xp yp))
		(task-sleep 0))
	(* (- x1 x) (- y1 y)))

(defun main ()
	;add window
	(canvas-swap (canvas-fill canvas +argb_black+))
	(bind '(x y w h) (apply view-locate (. mywindow :pref_size)))
	(gui-add (view-change mywindow x y w h))
	(reset)
	;main event loop
	(while (progn
		;next event
		(defq id (mail-select select) msg (mail-read (elem id select)))
		(cond
			((= id 0)
				;main mailbox
				(cond
					((= (setq id (get-long msg ev_msg_target_id)) +event_close+)
						;close button
						nil)
					((and (= id (component-get-id canvas))
							(= (get-long msg ev_msg_type) ev_type_mouse)
							(/= (get-int msg ev_msg_mouse_buttons) 0))
						;mouse click on the canvas so rerun
						(reset))
					(t (. mywindow :event msg))))
			(t	;child tile msg
				(setq area (- area (tile canvas msg)))
				(when (or (> (- (defq now (time)) then) 1000000) (= area 0))
					(canvas-swap canvas)
					(setq then now))
					t))))
	;close
	(. mywindow :hide)
	(mail-free-mbox (elem 1 select)))
