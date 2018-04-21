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
var wordlist = []
var to_be_replaced = []
var scoring_words = []

func _ready():
	randomize()
	var word_file = File.new()
	word_file.open("res://small_words.txt", word_file.READ)
	while !word_file.eof_reached():
		var line = word_file.get_line()
		wordlist.append(line)
	word_file.close()
	
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

func check_horizontal(start, end):
	var word = ""
	for i in range(start, end + 1):
		word += board[i].letter
	if wordlist.has(word.to_lower()):
		return [range(start, end + 1), word]

func search_horizontal(row_num):
	#print("searching - ", index)
	var results = []
	var start_row = row_num * 5
	var end_row = start_row + 4
	# is the entire row a word
	results.append(check_horizontal(start_row, end_row))
	# check the 4s
	results.append(check_horizontal(start_row, end_row - 1))
	results.append(check_horizontal(start_row + 1, end_row))
	# check the 3s
	results.append(check_horizontal(start_row, end_row - 2))
	results.append(check_horizontal(start_row + 1, end_row - 1))
	results.append(check_horizontal(start_row + 2, end_row))
	return results
	
func check_vertical(start, end):
	var word = ""
	for i in range(start, end + 5, 5):
		#print("start: ", start, " end: ", end, " i: ", i)
		word += board[i].letter
	if wordlist.has(word.to_lower()):
		return [range(start, end + 5, 5), word]

func search_vertical(column_num):
	var results = []
	var start_col = column_num
	var end_col = column_num + 20
	# is entire column a word
	results.append(check_vertical(start_col, end_col))
	# check the 4s
	results.append(check_vertical(start_col, end_col - 5))
	results.append(check_vertical(start_col + 5, end_col))
	# check the 3s
	results.append(check_vertical(start_col, end_col - 10))
	results.append(check_vertical(start_col + 5, end_col - 5))
	results.append(check_vertical(start_col + 10, end_col))
	return results

func word_search():
	var results = []
	for starting_pos in range(5):
		for result in search_horizontal(starting_pos):
			if result != null and !results.has(result):
				results.append(result)
		for result in search_vertical(starting_pos):
			if result != null and !results.has(result):
				results.append(result)
	print(results)
	if !results.empty():
		for letter in board:
			letter.scoring()
		scoring_words = results
		$Score.start()

func _picked_up(letter):
	current_letter = letter
	starting_pos = letter.global_position
	dragging = true

func _dropped(letter):
	letter.global_position = starting_pos
	dragging = false
	word_search()

func _process(delta):
	if dragging:
		var pos = get_global_mouse_position() - global_position + Vector2(25, 25)
		pos.x = clamp(pos.x, 0, 249)
		pos.y = clamp(pos.y, 0, 249)
		var cur_x = int(pos.x) / 50
		var cur_y = int(pos.y) / 50
		var index = (cur_y * 5) + cur_x
		if board.find(current_letter) != index:
			var swap = board[index]
			var swap_index = board.find(current_letter)
			board[swap_index] = swap
			board[index] = current_letter
			var new_pos = swap.global_position
			swap.global_position = starting_pos
			starting_pos = new_pos


func _on_Reset_timeout():
	for letter_index in to_be_replaced:
		board[letter_index].reset(LETTERS[randi() % LETTERS.size()])
	to_be_replaced = []
	$ScoreLabel.text = ""
	for letter in board:
		letter.scoring_over()


func _on_Score_timeout():
	if scoring_words.empty():
		print("Resetting")
		$Score.stop()
		$Reset.start()
	else:
		var result = scoring_words.pop_front()
		for letter_index in result[0]:
			if !to_be_replaced.has(letter_index):
				to_be_replaced.append(letter_index)
			board[letter_index].highlight()
		$ScoreLabel.text = str($ScoreLabel.text, result[1], "\n")
		$Score.start()
