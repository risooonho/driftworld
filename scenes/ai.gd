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
	var divided = divide_units(units, bases)
	var enemy_bases = get_enemy_bases()

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

		# Go on the offensive
		if not under_attack:
			var close = get_close_bases(enemy_bases, b.global_position)
			var rand_base = pick_random(close)
			if rand_base:
				prob_go_to(base_units, rand_base.global_position, 0.5)
	
	# If you have no bases, just attack
	if len(bases) == 0:
		for u in units:
			var close = get_close_bases(enemy_bases, u.global_position)
			var rand_base = pick_random(close)
			if rand_base:
				prob_go_to([u], rand_base.global_position, 1.0)

func balanced(units, bases):
	pass

## Helpers

func pick_random(arr):
	if arr:
		return arr[randi() % arr.size()]
	return null

const CLOSENESS_THRESHOLD = 300
func get_close_bases(bases, from_pos):
	var closest = null
	var closest_dist = -1
	for b in bases:
		var dist = from_pos.distance_squared_to(b.global_position)
		if dist < closest_dist or closest == null:
			closest = b
			closest_dist = dist
	
	if closest == null:
		return []
	var res = [closest]
	for b in bases:
		if from_pos.distance_squared_to(b.global_position) - closest_dist < CLOSENESS_THRESHOLD:
			res.append(b)
	return res

func get_enemy_bases():
	var bases = []
	for c in colors.TYPE:
		var col = colors.TYPE[c]
		if col == unit_type or col in colors.ALLIES[unit_type]:
			continue
		var bs = get_tree().get_nodes_in_group("bases_" + str(col))
		for b in bs:
			bases.append(b)
	return bases
	
func prob_go_to(units, pos, prob):
	for u in units:
		if randf() < prob:
			u.go_to(pos)

const IDLE_DISTANCE_SQUARED = 200*200

func idle_if_close_to_base(units, pos, prob):
	for u in units:
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
