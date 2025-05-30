extends Node2D

# === Settings ===
export(int) var total_rounds = 3
export(int) var sequence_length = 5
export(float) var display_time = 2.0

# === Runtime State ===
var current_round = 0
var correct_count = 0
var mistake_count = 0
var sequence = ""

# === References (Godot 3.5 Style) ===
onready var background = get_node("Background")
onready var professor = get_node("Professor")
onready var board_label = get_node("BoardLabel")
onready var notebook = get_node("Notebook")
onready var input_field = get_node("InputField")
onready var instruction_label = get_node("InstructionLabel")
onready var timer = get_node("Timer")
onready var finalrank_label = get_node("FinalRankLabel")
var restart_button
var pick_other_game_button

# === Professor faces ===
var professor_faces = [
	"res://Assets/professor_quicknotes/prof_normal.png",
	"res://Assets/professor_quicknotes/prof_mad1.png"
]

func _ready():
	randomize()
	restart_button = get_node("Restart")
	pick_other_game_button = get_node("PickotherGames")
	restart_button.visible = false
	pick_other_game_button.visible = false
	start_round()

func reset_round():
	board_label.visible = true
	notebook.visible = false
	input_field.visible = false
	input_field.editable = false
	input_field.text = ""
	instruction_label.text = "Memorize the letters!"
	professor.texture = load(professor_faces[0])

func start_round():
	reset_round()
	sequence = generate_sequence(sequence_length)
	board_label.text = sequence
	timer.start(display_time)

func generate_sequence(length):
	var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var result = ""
	for i in range(length):
		result += letters[randi() % letters.length()]
	return result

func _on_Timer_timeout():
	if current_round < total_rounds:
		board_label.visible = false
		notebook.visible = true
		input_field.visible = true
		input_field.editable = true
		input_field.grab_focus()
		instruction_label.text = "Type what you remember"

func _on_InputField_text_entered(text):
	input_field.editable = false
	current_round += 1

	if current_round < total_rounds:
		if text.strip_edges().to_upper() == sequence:
			correct_count += 1
			instruction_label.text = "Correct!"
		else:
			mistake_count += 1
			instruction_label.text = "Wrong! Correct was: " + sequence
			update_professor_face()

		yield(get_tree().create_timer(2.0), "timeout")
		start_round()
	else:
		if text.strip_edges().to_upper() == sequence:
			correct_count += 1
		else:
			mistake_count += 1
			update_professor_face()
		show_results()

func update_professor_face():
	var index = clamp(mistake_count, 0, professor_faces.size() - 1)
	professor.texture = load(professor_faces[index])

func show_results():
	notebook.visible = false
	input_field.visible = false
	instruction_label.visible = false
	board_label.visible = true
	board_label.text = "You got %d out of %d correct!" % [correct_count, total_rounds]

	var rank = "F"
	if correct_count == 3:
		rank = "A"
	elif correct_count == 2:
		rank = "B"
	elif correct_count == 1:
		rank = "C"

	finalrank_label.text = "Final Rank: %s\nPress a button to continue!" % rank
	restart_button.visible = true
	pick_other_game_button.visible = true

func _on_Restart_pressed():
	get_tree().change_scene("res://Scenes/QuickNotes.tscn")


func _on_PickotherGames_pressed():
	get_tree().change_scene("res://Scenes/Pick_Minigames.tscn")
