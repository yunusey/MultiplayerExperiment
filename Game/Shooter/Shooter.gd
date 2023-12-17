extends Node2D

signal died

var bullet_scene: PackedScene = preload("res://Game/Bullet/Bullet.tscn")
var is_dead: bool = false

func set_data(in_id: int, in_lifetime: float, in_position: Vector2, in_color: Color) -> void:
	$ShooterBody.set_data(in_id, in_lifetime, in_color)
	$ShooterBody.position = in_position
	$Bullet.position = in_position
	$Bullet.connect("bullet_destroyed", _on_bullet_destroyed)
	$Bullet.set_data(in_id)

	set_multiplayer_authority(in_id)

func handle_input(delta: float, direction: Vector2) -> void:
	$ShooterBody.handle_input(delta, direction)

func get_lifetime() -> float:
	return $ShooterBody.lifetime

func _on_bullet_destroyed() -> void:
	$Bullet.position = $ShooterBody.position
	$Bullet._ready()

func _on_shooter_body_died():
	is_dead = true
	died.emit()

func hide_self() -> void:
	$ShooterBody.hide()
	$Bullet.hide()
	$Bullet/CollisionShape2D.call_deferred("set_disabled", true)
	$ShooterBody/PlayerInterface/ProgressBar.visible = false
	$ShooterBody/PlayerInterface/Username.visible = false

func show_self() -> void:
	$ShooterBody.show()
	$Bullet.show()
	$Bullet/CollisionShape2D.call_deferred("set_disabled", false)
	$ShooterBody/PlayerInterface/ProgressBar.visible = true
	$ShooterBody/PlayerInterface/Username.visible = true
