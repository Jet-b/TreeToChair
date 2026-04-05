extends Control

const _ICON_WOOD  := preload("res://Art/Wood-Icon.png")
const _ICON_PLANK := preload("res://Art/Plank-Icon.png")
const _ICON_METAL := preload("res://Art/Metal-Icon.png")
const _ICON_NAIL  := preload("res://Art/Nail-Icon.png")
const _ICON_CHAIR := preload("res://Art/Chair/0001.png")

var _music_started := false

func _ready() -> void:
	var tab := $TabContainer
	tab.set_tab_icon(4, _ICON_WOOD)
	tab.set_tab_icon(5, _ICON_PLANK)
	tab.set_tab_icon(6, _ICON_METAL)
	tab.set_tab_icon(7, _ICON_NAIL)
	tab.set_tab_icon(8, _ICON_CHAIR)
	Settings.register_music_player($BackgroundMusic)

func _input(event: InputEvent) -> void:
	if not _music_started and event is InputEventMouseButton and event.pressed:
		_music_started = true
		$BackgroundMusic.play()
