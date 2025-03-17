extends Node

var in_sun : bool = true
var drinking_water : bool= true
var sleeping : bool = true
var plants : int = 0
var sensitivity : float = 1.0
var seeds_carried : int = 0

@warning_ignore("unused_signal")
signal picked_plant
@warning_ignore("unused_signal")
signal lost_plant
@warning_ignore("unused_signal")
signal lost_game
