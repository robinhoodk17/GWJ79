extends AudioStreamPlayer

func play_varied():
	if not playing:
		pitch_scale=randf_range(0.9,1.1)
		volume_db=randf_range(-5,0)
		play()
