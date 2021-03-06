(include "sys/class.inc")

(def-class 'ctx)
(dec-method :box 'gui/ctx/box :static '(r0 r7 r8 r9 r10))
(dec-method :filled_box 'gui/ctx/filled_box :static '(r0 r7 r8 r9 r10))
(dec-method :blit 'gui/ctx/blit :static '(r0 r1 r2 r7 r8 r9 r10))
(dec-method :set_color 'gui/ctx/set_color :static '(r3 r1))
(dec-method :panel 'gui/ctx/panel :static '(r0 r1 r2 r3 r7 r8 r9 r10))
(dec-method :brighter 'gui/ctx/brighter :static '(r1) '(r1))
(dec-method :darker 'gui/ctx/darker :static '(r1) '(r1))

; (dec-method :debug 'gui/ctx/debug :static '(r0 r7 r8 r9 r10))

(def-struct 'ctx)
	(ptr 'sdl_ctx 'dirty_region)
	(int 'x 'y)
(def-struct-end)
