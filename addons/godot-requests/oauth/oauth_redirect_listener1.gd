extends Node
class_name OAuthRedirectListener

var port: int
var bind_address: String
var timeout_ms: int
var header_timeout_ms: int
var max_bytes: int = 1000
var allowed_params: Array[String] = ["code", "state"]
var _server: TCPServer
var _peer: StreamPeerTCP

func _init(_port: int, _bind_address: String = "127.0.0.1", _timeout_ms: int = 5000) -> void:
    
    port = _port
    bind_address = _bind_address
    timeout_ms = _timeout_ms
    header_timeout_ms = timeout_ms
    
    _server = TCPServer.new()

# Starts listening, handles one GET request, then returns parsed params.
# Listens on `port`, takes the first GET request, parses query params, responds JSON, returns params.
func listen(port: int, bind_address: String = "*", timeout_ms: int = 5000) -> Dictionary:

    var header_timeout_ms: int = timeout_ms
    
    var err = server.listen(port, bind_address)
    if err != OK:
        push_error("Failed to listen on %s:%d (err %d)" % [bind_address, port, err])
        return {}

    # Wait for incoming connection
    while not _server.is_connection_available():
        await get_tree().process_frame()
    
    _peer = server.take_connection()
    _peer.set_no_delay(true)

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
        push_error("TCP Server was terminated.")
        _stop_and_cleanup()
        return {}

    # Extract request line
    var header_part = buffer.substr(0, buffer.find("\r\n\r\n"))
    var lines = header_part.split("\r\n", false)
    if lines.size() < 1:
        push_error("Invalid header received.")
        _stop_and_cleanup()
        return {}

    var request_line = lines[0]    
    var tokens = request_line.split(" ", false)
    if tokens.size() < 2:
        push_error("Invalid request received.")
        _stop_and_cleanup()
        return {}

    var method = tokens[0]
    var full_path = tokens[1]

    # Parse GET parameters
    var params: Dictionary = {}
    if method == "GET":
        params = _parse_unsafe_query_params(full_path, allowed_params)
    else:
        push_error("Unsupported HTTP method.")
        _stop_and_cleanup()
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
    _stop_and_cleanup()

    return params

# Internal cleanup of connections and server
func _stop_and_cleanup() -> void:
    if _peer and _peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
        _peer.disconnect_from_host()
    if _server.is_listening():
        _server.stop()

# Splits unsafe "/path?key=val&foo=bar" into { key: val, foo: bar }
# Input is untrusted, return early on any mismatch
func _parse_unsafe_query_params(unsafe_path: String) -> Dictionary:
    var dict: Dictionary = {}
    var max_parameters: int = allowed_params.size()

    var qpos: int = unsafe_path.find("?")
    if qpos < 0:
        push_error("Input path doesn't contain query string.")
        return {}

    var query_string: String = unsafe_path.substr(qpos + 1)
    var pairs_array: Array = query_string.split("&", false)
    if pairs_array.size() > max_parameters:
        push_error("Input path is over maximum number of parameters")
        return {}

    for pair in pairs_array:
        var key_val: Array = pair.split("=", false)
        if key_val.size() != 2:
            push_error("Invalid query found, parse failed.")
            return {}
        
        var key = key_val[0].uri_decode()
        if key not in allowed_params:
          push_error("Input path contains invalid key")
          return {}

        var val = key_val[1].uri_decode()
        dict[key] = val
    return dict
