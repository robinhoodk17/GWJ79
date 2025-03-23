extends Node

@warning_ignore("unused_signal")
signal seed_picked(type)
@warning_ignore("unused_signal")
signal seed_dropped()
@warning_ignore("unused_signal")
signal lost_game
@warning_ignore("unused_signal")
signal day_started
@warning_ignore("unused_signal")
signal night_started
@warning_ignore("unused_signal")
signal enemy_died(body : Node3D)
@warning_ignore("unused_signal")
##the area indicates which combat finished
signal combat_finished(body : Area3D)
@warning_ignore("unused_signal")
##the area indicates which combat started
signal combat_started(body : Area3D)
