extends Node2D

var tween: Tween

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const FADE_IN_TIME := 0.15
const FADE_OUT_TIME := 0.35
const START_SCALE := 0.6
const END_SCALE := 1.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	
	sprite.modulate.a = 0.0
	scale = Vector2.ONE * START_SCALE

	sprite.play()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	# Fade + scale in
	tween.tween_property(sprite, "modulate:a", 1.0, FADE_IN_TIME)
	tween.tween_property(self, "scale", Vector2.ONE * END_SCALE, FADE_IN_TIME)

	# Fade out
	tween.tween_property(sprite, "modulate:a", 0.0, FADE_OUT_TIME)

	tween.finished.connect(queue_free)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
