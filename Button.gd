extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var button_down = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	var pos = get_global_mouse_position()
	var offset = pos - global_position()
	if button_down:
		set_global_position(pos - offset)


func _on_Button_button_down():
	button_down = true


func _on_Button_button_up():
	button_down = false
