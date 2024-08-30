extends Node2D


export var flip_h : bool = false


func _ready():
	$snoozy.flip_h = flip_h
	$snoozy.rotation = rotation
	rotation = 0
