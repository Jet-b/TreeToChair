extends Control

@export var chairSprite : AnimatedSprite2D

var currentSide := 0

func resume_chair():
	chairSprite.play()
	
func _process(delta: float) -> void:
	if chairSprite.frame == 0 and currentSide != 1:
		side_1()
		currentSide = 1
		chairSprite.pause()
		$Side1.reset_buttons()
		
	if  chairSprite.frame == 6 and currentSide != 2:
		side_2()
		currentSide = 2
		chairSprite.pause()
		$Side2.reset_buttons()
	
	if  chairSprite.frame == 12 and currentSide != 3:
		side_3()
		currentSide = 3
		chairSprite.pause()
		$Side3.reset_buttons()
		
	if  chairSprite.frame == 19 and currentSide != 4:
		side_4()
		currentSide = 4
		chairSprite.pause()
		$Side4.reset_buttons()
	
func side_1():
	$Side1.modulate.a = 255
	$Side1.reset_buttons()
	
func side_2():
	$Side2.modulate.a = 255
	$Side2.reset_buttons()
	
func side_3():
	$Side3.modulate.a = 255
	$Side3.reset_buttons()
	
func side_4():
	$Side4.modulate.a = 255
	$Side4.reset_buttons()

func resume_animation() -> void:
	chairSprite.frame += 1
	chairSprite.play()


func _on_side_1_buttons_pressed() -> void:
	$Side1.modulate.a = 0
	resume_animation()


func _on_side_2_buttons_pressed() -> void:
	$Side2.modulate.a = 0
	resume_animation()


func _on_side_3_buttons_pressed() -> void:
	$Side3.modulate.a = 0
	resume_animation()


func _on_side_4_buttons_pressed() -> void:
	$Side4.modulate.a = 0
	resume_animation()
