extends Node2D

const colors = preload("res://scripts/colors.gd")

enum STRATEGY {
	DEFENSIVE,
	AGGRESSIVE,
	BALANCED,
}

export (STRATEGY) var strategy = STRATEGY.DEFENSIVE
export (colors.TYPE) var unit_type = colors.TYPE.NEUTRAL

const AI_TICK = 0.2
var delta_since_tick = 0.0

func _ready():
	assert(unit_type != colors.TYPE.PLAYER)
	randomize()

func _physics_process(delta):
	delta_since_tick += delta
	if delta_since_tick >= AI_TICK:
		think()
		delta_since_tick = 0.0

func think():
	var units = get_tree().get_nodes_in_group("units_" + str(unit_type))
	var bases = get_tree().get_nodes_in_group("bases_" + str(unit_type))
	match strategy:
		STRATEGY.DEFENSIVE:
			defense(units, bases)
		STRATEGY.AGGRESSIVE:
			aggression(units, bases)
		STRATEGY.BALANCED:
			balanced(units, bases)

func defense(units, bases):
	var divided = divide_units(units, bases)
	
	for i in range(len(bases)):
		var b = bases[i]
		var base_units = divided[i]

		# Prioritize base defense
		if b.is_under_attack:
			prob_go_to(base_units, b.aggressor_pos, 0.8)
			continue

		var under_attack = false
		for unit in base_units:
			if unit.is_under_attack:
				prob_go_to(base_units, unit.aggressor_pos, 0.5)
				under_attack = true
				break

		# Return to base
		if not under_attack:
			prob_go_to(base_units, b.global_position, 0.5)
			idle_if_close_to_base(base_units, b.global_position, 1)

func aggression(units, bases):
	pass

func balanced(units, bases):
	pass

## Helpers
	
func prob_go_to(units, pos, prob):
	for u in units:
		if randf() < prob:
			u.go_to(pos)

const IDLE_DISTANCE_SQUARED = 200*200

func idle_if_close_to_base(units, pos, prob):
	for u in units:
		print(u.global_position.distance_squared_to(pos))
		if u.global_position.distance_squared_to(pos) <= IDLE_DISTANCE_SQUARED and randf() < prob:
			u.go_idle()

func divide_units(units, bases):
	# Divide units into groups based on the bases they are closest to
	if len(bases) == 0:
		return [units]
	var res = []
	for b in bases:
		res.append([])
	for unit in units:
		var closest_i = -1
		var closest_distsq = -1
		for i in range(len(bases)):
			var distsq = unit.global_position.distance_squared_to(bases[i].global_position)
			if distsq < closest_distsq or closest_i == -1:
				closest_i = i
				closest_distsq = distsq
		res[closest_i].append(unit)
	
	return res
