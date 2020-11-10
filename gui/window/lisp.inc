;;;;;;;;;;;;;;;
; window widget
;;;;;;;;;;;;;;;

(ffi create-window "gui/window/lisp_create" 0)

(class Window ()
	; (Window) -> window
	; overide the default 'this' env with a window component
	(def (defq this (create-window)) :child nil :is_window t)

	(method :add_child (this child)
		; (. window :add_child child) -> window
		(if (defq old_child (get :child this))
			(view-sub old_child))
		(set this :child child)
		(view-add-back this child)
		this)

	(method :pref_size (this)
		; (. window :pref_size) -> (width height)
		(defq child (get :child this) border (get :border this) shadow
			(get :shadow this) w 0 h 0)
		(if child (bind '(w h) (view-pref-size child)))
		(list (+ (* (+ shadow border) 2) w) (+ (* (+ shadow border) 2) h)))

	(method :layout (this)
		; (. window :layout) -> window
		(defq border (get :border this) shadow (get :shadow this)
			color (get :color this) child (get :child this))
		;position any child
		(bind '(w h) (view-get-size this))
		(when child
			(view-change child (+ border shadow) (+ border shadow)
				(- w (* 2 (+ border shadow))) (- h (* 2 (+ border shadow)))))

		;adjust window transparetncy details based on color and shadow
		(when (= (>> (get :color this) 24) 0xff)
			(cond
				((= shadow 0)
					(view-set-flags this view_flag_opaque view_flag_opaque))
				(t
					(view-clr-opaque this)
					(view-add-opaque this (+ border shadow) (+ border shadow)
						(- w (* 2 (+ border shadow))) (- h (* 2 (+ border shadow)))))))
		this)

	(method :mouse_down (this event)
		; (. window :mouse_down event) -> window
		(bind '(w h) (view-get-size this))
		(defq rx (get-int event ev_msg_mouse_rx) ry (get-int event ev_msg_mouse_ry)
			border (get :border this) shadow (get :shadow this)
			drag_mode 0 drag_offx 0 drag_offy 0)
		(if (< rx (+ border shadow))
			(setq drag_mode (+ drag_mode 1) drag_offx rx))
		(if (< ry (+ border shadow))
			(setq drag_mode (+ drag_mode 2) drag_offy ry))
		(if (>= rx (- w border shadow))
			(setq drag_mode (+ drag_mode 4) drag_offx (- rx w)))
		(if (>= ry (- h border shadow))
			(setq drag_mode (+ drag_mode 8) drag_offy (- ry h)))
		(def this :drag_mode drag_mode :drag_offx drag_offx :drag_offy drag_offy)
		this)

	(method :mouse_move (this event)
		; (. window :mouse_move event) -> window
		(defq ax (get-int event ev_msg_mouse_x) ay (get-int event ev_msg_mouse_y)
			drag_mode (get :drag_mode this) drag_offx (get :drag_offx this)
			drag_offy (get :drag_offy this))
		(bind '(x y x1 y1) (view-get-bounds this))
		(bind '(w h) (. this :pref_size))
		(setq x1 (+ x x1) y1 (+ y y1))
		(if (/= 0 (logand 1 drag_mode))
			(setq x (min (- ax drag_offx) (- x1 w))))
		(if (/= 0 (logand 2 drag_mode))
			(setq y (min (- ay drag_offy) (- y1 h))))
		(if (/= 0 (logand 4 drag_mode))
			(setq x1 (max (- ax drag_offx) (+ x w))))
		(if (/= 0 (logand 8 drag_mode))
			(setq y1 (max (- ay drag_offy) (+ y h))))
		(view-change-dirty this x y (- x1 x) (- y1 y))
		(component-emit this)
		this)
	)