extends Node

var _tick_count: int = 0

func _ready() -> void:
	print("=== Test TimeManager ===")
	print("Hora inicial: ", GameState.current_hour, ":00")
	print("Día inicial: ", GameState.current_day)
	
	# Me suscribo a las señales para ver el tiempo pasar.
	SignalBus.game_tick.connect(_on_tick)
	SignalBus.hour_changed.connect(_on_hour_changed)
	SignalBus.day_ended.connect(_on_day_ended)
	
	# Prueba de pausa: a los 7 segundos pausa, a los 12 reanuda.
	await get_tree().create_timer(7.0).timeout
	print("⏸ PAUSANDO")
	TimeManager.pause()
	
	await get_tree().create_timer(5.0).timeout
	print("▶ REANUDANDO")
	TimeManager.resume()


func _on_tick(_delta: float) -> void:
	_tick_count += 1
	# Imprime solo cada 5 ticks para no saturar la consola.
	if _tick_count % 5 == 0:
		print("Tick #", _tick_count, " (día ", GameState.current_day, ", hora ", GameState.current_hour, ")")


func _on_hour_changed(new_hour: int) -> void:
	print("⏰ Nueva hora: ", new_hour, ":00")


func _on_day_ended(day_number: int) -> void:
	print("🌙 Terminó el día ", day_number)
