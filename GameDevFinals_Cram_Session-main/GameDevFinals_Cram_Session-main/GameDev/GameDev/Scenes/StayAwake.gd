extends Node2D

# Gameplay values
var max_stamina := 100.0
var current_stamina := 50.0
var base_depletion_rate := 10.0
var stamina_depletion_rate := base_depletion_rate
var stamina_gain := 15.0
var game_duration := 30
var time_left := game_duration
var game_over := false
var game_started := false

var awake_zone_min := 40.0
var awake_zone_max := 70.0
var countdown_value := 4

# Nodes
onready var stamina_bar := $StaminaBar
onready var countdown_timer := $CountdownTimer
onready var game_timer := $GameTimer
onready var countdown_image := $CountdownImage
onready var status_image := $StatusImage
onready var timer_label := $TimerLabel
onready var dim_overlay := $DimOverlay
onready var game_over_image := $GameOverImage

# Image assets
const COUNTDOWN_IMAGES = {
	4: preload("res://Assets/StayAwake/countdown_start.png"),
	3: preload("res://Assets/StayAwake/countdown_3.png"),
	2: preload("res://Assets/StayAwake/countdown_2.png"),
	1: preload("res://Assets/StayAwake/countdown_1.png")
}
const GAME_OVER_IMAGE = preload("res://Assets/StayAwake/gameoverscreen.png")

func _ready():
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina
	stamina_bar.visible = true
	stamina_bar.modulate.a = 0.0

	countdown_image.texture = COUNTDOWN_IMAGES[4]
	countdown_image.visible = true

	status_image.visible = false
	timer_label.visible = false
	game_over_image.visible = false
	timer_label.text = "Time Left: %ds" % game_duration

	countdown_timer.wait_time = 1.0
	countdown_timer.connect("timeout", self, "_on_CountdownTimer_timeout")
	countdown_timer.start()

	game_timer.wait_time = 1.0
	game_timer.connect("timeout", self, "_on_GameTimer_timeout")

func _process(delta):
	if game_over or not game_started:
		return

	stamina_depletion_rate += delta * 0.05
	current_stamina -= stamina_depletion_rate * delta
	current_stamina = clamp(current_stamina, 0, max_stamina)
	stamina_bar.value = current_stamina

	# Adjust awake zone
	awake_zone_min = lerp(40.0, 45.0, 1.0 - float(time_left) / game_duration)
	awake_zone_max = lerp(70.0, 55.0, 1.0 - float(time_left) / game_duration)

	# Update dim overlay based on stamina level
	var dim_strength := 1.0 - clamp((current_stamina - awake_zone_min) / (awake_zone_max - awake_zone_min), 0.0, 1.0)
	dim_overlay.color = Color(0, 0, 0, lerp(0.0, 0.5, dim_strength))  # 0.5 = max dim before failure

	if current_stamina < awake_zone_min or current_stamina > awake_zone_max:
		game_over = true
		game_timer.stop()
		timer_label.visible = false
		fade_in_screen("fail")

func _input(event):
	if game_over or not game_started:
		return

	if event.is_action_pressed("ui_accept"):
		current_stamina += stamina_gain
		current_stamina = clamp(current_stamina, 0, max_stamina)

func _on_CountdownTimer_timeout():
	countdown_value -= 1

	if countdown_value == 3:
		fade_in_bar()

	if countdown_value > 0:
		countdown_image.texture = COUNTDOWN_IMAGES[countdown_value]
	else:
		countdown_image.visible = false
		game_started = true
		game_timer.start()
		timer_label.visible = true
		countdown_timer.stop()

func _on_GameTimer_timeout():
	if game_over:
		return

	time_left -= 1
	timer_label.text = "Time Left: %ds" % time_left

	if time_left <= 0:
		game_over = true
		game_timer.stop()
		timer_label.visible = false
		fade_in_screen("win")

func fade_in_bar():
	var alpha := 0.0
	var step := 0.05
	while alpha < 1.0:
		alpha += step
		stamina_bar.modulate.a = alpha
		yield(get_tree().create_timer(0.02), "timeout")

func fade_in_screen(result: String):
	var alpha := 0.0
	var target_alpha := 0.7
	var step := 0.02
	dim_overlay.visible = true
	dim_overlay.color = Color(0, 0, 0, 0)

	call_deferred("_fade_in_loop", alpha, target_alpha, step, result)

func _fade_in_loop(alpha, target, step, result):
	while alpha < target:
		alpha += step
		dim_overlay.color = Color(0, 0, 0, alpha)
		yield(get_tree().create_timer(0.02), "timeout")

	if result == "win":
		timer_label.text = "You Survived!"
		timer_label.visible = true
	else:
		game_over_image.texture = GAME_OVER_IMAGE
		game_over_image.visible = true
