extends Node2D

var score = 0
var lives = 5
var is_professor_looking = false
var professor_speed = 2.5
var professor_speed_decay = 0.92
var last_mouse_pos = Vector2()
var game_started = false

var paper_ball
var professor
var timer
var score_label
var life_label
var warning_label
var game_over_label
var instruction_label
var countdown_label

# For life loss cooldown
var can_lose_life = true
var life_loss_cooldown = 1.0

# Button references
var restart_button
var pick_other_game_button

func _ready():
	randomize()

	paper_ball = get_node("PaperBall")
	professor = get_node("Professor")
	timer = get_node("Timer_profLook")
	score_label = get_node("ScoreLabel")
	life_label = get_node("LifeLabel")
	warning_label = get_node("WarningLabel")
	game_over_label = get_node("GameOverLabel")
	instruction_label = get_node("InstructionLabel")
	countdown_label = get_node("CountdownLabel")
	restart_button = get_node("Restart")
	pick_other_game_button = get_node("PickotherGame")

	paper_ball.visible = true
	paper_ball.z_index = 10
	warning_label.visible = false
	game_over_label.visible = false
	countdown_label.visible = false
	instruction_label.visible = true
	restart_button.visible = false
	pick_other_game_button.visible = false
	set_process(false)  # Don't start game logic yet

	# Start the countdown after 2 seconds to let players read
	yield(get_tree().create_timer(2.0), "timeout")
	start_countdown()

func start_countdown():
	instruction_label.visible = false
	countdown_label.visible = true

	var countdown = ["3", "2", "1", "GO!"]
	for number in countdown:
		countdown_label.text = number
		yield(get_tree().create_timer(1.0), "timeout")

	countdown_label.visible = false
	game_started = true
	set_process(true)

	timer.wait_time = professor_speed
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.start()

	last_mouse_pos = get_viewport().get_mouse_position()
	update_ui()

func _process(delta):
	if not game_started:
		return

	var current_mouse_pos = get_viewport().get_mouse_position()
	paper_ball.position = current_mouse_pos

	var is_moving = current_mouse_pos.distance_to(last_mouse_pos) > 0

	if is_professor_looking and is_moving and can_lose_life:
		lives -= 1
		can_lose_life = false
		update_ui()
		print("Caught moving! Lives left: ", lives)
		yield(get_tree().create_timer(life_loss_cooldown), "timeout")
		can_lose_life = true
		if lives <= 0:
			end_game()
	else:
		if not is_professor_looking:
			score += delta * 7
			update_ui()

			if score >= 100:
				win_game()

	last_mouse_pos = current_mouse_pos

func _on_Timer_timeout():
	warning_label.visible = true
	warning_label.text = "!!!"

	yield(get_tree().create_timer(0.3), "timeout")

	warning_label.visible = false

	is_professor_looking = randi() % 2 == 0 or randf() < 0.2

	if is_professor_looking:
		professor.texture = load("res://Assets/prof_papertoss/prof_mad.png")
	else:
		professor.texture = load("res://Assets/prof_papertoss/prof_seating.png")

	professor_speed *= professor_speed_decay
	professor_speed = max(professor_speed, 0.5)
	timer.wait_time = professor_speed
	timer.start()

func update_ui():
	score_label.text = "Score: " + str(int(score))
	life_label.text = "Lives: " + str(lives)

func end_game():
	timer.stop()
	set_process(false)
	game_over_label.visible = true
	game_over_label.text = "GAME OVER"
	game_over_label.modulate = Color(1, 0, 0, 1)
	print("GAME OVER - Final Score: ", int(score))
	restart_button.visible = true
	pick_other_game_button.visible = true

func win_game():
	timer.stop()
	set_process(false)
	game_over_label.visible = true
	game_over_label.text = "YOU WIN!"
	game_over_label.modulate = Color(0, 1, 0, 1)
	print("YOU WIN! Final Score: ", int(score))
	restart_button.visible = true
	pick_other_game_button.visible = true

func _on_Restart_pressed():
	get_tree().change_scene("res://Scenes/PaperToss.tscn")

func _on_PickotherGame_pressed():
	get_tree().change_scene("res://Scenes/Pick_Minigames.tscn")
