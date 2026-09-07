extends Node2D
class_name SDCardEffect

signal apply

		
func kill():
	queue_free()
	hide()
