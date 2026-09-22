class_name CounterOverlay
extends Sprite2D

const COUNTER_PARTICLE = preload("res://mods/proverbpalace/source/effects/particle/counter_particle.tscn")
const MAX_PARTICLE_DELAY: float = 3.5

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var particle_delay = MAX_PARTICLE_DELAY-fmod(Time.get_ticks_msec()/1000.,MAX_PARTICLE_DELAY)

func _process(delta: float) -> void:
	particle_delay -= delta
	
	if particle_delay < 0:
		particle_delay = MAX_PARTICLE_DELAY
		
		#add_child(
			#COUNTER_PARTICLE.instantiate()
		#)
