;imports
(import "sys/lisp.inc")
(import "class/lisp.inc")
(import "gui/lisp.inc")

(structure '+event 0
	(byte 'close+)
	(byte 'hvalue+)
	(byte 'clear+)
	(byte 'clear_all+))

(defq vdu_width 60 vdu_height 40 buf_keys (list) buf_list (list) buf_index nil id t)

;single instance only
(when (= (length (mail-enquire "PROFILE_SERVICE")) 0)
	(defq select (array (task-mailbox) (mail-alloc-mbox))
		entry (mail-declare "PROFILE_SERVICE" (elem -2 select) "Profile Service 0.1"))

(structure '+profile_msg 0
	(long 'tcb+)
	(offset 'data+))

(structure '+profile_rec 0
	(byte 'buf+))

(ui-window mywindow (:color 0xc0000000)
	(ui-flow _ (:flow_flags +flow_down_fill+)
		(ui-title-bar _ "Profile" (0xea19) +event_close+)
		(ui-tool-bar _ ()
			(ui-buttons (0xe960) +event_clear+)
			(ui-buttons (0xe960) +event_clear_all+ (:color (const *env_toolbar2_col*))))
		(component-connect (ui-slider hslider (:value 0)) +event_hvalue+)
		(ui-vdu vdu (:vdu_width vdu_width :vdu_height vdu_height :ink_color +argb_yellow+))))

(defun set-slider-values ()
	(defq val (get :value hslider) mho (max 0 (dec (length buf_list))))
	(def hslider :maximum mho :portion 1 :value (min val mho))
	(. hslider :dirty))

(defun reset (&optional _)
	(setd _ -1)
	(if (<= 0 _ (dec (length buf_list)))
		(progn
			(def hslider :value _)
			(setq buf_index _)
			(vdu-load vdu (elem +profile_rec_buf+ (elem buf_index buf_list)) 0 0 0 1000))
		(progn
			(clear buf_list)
			(clear buf_keys)
			(setq buf_index nil)
			(vdu-load vdu '(
				{ChrysaLisp Profile 0.1}
				{Toolbar1 buttons act on a single task.}
				{Toolbar2 buttons act on all tasks.}
				{Slider to switch between tasks.}
				{}
				{In Lisp files:}
				{add (import "lib/debug/profile.inc")}
				{then use (profile-report name) to send.}) 0 0 0 1000)))
	(set-slider-values))

(defun main ()
	(bind '(x y w h) (apply view-locate (. mywindow :pref_size)))
	(gui-add (view-change mywindow x y w h))
	(reset)
	(while id
		(defq idx (mail-select select) msg (mail-read (elem idx select)))
		(cond
			;new debug msg
			((/= idx 0)
				(defq tcb (get-long msg +profile_msg_tcb+)
					data (slice +profile_msg_data+ -1 msg)
					key (sym (str tcb))
					index (find-rev key buf_keys))
				(unless index
					(push buf_keys key)
					(push buf_list (list (list "")))
					(reset (setq index (dec (length buf_list)))))
				(elem-set +profile_rec_buf+ (elem index buf_list) (split data (ascii-char 10)))
				(vdu-load vdu (elem +profile_rec_buf+ (elem buf_index buf_list)) 0 0 0 1000))
			;close ?
			((= (setq id (get-long msg ev_msg_target_id)) +event_close+)
				(setq id nil))
			;moved task slider
			((= id +event_hvalue+)
				(reset (get :value hslider)))
			;pressed clear button
			((= id +event_clear+)
				(when buf_index
					(setq buf_keys (cat (slice 0 buf_index buf_keys) (slice (inc buf_index) -1 buf_keys)))
					(setq buf_list (cat (slice 0 buf_index buf_list) (slice (inc buf_index) -1 buf_list)))
					(reset (min buf_index (dec (length buf_list))))))
			;pressed clear all button
			((= id +event_clear_all+)
				(reset))
			;otherwise
			(t (. mywindow :event msg))))
	(mail-forget entry)
	(mail-free-mbox (pop select))
	(. mywindow :hide))
)
