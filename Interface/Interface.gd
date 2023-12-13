extends CanvasLayer

signal request_lobby
signal change_local_ready_status
signal request_send_message(message: String)

@export var username_color: Color = Color(0.0, 0.0, 0.0, 1.0)

var player_label: PackedScene = preload("res://Interface/PlayerLabel/PlayerLabel.tscn")

enum PeerState {
	CONNECTING,
	HOSTING
}

var ip: String = "127.0.0.1"
var port: int = 25000
var username: String = ""
var peer_status: PeerState = PeerState.CONNECTING
var is_ready: bool = false

func _on_connect_button_pressed():
	$LoginScreen.hide()
	set_data(PeerState.CONNECTING)
	request_lobby.emit()
	$LobbyScreenControl.show()

func _on_host_button_pressed():
	$LoginScreen.hide()
	set_data(PeerState.HOSTING)
	request_lobby.emit()
	$LobbyScreenControl.show()

func set_data(state: PeerState):
	ip = $LoginScreen/ServerCredentialsContainer/Server.text
	port = int($LoginScreen/ServerCredentialsContainer/Port.text)
	username = $LoginScreen/Username.text
	peer_status = state

func add_player(id: int, in_is_ready: bool, player_username: String):
	if not id in Globals.players:
		var label: HBoxContainer = player_label.instantiate()
		label.set_label(player_username, in_is_ready, id)

		if id == multiplayer.get_unique_id():
			# If this is the local player, change the color of their username
			label.change_username_color(self.username_color)

		$LobbyScreenControl/LobbyScreenScroll/LobbyScreen.add_child(label)

		Globals.players[id] = {
			"username": player_username,
			"is_ready": in_is_ready,
			"label": label,
			"color": Color(randf(), randf(), randf())
		}

	else:
		Globals.players[id]["username"] = player_username

func remove_player(id: int):
	if id in Globals.players:
		Globals.players[id]["label"].queue_free()
		Globals.players.erase(id)
	else:
		print("Trying to remove player that doesn't exist")

func change_ready_status(in_is_ready: bool, in_id: int):
	if in_id in Globals.players:
		Globals.players[in_id]["label"].change_ready_status(in_is_ready)
		Globals.players[in_id]["is_ready"] = in_is_ready

func add_message(in_message: String, in_id: int):
	var message: Globals.Message = Globals.Message.from({
		"id": in_id,
		"username": Globals.players[in_id]["username"],
		"message": in_message,
		"color": Globals.players[in_id]["color"]
	})
	Globals.messages.append(message)
	update_messages()

func update_messages():
	var bbcode_message = Globals.messages[-1].get_bbcode() + "\n"
	$LobbyScreenControl/MessagesContainer/Messages.text += bbcode_message

func _unhandled_input(event):
	# If the local player is in the lobby and presses presses "toggle ready",
	# Then, toggle its ready status.
	if $LobbyScreenControl.visible and event.is_action_pressed("toggle_ready"):
		is_ready = !is_ready
		var label = Globals.players[multiplayer.get_unique_id()]["label"]
		label.change_ready_status(is_ready)
		change_local_ready_status.emit(is_ready)


func _on_send_message(new_text: String) -> void:
	$LobbyScreenControl/MessagesContainer/SendMessage.text = ""
	request_send_message.emit(new_text)
