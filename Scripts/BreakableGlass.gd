extends StaticBody2D

var scale_internal : Vector2

var break_active : bool = false

var line_offset : float = 2

func _ready():
	scale_internal = scale
	scale = Vector2(1, 1)
	$stained_glass.region_rect.size = scale_internal * 64
	$CollisionShape2D.scale = scale_internal
	$CollisionShape2D.position = scale_internal * 64
	$stained_glass/Outline.points[0].x = line_offset
	$stained_glass/Outline.points[0].y = line_offset
	$stained_glass/Outline.points[1].x = scale_internal.x * 128 - line_offset
	$stained_glass/Outline.points[1].y = line_offset
	$stained_glass/Outline.points[2].x = scale_internal.x * 128 - line_offset
	$stained_glass/Outline.points[2].y = scale_internal.y * 128 - line_offset
	$stained_glass/Outline.points[3].x = line_offset
	$stained_glass/Outline.points[3].y = scale_internal.y * 128 - line_offset
	$stained_glass/Outline.points[4].x = line_offset
	$stained_glass/Outline.points[4].y = line_offset

func _physics_process(_delta):
	if break_active:
		$CollisionShape2D.disabled = true
		$stained_glass.visible = false
		break_active = false
