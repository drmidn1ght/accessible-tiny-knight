class_name Enemy
extends Node2D

@export_category("Life")
@export var health: int = 10
@export var death_prefab: PackedScene
var damage_digit_prefab: PackedScene

@onready var damage_digit_marker = $DamageDigitMarker

@export_category("Drops")
@export var drop_chance: float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float]

# Dicionários para armazenar os sons dos inimigos
var detect_sounds = {
    "sheep": preload("res://audio/sheep-1-89229.mp3"),
    "goblin": preload("res://audio/goblin-scream-87564.mp3"),
    "pawn": preload("res://audio/male-attack-grunt-45747.mp3")
}

var hit_sounds = {
    "sheep": preload("res://audio/Sheep Bleating-SoundBible.com-1373580685.wav"),
    "goblin": preload("res://audio/Starter Pack-Realist Sound Bank.23/Monster/Monster9.wav"),
    "pawn": preload("res://audio/ouch-sound-effect-30-11844.mp3")
}

# Função para tocar som quando o inimigo detecta o player
func play_detect_sound(enemy_type):
    if enemy_type in detect_sounds:
        var audio_player = AudioStreamPlayer.new()
        audio_player.stream = detect_sounds[enemy_type]
        add_child(audio_player)
        audio_player.play()

# Função para tocar som ao atingir o inimigo 
func play_hit_sound(enemy_type):
    if enemy_type in hit_sounds:
        var audio_player = AudioStreamPlayer.new()
        audio_player.stream = hit_sounds[enemy_type]
        add_child(audio_player)
        audio_player.play()

# Função chamada quando um inimigo detecta o player
func on_enemy_detected(enemy_type):
    play_detect_sound(enemy_type)

# Função chamada quando um inimigo é atingido pelo player
func on_enemy_hit(enemy_type):
    play_hit_sound(enemy_type)

func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")
		play_detect_sound(enemy_type)


func damage(amount: int) -> void:
	health -= amount
	print("Inimigo recebeu dano de ", amount, ". A vida total é de ", health)
		play_hit_sound(enemy_type)
	
	# Piscar node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Criar DamageDigit
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
	# Processar morte
	if health <= 0:
		die()


func die() -> void:
	# Caveira
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	# Drop
	if randf() <= drop_chance:
		drop_item()

	# Incrementar contador
	GameManager.monsters_defeated_counter += 1
	
	# Deletar node
	queue_free()


func drop_item() -> void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)


func get_random_drop_item() -> PackedScene:
	# Listas com 1 item
	if drop_items.size() == 1:
		return drop_items[0]

	# Calcular chance máxima
	var max_chance: float = 0.0
	for drop_chance in drop_chances:
		max_chance += drop_chance
	
	# Jogar dado
	var random_value = randf() * max_chance
	
	# Girar a roleta
	var needle: float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
	
	return drop_items[0]
	
	
	
	
	
	
	
