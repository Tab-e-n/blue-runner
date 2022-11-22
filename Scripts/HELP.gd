extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()

var page : int = 0
var page_amount : int = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	$bg.rotation -= 0.001

func menu_update():
	if Input.is_action_pressed("up") and parent.move and page > 0:
		page -= 1
		$anim.play("up")
	if Input.is_action_pressed("down") and parent.move and page < page_amount - 1:
		page += 1
		$anim.play("down")
	
	
	
	$menu_arrow_2.modulate = Color(1, 1, 1, 1)
	$menu_arrow_1.modulate = Color(1, 1, 1, 1)
	if page == 0: $menu_arrow_2.modulate = Color(0.5, 0.5, 0.5, 1)
	if page == page_amount - 1: $menu_arrow_1.modulate = Color(0.5, 0.5, 0.5, 1)
	
	$menu_help_moving.visible = false
	$menu_help_danger.visible = false
	$menu_help_goal.visible = false
	$menu_help_bonus.visible = false
	$menu_help_s1_special.visible = false
	$menu_help_s1_dropslide.visible = false
	match(page):
		0:
			$menu_help_moving.visible = true
			$menu_help_moving/left.text = global.key_names(0)
			$menu_help_moving/right.text = global.key_names(1)
			$menu_help_moving/jump.text = global.key_names(4)
		1:
			$menu_help_goal.visible = true
		2:
			$menu_help_danger.visible = true
		3:
			$menu_help_bonus.visible = true
		4:
			$menu_help_s1_special.visible = true
			$menu_help_s1_special/special.text = global.key_names(5)
		5:
			$menu_help_s1_dropslide.visible = true
