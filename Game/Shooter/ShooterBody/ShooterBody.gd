extends Area2D

signal died

const SPEED = 300.0

var player_id: int
var lifetime: float = 1.0

func set_data(in_id: int, in_lifetime: float):
	self.player_id = in_id
	self.lifetime = in_lifetime

func handle_input(delta, direction: Vector2):
	position += direction * SPEED * delta

func _process(_delta):
	if is_multiplayer_authority():
		look_at(get_global_mouse_position())

	$PlayerInterface.transform.origin = position
	$PlayerInterface/ProgressBar.value = lifetime * 100

func _on_body_entered(body: Node2D):
	if body.is_in_group("bullets") and body.player_id != player_id and body.visible:
		lifetime -= Globals.bullet_damage

		if lifetime <= 0.01:
			died.emit()
