;;;;;;;;;;;;;
; grid widget
;;;;;;;;;;;;;

(defclass Grid ()
	; (Grid) -> grid
	; overide the default 'this' env with a grid component
	; inherit from View !
	(defq this (View))

	(defmethod :pref_size (this)
		; (. grid :pref_size) -> (width height)
		(defq pw 0 ph 0)
		(each (lambda (child)
			(bind '(w h) (. child :pref_size))
			(setq pw (max w pw) ph (max h ph))) (. this :children))
		(list (* (get :grid_width this) pw) (* (get :grid_height this) ph)))

	(defmethod :layout (this)
		; (. grid :layout) -> grid
		(bind '(w h) (. this :get_size))
		(defq grid_width (get :grid_width this) grid_height (get :grid_height this)
			w (<< w +fp_shift+) h (<< h +fp_shift+))
		(each (lambda (child)
			(defq row (/ _ grid_width) col (% _ grid_width)
				x (>> (/ (* col w) grid_width) +fp_shift+)
				y (>> (/ (* row h) grid_height) +fp_shift+)
				x1 (>> (/ (* (inc col) w) grid_width) +fp_shift+)
				y1 (>> (/ (* (inc row) h) grid_height) +fp_shift+))
			(view-change child x y (- x1 x) (- y1 y))) (. this :children))
		this)
	)
