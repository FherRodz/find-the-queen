extends Control

@export var box_texture: Texture2D
@export var initial_text: String = "000"

@onready var background := $TextureRect
@onready var label := $Label

func _ready():
	background.texture = box_texture
	label.text = initial_text

func set_value(value: String):
	label.text = value
