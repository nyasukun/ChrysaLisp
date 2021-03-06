;;;;;;;;;;;;;;
; title widget
;;;;;;;;;;;;;;

(defclass Title ()
	; (Title) -> title
	; overide the default 'this' env with a title component
	; inherit from Label !
	(defq this (Label))

	(defmethod :mouse_down (this event)
		; (. title :mouse_down event) -> title
		(defq ax (get-int event ev_msg_mouse_x) ay (get-int event ev_msg_mouse_y)
			window (penv this))
		(until (def? :is_window window)
			(setq window (penv window)))
		(bind '(x y) (. window :get_pos))
		(def this :drag_offx (- x ax) :drag_offy (- y ay))
		(if (= 1 (get-int event ev_msg_mouse_buttons))
			(. window :to_front)
			(. window :to_back))
		this)

	(defmethod :mouse_move (this event)
		; (. title :mouse_move event) -> title
		(defq ax (get-int event ev_msg_mouse_x) ay (get-int event ev_msg_mouse_y)
			window (penv this))
		(until (def? :is_window window)
			(setq window (penv window)))
		(bind '(x y w h) (. window :get_bounds))
		(. window :change_dirty (+ ax (get :drag_offx this)) (+ ay (get :drag_offy this)) w h)
		this)
	)
