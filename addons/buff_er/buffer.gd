extends RefCounted
class_name Buffer


## Generic purpose buffer, which can be used for input buffering, coyote jump, etc.[br]
## You'll see various times the terms pre-buffer and post-buffer. These are (probably) terms I made up myself.[br][br]
## Pre-buffering is buffering an input before the action can be done to then do the action when possible.[br]
## Post-buffering is buffering the possibility of doing an action to do it when input is asked to.
## pre_buffer_frames and post_buffer_frames with both 0 will result in no buffering


## If true, input is sent
var input: bool
## If true, action can be done
var allow: bool

var pre_buffering_time: float = 0.0
var post_buffering_time: float = 0.0

var _pre_b_time: float = 0.0
var _post_b_time: float = 0.0
# If true, all buffering is reset on update (action was done)
var _reset_buffer: bool = false


func _init(pre_buffer: float = 0.0, post_buffer: float = 0.0):
	pre_buffering_time = pre_buffer
	post_buffering_time = post_buffer


# Helper function for decreasing
func _decrease(value: float, delta: float):
	return maxf(0.0, value - delta)


func update(delta: float):
	if _reset_buffer:
		_pre_b_time = 0.0
		_post_b_time = 0.0
		_reset_buffer = false
	
	_pre_b_time = _decrease(_pre_b_time, delta)
	_post_b_time = _decrease(_post_b_time, delta)
	
	if input and not allow:
		_pre_b_time = pre_buffering_time
	if allow and not input:
		_post_b_time = post_buffering_time
	
#	print_debug_info()


func print_debug_info() -> void:
	printt(_pre_b_time, _post_b_time, can_do_action())


func can_do_action() -> bool:
	var result = (input and allow) or (allow and _pre_b_time > 0.0) or (input and _post_b_time > 0.0)
	if result:
		_reset_buffer = true
	return result


func is_in_coyote_time() -> bool:
	return not allow and _post_b_time > 0.0


func reset_buffering():
	_pre_b_time = 0.0
	_post_b_time = 0.0


## If 0, action was done when both input and allow were true
## If negative, input was done -x frames earlier
## If positive, was done x frames later
#func get_action_error() -> int:
#	if input and allow:
#		return 0
#	elif allow and _pre_b_frames > 0:
#		return -_pre_b_frames
#	elif input and _post_b_frames > 0:
#		return _post_b_frames
#	push_error("Cannot do action, returning 0")
#	return 0
