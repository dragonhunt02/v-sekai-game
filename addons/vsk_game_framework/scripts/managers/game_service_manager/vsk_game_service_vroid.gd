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
	
	if not _godot_uro:
		return
		
	var token_changed: bool = false
	
	# Get a unique OS ID to encrypt the session keys just in case
	# the file gets stolen.
	var _os_unique_id = OS.get_unique_id()
	
	var renewal_token: String = ""
	var access_token: String = ""
	
	var tokens: Dictionary = _godot_uro.get_tokens(p_username, p_domain)
	renewal_token = tokens.get("renewal_token", "")
	access_token = tokens.get("access_token", "")
	
	if renewal_token != p_renewal_token:
		renewal_token = p_renewal_token
		token_changed = true
	if access_token != p_access_token:
		access_token = p_access_token
		token_changed = true

	_godot_uro.cfg.set_value("api", p_username + "@" + p_domain + "/" + "renewal_token", renewal_token)
	_godot_uro.cfg.set_value("api", p_username + "@" + p_domain + "/" + "access_token", access_token)
	
	if _godot_uro.cfg.save_encrypted_pass(_godot_uro.get_uro_editor_config_path(), _os_unique_id) != OK:
		push_error("Could not save editor token!")
	if _godot_uro.cfg.save_encrypted_pass(_godot_uro.get_uro_game_config_path(), _os_unique_id) != OK:
		push_error("Could not save game token!")
	
	_current_account_address = "%s@%s" % [p_username, p_domain]
	_session_mode = SessionType.USER

	_godot_uro.store_selected_id(_current_account_address)

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
	if _godot_uro and _godot_uro.get_api():
		_godot_uro.clear_tokens(address_dict.get("username", ""), address_dict.get("domain", ""))
		_godot_uro.store_selected_id("")
	
	return

func _process_result_and_update(p_service_request: VSKGameServiceRequestUro, p_result: Dictionary) -> Dictionary:
	if _godot_uro:
		var tokens: Dictionary = _godot_uro.get_tokens("", "")
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


func _process_result_and_delete(p_result: Dictionary) -> Dictionary:
	if not _godot_uro:
		return {}
		
	var tokens: Dictionary = _godot_uro.get_tokens("", "")
	var processed_result: Dictionary = GodotUroHelper.process_session_json(
		p_result,
		tokens.get("renewal_tokens", ""),
		tokens.get("access_tokens", "")
	)
	
	if not GodotUroHelper.requester_result_is_ok(processed_result):
		push_error(
			(
				"_process_result_and_delete: %s"
				% GodotUroHelper.get_full_requester_error_string(processed_result)
			)
		)
		return processed_result

	_clear_local_session()
	
	return processed_result


func _process_result_and_update_session(p_service_request: SarGameServiceRequest, p_result: Dictionary) -> Dictionary:
	var processed_result: Dictionary = _process_result_and_update(p_service_request, p_result)

	_emit_session_request_complete(p_service_request, processed_result)

	return processed_result


func _process_result_and_delete_session(p_result: Dictionary) -> Dictionary:
	var processed_result: Dictionary = _process_result_and_delete(p_result)

	session_deletion_complete.emit(processed_result.get("requester_code", -1), processed_result.get("message", ""))

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
	
	var tokens: Dictionary = _godot_uro.get_tokens(username, domain)
	
	return tokens
	
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


# Listens on `port`, takes the first GET request, parses query params, responds JSON, returns params.
func listen_oauth_redirect(port: int, bind_address: String = "*", timeout_ms: int = 5000) -> Dictionary:

var header_timeout_ms: int = timeout_ms
var max_bytes = 1000
var allowed_params = ["code", "state"]

var server = TCPServer.new()
    var err = server.listen(port, bind_address)
    if err != OK:
        push_error("Failed to listen on %s:%d (err %d)" % [bind_address, port, err])
        return {}

    # Wait for incoming connection
    while not server.is_connection_available():
        await get_tree().process_frame()

    var peer: StreamPeerTCP = server.take_connection()
    peer.set_no_delay(true)

    # Read until end of headers (CRLF CRLF)
    var buffer = ""
    var deadline = Time.get_ticks_msec() + header_timeout_ms
    var force_quit = false
    while buffer.find("\r\n\r\n") == -1:
        if Time.get_ticks_msec() > deadline:
            push_error("Timeout while reading headers.")
            force_quit = true
            break
        var avail = peer.get_available_bytes()
        if (buffer.length() + avail) > max_bytes:
            push_error("Incoming request sent too many bytes.")
            force_quit = true
            break

        if avail > 0:
            buffer += peer.get_utf8_string(avail)
        else:
            await get_tree().process_frame()

    if force_quit == true:
        peer.disconnect_from_host()
        server.stop()
        push_error("TCP Server was terminated.")
        return {}

    # Extract request line
    var header_part = buffer.substr(0, buffer.find("\r\n\r\n"))
    var request_lines = header_part.split("\r\n", false)
    if request_lines.size() < 1:
        push_error("Invalid header received.")
        return {}
    var request_line = request_lines[0]
    
    var tokens = request_line.split(" ", false)
    if tokens.size() < 2:
        push_error("Invalid request received.")
        return {}

    var method = tokens[0]
    var full_path = tokens[1]

    # Parse GET parameters
    var params: Dictionary = {}
    if method == "GET":
        params = _parse_unsafe_query_params(full_path, allowed_params)
    else:
        push_error("Invalid request method received.")
        return {}

    # Respond with JSON payload
    var json_body = "OAuth completed"
    var resp = "HTTP/1.1 200 OK\r\n" +
               "Content-Type: application/json\r\n" +
               "Content-Length: %d\r\n" +
               "Connection: close\r\n\r\n%s" % [
                   json_body.to_utf8().size(),
                   json_body
               ]
    peer.put_utf8_string(resp)
    peer.disconnect_from_host()
    server.stop()


    return params


# Splits unsafe "/path?key=val&foo=bar" into { key: val, foo: bar }
# Input is untrusted, return early on any mismatch
func _parse_unsafe_query_params(unsafe_path: String, allowed_params: Array[String]) -> Dictionary:
    var dict: Dictionary = {}
    var max_parameters: int = allowed_params.size()

    var qpos: int = unsafe_path.find("?")
    if qpos < 0:
        push_error("Input path doesn't contain query.")
        return {}

    var query_string: String = unsafe_path.substr(qpos + 1)
    var pairs_array: Array = query_string.split("&", false)
    if pairs_array.size() > max_parameters:
        push_error("Input path is over maximum number of parameters")
        return {}

    for pair in pairs_array:
        var key_val: Array = pair.split("=", false)
        if key_val.size() == 2:          
            var key = key_val[0].uri_decode()
            if key not in allowed_params:
                push_error("Input path contains invalid key")
                return {}

            var val = key_val[1].uri_decode()
            dict[key] = val
    return dict


## Attempts to sign into the service. A SarGameServiceRequestObject created
## from the service required to keep track of the individual request,
## and a Dictionary containing service-specific sign in data, should be
## passed in as a parameters. The method may await a coroutine,
## but will return a dictionary containing the result, or an empty one if
## the action failed outright.
func sign_in(p_service_request: SarGameServiceRequest, p_sign_in_data: Dictionary) -> Dictionary:
	if _godot_uro and _godot_uro.get_api():
		if not p_service_request is VSKGameServiceRequestUro:
			push_error("Did not pass a valid VSKGameServiceRequestUro object to sign in request.")
			return {} 
			
		_current_account_address = ""
		
		var domain: String = (p_service_request as VSKGameServiceRequestUro).domain
		if domain.is_empty():
			push_error("Did not pass a valid domain to a sign in request.")
			return {}
		
		var username_or_email: String = p_sign_in_data.get("username_or_email", "")
		if username_or_email.is_empty():
			push_error("Did not pass a valid username or email to sign in request.")
			return {}
			
		var password: String = p_sign_in_data.get("password", "")
		if username_or_email.is_empty():
			push_error("Did not pass a valid password to sign in request.")
			return {}
		
		# Add this request to the active request pool.
		var godot_uro_request: GodotUroRequester = _godot_uro.create_requester(domain, -1)
		_active_service_requests[p_service_request] = godot_uro_request
		
		# Wait for the internal Uro API to respond to our sign in request.
		var result: Dictionary = await _godot_uro.get_api().sign_in_async(
			godot_uro_request,
			username_or_email,
			password
		)
			
		# If we cannot stop the request, that means it may have been
		# externally cancelled and we should cease attempting to update
		# the session.
		if not stop_request(p_service_request):
			return {}

		# I'm not sure if this will ever be empty, but just in case...
		if result.is_empty():
			push_error("Failed to sign_in_async: " + str(result))
			return {}

		var processed_result: Dictionary = _process_result_and_update_session(p_service_request, result)
		return processed_result

	return {}


## Attempts to refresh the token.
func renew_session(p_service_request: SarGameServiceRequest) -> Dictionary:
	if _godot_uro and _godot_uro.get_api():
		if not p_service_request is VSKGameServiceRequestUro:
			push_error("Did not pass a valid VSKGameServiceRequestUro object to a renew request.")
			return {} 
		
		var domain: String = (p_service_request as VSKGameServiceRequestUro).domain
		var tokens: Dictionary = _get_tokens(p_service_request)
		
		# Add this request to the active request pool.
		var godot_uro_request: GodotUroRequester = _godot_uro.create_requester(domain, -1)
		_active_service_requests[p_service_request] = godot_uro_request
		
		var result: Dictionary = await _godot_uro.get_api().renew_session_async(
		godot_uro_request,
		 tokens.get("renewal_token", ""))
			
		if not stop_request(p_service_request):
			return {}
			
		if result.is_empty():
			return {}

		var processed_result: Dictionary = _process_result_and_update_session(p_service_request, result)
		return processed_result

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


## Creates a service request object. This can then be passed into
## into the request API to keep track of the status and callbacks of
## the request.
func create_request(p_data: Dictionary) -> SarGameServiceRequest:
	var service_request: VSKGameServiceRequestUro = VSKGameServiceRequestUro.new()
	service_request.username = p_data.get("username", "")
	service_request.domain = p_data.get("domain", "")
	return service_request

## Will attempt to cancel an ongoing service request. Will return true
## if the request was active and subsequently stopped, and false if
## the request wasn't active and there was nothing to stop.
func stop_request(p_service_request: SarGameServiceRequest) -> bool:
	if is_request_active(p_service_request):
		var godot_uro_request: GodotUroRequester = _active_service_requests.get(p_service_request)
		if godot_uro_request:
			_active_service_requests.erase(p_service_request)
			_godot_uro.get_api().cancel(godot_uro_request)
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
	return _godot_uro.load_selected_id()
		
	
