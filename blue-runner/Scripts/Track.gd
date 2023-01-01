extends Line2D

export var time : int = 1 # How long should it take to go from point to point
export var is_a_loop : bool = false
export var time_internal : int = 0
export var time_direction : bool = true

var positions : PoolVector2Array = [Vector2(0,0),Vector2(0,0)]
export var auto_pos : bool = true
export var pre_pos : Dictionary = {}

var pos : Dictionary = {}

func _ready():
	positions = points
	for i in range(positions.size()):
		positions[i] += position
	
	if auto_pos:
		# warning-ignore:unassigned_variable
		var time_chunks : PoolIntArray
		time_chunks.resize(positions.size()-1)
		# warning-ignore:unassigned_variable
		var individual_lenght : PoolRealArray
		individual_lenght.resize(positions.size()-1)
		var total_lenght : float = 0
		
		# First, we calculate the distances between points
		for i in range(time_chunks.size()):
			var a : float = abs(positions[i].x - positions[i+1].x)
			var b : float = abs(positions[i].y - positions[i+1].y)
			individual_lenght[i] = sqrt(a*a + b*b)
			total_lenght += individual_lenght[i]
		# We calculate the amount of time the lenghts should be moved in 
		for i in range(time_chunks.size()):
			time_chunks[i] = int(float(time) * (individual_lenght[i] / total_lenght))
		# We reconstuck time, just so there aren't any discrepancies
		time = 0
		for i in range(time_chunks.size()):
			time += time_chunks[i]
		
		var shift : int = 0
		for j in range(positions.size()-1):
			var pos_fraction : Vector2 = Vector2((positions[j].x - positions[j+1].x) / time_chunks[j], (positions[j].y - positions[j+1].y) / time_chunks[j])
			for i in range(time_chunks[j]):
				pos[i+shift] = Vector2(positions[j].x - pos_fraction.x*i, positions[j].y - pos_fraction.y*i)
			shift += time_chunks[j]
			pos[shift] = positions[j+1]
			
	else:
		# IMPORTANT! DON'T REMOVE BECAUSE IT'S "INEFFICIENT", IT'S A WORKAROUND BECAUSE IM DUMB PROBABLY OR SOMETHING
		pos = pre_pos.duplicate()

func _physics_process(_delta):
	position = pos[time_internal]
	if time_direction:
		time_internal += 1
	else:
		time_internal -= 1
	if time_internal == time or time_internal == 0:
		if !is_a_loop:
			time_direction = !time_direction
		else:
			if time_direction:
				time_internal = 0
			else:
				time_internal = time
