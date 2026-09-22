extends "res://source/ui/intents/intent.gd"
class_name ProverbPalaceCustomIntent

const COUNTER_INTENT = 9054823042389
const COUNTER_INTENT_TEXTURE = preload("res://mods/proverbpalace/arte/intents/counter_intent.png")
const INTENTS = preload("res://arte/ui/intents.png")

func update_sprite():
	if intent == COUNTER_INTENT:
		sprite.texture = COUNTER_INTENT_TEXTURE
		(sprite).hframes = 1
		(sprite).vframes = 1
	else:
		(sprite).hframes = 8
		(sprite).vframes = 9
		sprite.texture = INTENTS
		super()

func get_key() -> String:
	if intent == COUNTER_INTENT:
		return "counter"
	return super()
