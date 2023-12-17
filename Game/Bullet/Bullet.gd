extends CharacterBody2D

signal bullet_destroyed

const SPEED: float = 300.0
var player_id: int # Bullet's owner's id
var direction: Vector2

func _ready() -> void:
	direction = global_position.direction_to(get_global_mouse_position())
	$Timer.start()

func _physics_process(_delta: float) -> void:
	velocity = direction * SPEED
	move_and_slide()

func _on_timer_timeout() -> void:
	bullet_destroyed.emit()

func set_data(in_id: int) -> void:
	player_id = in_id

