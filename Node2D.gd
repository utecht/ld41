extends Node2D
signal grabbed
signal dropped

var button_down = false
var offset
export (String) var letter

func _ready():
	$Button.text = letter

func highlight():
	$Highlight.visible = true
	
func reset(new_letter):
	letter = new_letter
	$Button.text = letter
	$Highlight.visible = false

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	var pos = get_global_mouse_position()
	if button_down:
		global_position = pos - offset

func _on_Button_button_down():
	offset = get_global_mouse_position() - global_position
	button_down = true
	emit_signal("grabbed", self)

func _on_Button_button_up():
	button_down = false
	emit_signal("dropped", self)