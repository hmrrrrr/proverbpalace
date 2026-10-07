extends "res://source/enemies/brutalist.gd"

func multiattack():
	await sprite.pend_flag("beating", false)

	var num_heartbeats = moves[next_move].count

	for i in range(num_heartbeats):
		if i == 0:
			anim_player.play(next_move + "_start")
		else:
			anim_player.play(next_move + "_loop")

		await sprite.hit
		Game.screenshake(4, 0.5)

		hit_player(moves[next_move].damage, i == num_heartbeats - 1)

		if anim_player.is_playing():
			await anim_player.animation_finished
		if is_defeated:
			break
		if i == num_heartbeats - 1:
			anim_player.play(next_move + "_end")
			await anim_player.animation_finished

	anim_player.play("idle")
