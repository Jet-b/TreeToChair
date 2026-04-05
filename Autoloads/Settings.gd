extends Node

## Creates named audio buses so every AudioStreamPlayer can be routed
## to an individual channel and controlled from the settings tab.

const MUSIC_BUS    := "Music"
const BUS_BUTTON   := "SFX_Button"
const BUS_CHOP     := "SFX_Chop"
const BUS_PLANT    := "SFX_Plant"
const BUS_NAIL     := "SFX_Nail"
const BUS_METAL    := "SFX_Metal"
const BUS_SAW      := "SFX_Saw"
const BUS_MONEY    := "SFX_Money"

const ALL_BUSES := [
	MUSIC_BUS,
	BUS_BUTTON,
	BUS_CHOP,
	BUS_PLANT,
	BUS_NAIL,
	BUS_METAL,
	BUS_SAW,
	BUS_MONEY,
]

func _ready() -> void:
	for bus_name in ALL_BUSES:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")

## Sets Music bus volume from a linear 0–1 value (slider input).
func set_music_volume(linear: float) -> void:
	var idx := AudioServer.get_bus_index(MUSIC_BUS)
	if idx < 0:
		return
	if linear <= 0.001:
		AudioServer.set_bus_volume_db(idx, -80.0)
	else:
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear))

## Mutes or unmutes a named SFX bus.
func set_bus_muted(bus_name: String, muted: bool) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_mute(idx, muted)
