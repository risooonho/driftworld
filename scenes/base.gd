extends StaticBody2D

const colors = preload("res://scripts/colors.gd")

export (colors.TYPE) var unit_type = colors.TYPE.NEUTRAL

export (float) var SPAWN_SECS = 1.0
export (float) var SPAWN_RING_WIDTH = 75.0

onready var timer = Timer.new()
onready var level = get_parent()
onready var spawn_radius = $shape.shape.radius

const unit_scene = preload("res://scenes/unit.tscn")

func _ready():
	randomize()
	
	$sprite.modulate = colors.COLORS[unit_type].darkened(0.15)
	add_to_group("bases")
	
	add_child(timer)
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(SPAWN_SECS)
	timer.set_one_shot(false)
	timer.start()

func _on_timer_timeout():
	var unit = unit_scene.instance()
	unit.global_position = generate_spawn_position()
	unit.unit_type = unit_type
	level.add_child(unit)

func generate_spawn_position():
	var angle = randf() * PI * 2
	var direction = Vector2(cos(angle), sin(angle))
	var ring_offset = randf() * SPAWN_RING_WIDTH
	return global_position + direction * (spawn_radius + ring_offset)
