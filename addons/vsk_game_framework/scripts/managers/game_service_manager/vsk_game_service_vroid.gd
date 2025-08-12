# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# vsk_game_service_vroid.gd
# SPDX-License-Identifier: MIT
@tool
extends SarGameService
class_name VSKGameServiceVroid

enum SessionType {
	NONE = 0, # Null state, API calls don't work
	USER = 2
}

signal vroid_sign_in_complete

var _godot_vroid: GodotVroid = null
var _current_account_address: String = ""
var _session_mode: SessionType = SessionType.NONE

var _active_service_requests: Dictionary[SarGameServiceRequest, GodotRequester] = {}

func _update_session(
	p_renewal_token: String,
	p_access_token: String,
	p_username: String,
	p_domain: String
) -> void:
	_current_account_address = ""
	
	if not _godot_vroid:
		return
		
	var token_changed: bool = false
	
	# Get a unique OS ID to encrypt the session keys just in case
	# the file gets stolen.
	var _os_unique_id = OS.get_unique_id()
	
	var renewal_token: String = ""
	var access_token: String = ""
	
	var tokens: Dictionary = _godot_vroid.get_tokens(p_username, p_domain)
	renewal_token = tokens.get("renewal_token", "")
	access_token = tokens.get("access_token", "")
	
	if renewal_token != p_renewal_token:
		renewal_token = p_renewal_token
		token_changed = true
	if access_token != p_access_token:
		access_token = p_access_token
		token_changed = true

	_godot_vroid.cfg.set_value("api", p_username + "@" + p_domain + "/" + "renewal_token", renewal_token)
	_godot_vroid.cfg.set_value("api", p_username + "@" + p_domain + "/" + "access_token", access_token)
	
	if _godot_vroid.cfg.save_encrypted_pass(_godot_vroid.get_editor_config_path(), _os_unique_id) != OK:
		push_error("Could not save editor token!")
	if _godot_vroid.cfg.save_encrypted_pass(_godot_vroid.get_game_config_path(), _os_unique_id) != OK:
		push_error("Could not save game token!")
	
	_current_account_address = "%s@%s" % [p_username, p_domain]
	_session_mode = SessionType.USER

	_godot_vroid.store_selected_id(_current_account_address)

	if not token_changed:
		return

func _create_session(p_service_request: VSKGameServiceRequestUro, p_procesed_result: Dictionary) -> void:
	_update_session(
		p_procesed_result.get("renewal_token", ""),
		p_procesed_result.get("access_token", ""),
		p_procesed_result.get("user_username", ""),
		p_service_request.domain
	)


func _clear_local_session() -> void:
	var address_dict: Dictionary = GodotUroHelper.get_username_and_domain_from_address(_current_account_address)
	
	_current_account_address = ""
	_session_mode = SessionType.NONE
	if _godot_vroid and _godot_vroid.get_api():
		_godot_vroid.clear_tokens(address_dict.get("username", ""), address_dict.get("domain", ""))
		_godot_vroid.store_selected_id("")
	
	return

func _process_result_and_update(p_service_request: VSKGameServiceRequestUro, p_result: Dictionary) -> Dictionary:
	if _godot_vroid:
		var tokens: Dictionary = _godot_vroid.get_tokens("", "")
		var processed_result: Dictionary = GodotUroHelper.process_session_json(
			p_result,
			tokens.get("renewal_token", ""),
			tokens.get("access_token", "")
		)
		
		if GodotUroHelper.requester_result_is_ok(processed_result):
			_create_session(p_service_request, processed_result)
		else:
			_clear_local_session()

		return processed_result
	else:
		return {}



func _process_result_and_update_session(p_service_request: SarGameServiceRequest, p_result: Dictionary) -> Dictionary:
	var processed_result: Dictionary = _process_result_and_update(p_service_request, p_result)

	_emit_session_request_complete(p_service_request, processed_result)

	return processed_result


func _get_tokens(p_service_request: SarGameServiceRequest) -> Dictionary:
	if not p_service_request is VSKGameServiceRequestUro:
		push_error("Did not pass a valid VSKGameServiceRequestUro object to sign in request.")
		return {}

	var domain: String = (p_service_request as VSKGameServiceRequestUro).domain
	if domain.is_empty():
		push_error("Did not pass a valid domain to sign in request.")
		return {}
		
	var username: String = (p_service_request as VSKGameServiceRequestUro).username
	if username.is_empty():
		push_error("Did not pass a valid username to sign in request.")
		return {}
	
	var tokens: Dictionary = _godot_vroid.get_tokens(username, domain)
	
	return tokens

"""
func _get_dashboard_content_async(p_service_request: SarGameServiceRequest, p_callable: Callable) -> Dictionary:
	if _godot_uro and _godot_uro.get_api():
		if not p_service_request is VSKGameServiceRequestUro:
			push_error("Did not pass a valid VSKGameServiceRequestUro object to a sign out request.")
			return {} 
		
		var domain: String = (p_service_request as VSKGameServiceRequestUro).domain
		var tokens: Dictionary = _get_tokens(p_service_request)
		
		# Add this request to the active request pool.
		var godot_uro_request: GodotUroRequester = _godot_uro.create_requester(domain, -1)
		_active_service_requests[p_service_request] = godot_uro_request
		
		var result: Dictionary = await p_callable.call(
			godot_uro_request,
			tokens.get("access_token", "")
		)
		
		if not stop_request(p_service_request):
			return {}
			
		if result.is_empty():
			return {}

		return result
		
	return {}

func _get_multiple_content_async(p_service_request: SarGameServiceRequest, p_callable: Callable):
	if _godot_uro and _godot_uro.get_api():
		if not p_service_request is VSKGameServiceRequestUro:
			printerr("Did not pass a valid VSKGameServiceRequestUro object to a sign out request.")
			return {} 
		
		var domain: String = (p_service_request as VSKGameServiceRequestUro).domain
		
		# Add this request to the active request pool.
		var godot_uro_request: GodotUroRequester = _godot_uro.create_requester(domain, -1)
		_active_service_requests[p_service_request] = godot_uro_request
		
		var result: Dictionary = await p_callable.call(
			godot_uro_request
		)
		
		if not stop_request(p_service_request):
			return {}
			
		if result.is_empty():
			return {}

		return result
		
	return {}

func _get_individual_content_async(p_service_request: SarGameServiceRequest, p_id: String, p_callable: Callable):
	if _godot_uro and _godot_uro.get_api():
		if not p_service_request is VSKGameServiceRequestUro:
			push_error("Did not pass a valid VSKGameServiceRequestUro object to a sign out request.")
			return {} 
		
		var domain: String = (p_service_request as VSKGameServiceRequestUro).domain
		
		# Add this request to the active request pool.
		var godot_uro_request: GodotUroRequester = _godot_uro.create_requester(domain, -1)
		_active_service_requests[p_service_request] = godot_uro_request
		
		var result: Dictionary = await p_callable.call(
			godot_uro_request,
			p_id
		)
		
		if not stop_request(p_service_request):
			return {}
			
		if result.is_empty():
			return {}

		return result
		
	return {}
	

	
## Returns a dictionary containing information about a specific avatar id.
func get_avatar_async(p_service_request: SarGameServiceRequest, p_id: String) -> Dictionary:
	if _godot_uro and _godot_uro.get_api():
		return await _get_individual_content_async(p_service_request, p_id, _godot_uro.get_api().get_avatar_async)
	
	return {}


## Returns a dictionary containing public avatars
func get_avatars_async(p_service_request: SarGameServiceRequest) -> Dictionary:
	if _godot_uro and _godot_uro.get_api():
		return await _get_multiple_content_async(p_service_request, _godot_uro.get_api().get_avatars_async)
	
	return {}
"""

func _ready() -> void:
	add_child(_godot_vroid)

func _init() -> void:
	_godot_vroid = GodotVroid.new()

###

## Returns a dictionary containing the current active account username and domain
## we are signed in with. On failure it will return a dictionary with an empty username
## and domain.
func get_current_username_and_domain() -> Dictionary[String, String]:
	var account_address: String = _godot_uro.get_current_account_address()
	var result_dictionary: Dictionary[String, String] = GodotUroHelper.get_username_and_domain_from_address(account_address)
	return result_dictionary

## Returns a string containing the currently active user account and domain
## we are signed in with.
func get_current_account_address() -> String:
	return _current_account_address

## Returns current SessionType.
func get_current_session_mode() -> SessionType:
	return _session_mode

## Returns the name of the service.
static func get_service_name() -> String:
	return "Vroid"

func _get_uro_service() -> VSKGameServiceUro:
	var service_manager: SarGameServiceManager = get_tree().get_first_node_in_group("game_service_managers")
	if service_manager:
		var uro_service: VSKGameServiceUro = service_manager.get_service("Uro")
		return uro_service
		
	return null

const DEFAULT_PORT: int = 8553

func start_oauth_sign_in(p_service_request: SarGameServiceRequest, p_sign_in_data: Dictionary) -> Error:
	# TODO: web support
	if OS.get_name() == "Web":
		push_error("Web platform Vroid API support is not implemented")
		return FAILED

	var _godot_uro = _get_uro_service()
	if not (_godot_uro and _godot_uro.get_api()):
		return FAILED

	var _domain = 
	var request = _godot_uro.create_request({"domain": _domain})
	var provider = get_service_name().to_lower()
	var result: Dictionary = await _godot_uro.get_oauth_redirect(request, provider)

	# Start server listener
	var oauth_listener = OAuthRedirectListener.new(DEFAULT_PORT)
	if not SarUtils.assert_ok(oauth_listener.oauth_redirect_success.connect(_on_oauth_redirect_success),
		"Could not connect signal 'oauth_listener.oauth_redirect_success' to '_on_oauth_redirect_success'"):
		return FAILED
	if not SarUtils.assert_ok(oauth_listener.oauth_redirect_failure.connect(_on_oauth_redirect_failure),
		"Could not connect signal 'oauth_listener.oauth_redirect_failure' to '_on_oauth_redirect_failure'"):
		return FAILED

	add_child(oauth_listener)

	if not SarUtils.assert_ok(oauth_listener.start_listen(),
		"Failed to start OAuth redirect listener"):
		return FAILED

	push_error(result)
	var redirect_url: String = ""
	#open browser
	#if OS.get_name() == "Linux":
	#	OS.create_process("xdg-open", [redirect_url, "&"])
	
	if not SarUtils.assert_ok(OS.shell_open(redirect_url),
		"Failed to start browser at %s" % redirect_url):
		return FAILED

	return OK

func _on_oauth_redirect_success(data):
	push_error(data)
	_process_result_and_update_session(data)

	vroid_sign_in_complete.emit()
	return

func _on_oauth_redirect_failure(err):
	push_error("Vroid OAuth error: %s" % err)
	return


## Creates a service request object. This can then be passed into
## into the request API to keep track of the status and callbacks of
## the request.
func create_request(p_data: Dictionary) -> SarGameServiceRequest:
	var service_request: VSKGameServiceRequestVroid = VSKGameServiceRequestVroid.new()
	service_request.username = p_data.get("username", "")
	service_request.domain = p_data.get("domain", "")
	return service_request

## Will attempt to cancel an ongoing service request. Will return true
## if the request was active and subsequently stopped, and false if
## the request wasn't active and there was nothing to stop.
func stop_request(p_service_request: SarGameServiceRequest) -> bool:
	if is_request_active(p_service_request):
		var godot_vroid_request: GodotRequester = _active_service_requests.get(p_service_request)
		if godot_vroid_request:
			_active_service_requests.erase(p_service_request)
			_godot_vroid.get_api().cancel(godot_vroid_request)
			return true
	
	return super.stop_request(p_service_request)
	
## Returns true if the request is active.
func is_request_active(p_service_request: SarGameServiceRequest) -> bool:
	if _active_service_requests.has(p_service_request):
		return true
	
	return super.is_request_active(p_service_request)

## Gets the selected username and domain for the currently active service
## session from local keystore.
func get_selected_id() -> String:
	return _godot_vroid.load_selected_id()
		
	
