extends CanvasLayer

signal request_lobby
signal request_game
signal change_local_ready_status
signal request_send_message(message: String)

var player_label: PackedScene = preload("res://Interface/PlayerLabel/PlayerLabel.tscn")

var timer: Timer = Timer.new()

enum PeerState {
	CONNECTING,
	HOSTING
}

var ip: String = "127.0.0.1"
var port: int = 25000
var username: String = ""
var peer_status: PeerState = PeerState.CONNECTING
var is_ready: bool = false

func _ready():
	# Set up the timer that will be used to wait when everyone is ready.
	# Basically, it will give 10 seconds for everyone to make sure that
	# everyone is actually ready.
	timer.connect("timeout", self._on_timer_timeout)
	timer.wait_time = 3.
	add_child(timer)

func _process(_delta: float) -> void:
	if timer.is_stopped():
		var title: Label = $LobbyScreenControl/LobbyScreenScroll/LobbyScreen/PlayerLabelTitle
		title.text = "Players"
		return
	
	else:
		var title: Label = $LobbyScreenControl/LobbyScreenScroll/LobbyScreen/PlayerLabelTitle
		title.text = "Players ({time_left}s)".format({
			"time_left": int(timer.time_left)
		})


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

func set_winner(winner_id: int):
	for id in Globals.players:
		Globals.players[id]["label"].set_loser()
	
	Globals.players[winner_id]["label"].set_winner()

func add_player(id: int, in_is_ready: bool, player_username: String):
	if not id in Globals.players:
		var label: HBoxContainer = player_label.instantiate()
		var color: Color = Color(randf(), randf(), randf())
		label.set_label(player_username, in_is_ready, id)

		label.change_label_color(color)

		$LobbyScreenControl/LobbyScreenScroll/LobbyScreen.add_child(label)

		Globals.players[id] = {
			"username": player_username,
			"is_ready": in_is_ready,
			"label": label,
			"color": color
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
	
	var is_everyone_ready: bool = Globals.is_everyone_ready()
	if is_everyone_ready:
		# Then, start the timer!
		timer.start()
	
	else:
		timer.stop()

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

func _on_timer_timeout() -> void:
	timer.stop()
	request_game.emit()
