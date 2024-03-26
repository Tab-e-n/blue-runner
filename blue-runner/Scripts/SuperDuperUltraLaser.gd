extends Node2D


export var chargeup_time : float = 15
export var blast_lenght : float = 4096

onready var level = get_tree().current_scene

onready var chargeup_time_inv : float = 1 / chargeup_time

var time : float = 0

var blasting : bool = false
var blast : float = 0

var last_speed_circle : int = 1


func _ready():
	$light.scale = Vector2(0, 0)
	$particles.emitting = false
	$menu_circle.visible = false


func _physics_process(delta):
	$particles.emitting = level.timers_active and not blasting
	$light.scale = Vector2(1, 1) * time * chargeup_time_inv
	
	if not $menu_circle/anim.is_playing() and not blasting:
		if time >= chargeup_time * 0.75 and chargeup_time > 6:
			$menu_circle/anim.play("explode")
	
	if time >= chargeup_time:
		$anim.play("blast")
		$hitbox.set_deferred("monitoring", true)
		blasting = true
		blast = 0
		time = chargeup_time
		last_speed_circle = 1
	
	$BigLaser.scale.x = blast * 0.25
	$hitbox.scale.x = blast * 0.25
	$BigLaserCapEnd.position.x = blast
	
	if blasting:
		if blast >= blast_lenght:
			$anim.play("calm")
			$hitbox.set_deferred("monitoring", false)
			blasting = false
			time = 0
		
		if last_speed_circle * 256 < blast:
			var ring : Node2D = preload("res://Objects/Decor/SpeedRing.tscn").instance()
			var trans : Transform2D = Transform2D()
			ring.position = position + trans.rotated(rotation).x * scale * blast
			ring.scale = scale * 3
			ring.rotation = rotation
			get_tree().current_scene.add_child(ring)
			last_speed_circle += 1
	
	if level.timers_active:
		if blasting:
			blast += 64
			if time > 0:
				time -= delta
		else:
			time += delta


func _on_hitbox_body_entered(body):
	if body is Player:
		body.die()
