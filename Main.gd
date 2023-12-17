extends Node2D

func _ready():
	# Set up the networking.
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(failed_connect)
	multiplayer.server_disconnected.connect(disconnected_from_server)

func _on_interface_request_lobby():
	# If the local player wants to login to the lobby, this function
	# is called.
	if $Interface.peer_status == $Interface.PeerState.HOSTING:
		var peer = ENetMultiplayerPeer.new()
		peer.create_server($Interface.port, 5)
		multiplayer.multiplayer_peer = peer
		send_player_info($Interface.username, false, multiplayer.get_unique_id())

	elif $Interface.peer_status == $Interface.PeerState.CONNECTING:
		var peer = ENetMultiplayerPeer.new()
		peer.create_client($Interface.ip, $Interface.port)
		multiplayer.multiplayer_peer = peer
	
	if multiplayer.is_server():
		print("Server created, waiting for players")

func _on_interface_request_send_message(message: String):
	# This function is called when the local player wants to send
	# a message to the server.
	if multiplayer.is_server():
		# If the sender is the server, we send the message to everyone.
		notify_player_message(message, multiplayer.get_unique_id())
	else:
		# If the sender is not the server, we send the message to the server.
		notify_player_message.rpc_id(1, message, multiplayer.get_unique_id())

func _on_interface_change_local_ready_status(in_is_ready: bool):
	# This function is called when the local player changes its ready status
	# (by clicking space on the interface).
	if multiplayer.is_server():
		# If the sender is the server, we send the ready status to everyone.
		notify_player_status(in_is_ready, multiplayer.get_unique_id())
	else:
		# If the sender is not the server, we send the ready status to the server.
		notify_player_status.rpc_id(1, in_is_ready, multiplayer.get_unique_id())

func _on_interface_request_game():
	$Interface.hide()
	$Game.initialize_game()
	$Game.show()

func _on_game_finished(winner_id: int):
	$Game.hide()
	$Interface.show()
	$Interface.set_winner(winner_id)

@rpc("any_peer")
func send_player_info(username: String, in_is_ready: bool, id: int):
	# This method gets called each time a new player sends its
	# info to the server. It will be received by all the players
	# to add them to the local lobby.
	$Interface.add_player(id, in_is_ready, username)
	
	if multiplayer.is_server():
		# If the receiver is the server, we need to send the 
		# player info that was received to the other players.
		# We send every info of all the players to everyone.
		for player_id in Globals.players:
			var player = Globals.players[player_id]
			send_player_info.rpc(
					player["username"],
					player["is_ready"],
					player_id
					)

@rpc("any_peer")
func notify_player_status(is_ready: bool, id: int):
	# Change the ready status for the player with the given id.
	$Interface.change_ready_status(is_ready, id)

	if multiplayer.is_server():
		# Notify the other players that the player that notified
		# the server changed its ready status.
		notify_player_status.rpc(is_ready, id)

@rpc("any_peer")
func notify_player_message(message: String, id: int):
	# Change the ready status for the player with the given id.
	$Interface.add_message(message, id)

	if multiplayer.is_server():
		# Notify the other players that the player that notified
		# the server changed its ready status.
		notify_player_message.rpc(message, id)

# These functions are for the networking notifications.
# Not much to explain here.
func peer_connected(id):
	print("Peer connected " + str(id))

func peer_disconnected(id):
	$Interface.remove_player(id)
	print("Peer disconnected " + str(id))

func connected_to_server():
	send_player_info.rpc_id(1, $Interface.username, false, multiplayer.get_unique_id())
	print("Connected to server " + str(multiplayer.get_unique_id()))

func failed_connect():
	print("Failed to connect to server ")

func disconnected_from_server():
	print("Disconnected from server ")

