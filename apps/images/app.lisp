;imports
(import 'sys/lisp.inc)
(import 'class/lisp.inc)
(import 'gui/lisp.inc)

(structure 'event 0
	(byte 'win_close)
	(byte 'win_prev 'win_next))

(defq images '("apps/images/wallpaper.cpm" "apps/images/chrysalisp.cpm"
	"apps/images/frill.cpm" "apps/images/magicbox.cpm" "apps/images/captive.cpm"
	"apps/images/balls.cpm" "apps/images/banstand.cpm" "apps/images/bucky.cpm"
	"apps/images/circus.cpm" "apps/images/cyl_test.cpm" "apps/images/logo.cpm"
	"apps/images/mice.cpm" "apps/images/molecule.cpm" "apps/images/nippon3.cpm"
	"apps/images/piramid.cpm" "apps/images/rings.cpm" "apps/images/sharpend.cpm"
	"apps/images/stairs.cpm" "apps/images/temple.cpm" "apps/images/vermin.cpm")
	index 0 id t)

(ui-tree window (create-window) nil
	(ui-element window_flow (create-flow) ('flow_flags flow_down_fill)
		(ui-element _ (create-flow) ('flow_flags flow_left_fill
				'font (create-font "fonts/Entypo.ctf" 22) 'color title_col)
			(ui-buttons (0xea19) (const event_win_close))
			(ui-element window_title (create-title) ('font (create-font "fonts/OpenSans-Regular.ctf" 18))))
		(ui-element _ (create-flow) ('flow_flags (logior flow_flag_right flow_flag_fillh)
				'color toolbar_col 'font (create-font "fonts/Entypo.ctf" 32))
			(ui-buttons (0xe91d 0xe91e) (const event_win_prev)))
		(ui-element image_scroll (create-scroll (logior scroll_flag_vertical scroll_flag_horizontal))
			('color slider_col))))

(defun win-refresh (_)
	(bind '(w h) (view-pref-size (defq canvas (canvas-load (elem (setq index _) images) 0))))
	(def image_scroll 'min_width w 'min_height h)
	(view-add-child image_scroll canvas)
	(def window_title 'text (elem _ images))
	(view-layout window_title)
	(bind '(x y) (view-get-pos window))
	(bind '(w h) (view-pref-size window))
	(def image_scroll 'min_width 32 'min_height 32)
	(view-change-dirty window x y w h))

(defun-bind main ()
	(gui-add (apply view-change (cat (list window 320 256) (view-get-size (win-refresh index)))))
	(while id
		(cond
			((= (setq id (get-long (defq msg (mail-read (task-mailbox))) ev_msg_target_id)) event_win_close)
				(setq id nil))
			((= id event_win_next)
				(win-refresh (% (inc index) (length images))))
			((= id event_win_prev)
				(win-refresh (% (+ (dec index) (length images)) (length images))))
			(t (view-event window msg))))
	(view-hide window))
