extends Position2D

export (PackedScene) var Letter
var board = []
var size = 25
var LETTERS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
			   'K', 'I', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
			   'T', 'U', 'V', 'X', 'Y', 'Z']
var starting_pos
var current_letter
var dragging = false

func _ready():
	for i in range(size):
		var letter = Letter.instance()
		letter.letter = LETTERS[randi() % LETTERS.size()]
		var x = (i % 5) * 50
		var y = (i/5) * 50
		letter.global_position = Vector2(x, y)
		add_child(letter)
		letter.connect("grabbed", self, "_picked_up")
		letter.connect("dropped", self, "_dropped")
		board.append(letter)

func _picked_up(letter):
	current_letter = letter
	starting_pos = letter.global_position
	dragging = true

func _dropped(letter):
	letter.global_position = starting_pos
	dragging = false

func _process(delta):
	var pos = get_global_mouse_position() - global_position + Vector2(25, 25)
	pos.x = clamp(pos.x, 0, 249)
	pos.y = clamp(pos.y, 0, 249)
	var cur_x = int(pos.x) / 50
	var cur_y = int(pos.y) / 50
	var index = (cur_y * 5) + cur_x
	if dragging and board.find(current_letter) != index:
		var swap = board[index]
		var swap_index = board.find(current_letter)
		board[swap_index] = swap
		board[index] = current_letter
		var new_pos = swap.global_position
		swap.global_position = starting_pos
		starting_pos = new_pos
