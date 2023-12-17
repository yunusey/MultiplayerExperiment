extends Node

var players: Dictionary = {}

func is_everyone_ready() -> bool:
	# Check if everyone is ready in players
	for player_id in players:
		var player = players[player_id]
		if !player["is_ready"]:
			return false
	
	return true

var username_color: Color
# This is the color of the username of the local player.
# It will be set by Interface once the program starts.

class Message:
	const FORMATTED_MESSAGE = "[color=#{color}][i]{username}[/i][/color]: {message}"

	var id: int
	var username: String
	var message: String
	var color: Color

	static func from(in_dict: Dictionary):
		var new_message = Message.new()
		new_message.id = in_dict["id"]
		new_message.username = in_dict["username"]
		new_message.message = in_dict["message"]
		new_message.color = in_dict["color"]
		
		return new_message
	
	func _to_string():
		return str(id, " ", username, " ", message)
	
	func get_bbcode() -> String:
		return FORMATTED_MESSAGE.format({
			"color": color.to_html(false),
			"username": username,
			"message": message
		})

var messages: Array[Message] = []

var bullet_damage: float = .2
