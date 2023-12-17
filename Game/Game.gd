extends Node2D

signal game_finished(winner_id: int)

var shooter_scene: PackedScene = preload("res://Game/Shooter/Shooter.tscn")
var bullet_scene: PackedScene = preload("res://Game/Bullet/Bullet.tscn")

var local_id: int = 1
var is_server: bool = false
var shooters: Dictionary = {}

func initialize_game() -> void:
	for player in $Players.get_children():
		$Players.remove_child(player)
		player.queue_free()

	$GameInterface.visible = true

	self.local_id = get_tree().get_multiplayer().get_unique_id()
	self.is_server = get_tree().get_multiplayer().is_server()
	shooters.clear()

	for id in Globals.players:
		var shooter: Node2D = shooter_scene.instantiate()
		shooter.set_data(id, 1., Vector2(randf() * 1000, randf() * 1000), Globals.players[id].color)
		shooters[id] = shooter
		$Players.add_child(shooter)
	
	shooters[local_id].connect("died", _on_local_shooter_died)

func _process(delta: float):
	if visible and shooters[local_id].is_dead:
		return

	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction and local_id in shooters:
		shooters[local_id].handle_input(delta, direction)

	var lifetime: float = shooters[local_id].get_lifetime() if local_id in shooters else 0.
	$GameInterface/ProgressBar.value = lifetime * 100

func _on_local_shooter_died():
	$GameInterface/ProgressBar.value = 0.
	if is_server:
		kill_player(local_id)
	else:
		kill_player.rpc_id(1, local_id)

@rpc("any_peer")
func kill_player(id: int) -> void:
	if is_server:
		kill_player.rpc(id)

	shooters[id].is_dead = true
	shooters[id].hide_self()

	var alive_shooters: Array = get_alive_shooters()
	if alive_shooters.size() == 1:
		$GameInterface.visible = false
		var winner_id = alive_shooters[0]
		shooters[winner_id].hide_self()
		game_finished.emit(winner_id)

func get_alive_shooters() -> Array:
	var alive_shooters: Array = []
	for id in shooters:
		if not shooters[id].is_dead:
			alive_shooters.append(id)
	return alive_shooters
