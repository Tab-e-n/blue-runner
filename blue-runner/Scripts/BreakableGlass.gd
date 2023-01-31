extends StaticBody2D

var scale_internal : Vector2

var break_active : bool = false
var break_position : Vector2

var line_offset : float = 2

var rand : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	scale_internal = scale
	scale = Vector2(1, 1)
	$glass/stained_glass.region_rect.size = scale_internal * 64
	$glass/blight.region_rect.size = scale_internal * 64
	$CollisionShape2D.scale = scale_internal
	$CollisionShape2D.position = scale_internal * 64
	$glass/stained_glass/Outline.points[0].x = line_offset
	$glass/stained_glass/Outline.points[0].y = line_offset
	$glass/stained_glass/Outline.points[1].x = scale_internal.x * 128 - line_offset
	$glass/stained_glass/Outline.points[1].y = line_offset
	$glass/stained_glass/Outline.points[2].x = scale_internal.x * 128 - line_offset
	$glass/stained_glass/Outline.points[2].y = scale_internal.y * 128 - line_offset
	$glass/stained_glass/Outline.points[3].x = line_offset
	$glass/stained_glass/Outline.points[3].y = scale_internal.y * 128 - line_offset
	$glass/stained_glass/Outline.points[4].x = line_offset
	$glass/stained_glass/Outline.points[4].y = line_offset

func _physics_process(_delta):
	if break_active:
		$CollisionShape2D.disabled = true
		break_active = false
		var prev_pos : Vector2 = position
		position = break_position
		var shift : Vector2 = Vector2(prev_pos.x - break_position.x, prev_pos.y - break_position.y)
		$glass/stained_glass.position += shift
		$glass/blight.position += shift
		$line1.rotation_degrees = rand.randi_range(0, 360)
		$line1.visible = true
		$line2.rotation_degrees = rand.randi_range(0, 360)
		$line2.visible = true
		$line3.rotation_degrees = rand.randi_range(0, 360)
		$line3.visible = true
		$particle_circle.visible = true
		$anim.play("Break")
		
		
	#if break_active:
	#	$CollisionShape2D.disabled = true
	#	$stained_glass/Outline.visible = false
	#	$Particles.visible = true
	#	$Particles.emitting = true
	#	break_timer = 12
	#	break_active = false
	#if break_timer > -1:
	#	var break_placement : float = scale_internal.x * 64 * (float(break_timer) / 12)
	#	$stained_glass.region_rect.size.x = break_placement
	#	break_timer -= 1
	#	break_placement = scale_internal.x * 64 * (float(break_timer) / 12)
	#	var break_chunk = scale_internal.x * 64 / 12
	#	$Particles.position.x = break_placement * 2 + float(rand.randi_range(0, break_chunk))
	#	$Particles.position.y = float(rand.randi_range(0, scale_internal.y * 128))
