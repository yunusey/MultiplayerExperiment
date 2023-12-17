extends HBoxContainer

var username: String = ""
var is_ready: bool = false
var id: int = -1

func set_label(in_username: String, in_is_ready: bool, in_id: int):
	self.username = in_username
	self.id = in_id
	$LabelContainer/Label.text = self.username
	change_ready_status(in_is_ready)

func change_ready_status(in_is_ready: bool):
	self.is_ready = in_is_ready
	$ReadyStatus.material.set_shader_parameter("situation", self.is_ready)

func change_label_color(in_color: Color):
	var new_stylebox_normal = $LabelContainer/Label.get("theme_override_styles/normal").duplicate()
	new_stylebox_normal.bg_color = in_color
	$LabelContainer/Label.set("theme_override_styles/normal", new_stylebox_normal)

func set_winner():
	$LabelContainer/Label.text = "{username} (W)".format({
		"username": username
	})

func set_loser():
	$LabelContainer/Label.text = "{username} (L)".format({
		"username": username
	})
