@tool
extends RefCounted
class_name SarScriptUtilities

## This class contains helper functions designed for dealing with scripts.

## Returns true if p_script is or inherits from p_base_inheritance_script.
static func does_script_inherit(
	p_script: Script,
	p_base_inheritance_script: Script) -> bool:
	var script: Script = p_script

	while 1:
		if script == p_base_inheritance_script:
			return true
		else:
			if script == null:
				break
			script = script.get_base_script()
			
	return false

const SENTINEL = Object.new()

## Compares two parameters and prints error message parameter if false.
## Used as replacement to assert() in exported projects.
# assert_bool
static func check_neq(
	p_value: Variant,
	p_expected: Variant,
	p_error_msg: String = "error_check() failed"
) -> bool:
	var result: bool = p_value == p_expected
	if not result:
		push_error("Script Error: " + p_error_msg)
		# Editor debugger only
		print_stack()
		assert(result)

	return result

static func check_false(
	p_value: Variant,
	p_error_msg: String = "error_check_bool() failed!"
) -> bool:
	var result: bool = bool(p_value)
	if not result:
		push_error("Script Error: " + p_error_msg)
		# Editor debugger only
		print_stack()
		assert(result)

	return result

static func check_null(
	p_value: Variant,
	p_error_msg: String = "Unexpected null value"
) -> bool:
	var result: bool = true
	if p_value == null:
		result = false
		push_error("Script Error: " + p_error_msg)
		# Editor debugger only
		print_stack()
		assert(result)

	return result

static func check_error(
	p_value: Error,
	p_error_msg: String = "Unexpected Error value"
) -> bool:
	var result: Error == OK
	if not result:
		push_error("Script Error: " + p_error_msg)
		# Editor debugger only
		print_stack()
		assert(result)

	return result
