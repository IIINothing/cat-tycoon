extends Node

func _ready() -> void:
	print("=== Test SaveSystem ===")
	
	# Paso 1: Modificar GameState con valores reconocibles.
	print("\n--- Paso 1: modifico GameState ---")
	GameState.clean_money = 1234
	GameState.dirty_money = 567
	GameState.current_day = 5
	GameState.current_hour = 14
	GameState.heat_level = 42.5
	
	# Añado el negocio "shop_basic" como poseído (si existe).
	var shop: BusinessData = load("res://resources/businesses/shop_basic.tres")
	if shop:
		GameState.owned_businesses.append(shop)
		GameState.active_business = shop
		print("Negocio agregado: ", shop.display_name)
	
	GameState.is_dirty = true
	print("Estado actual — limpio: $%d, sucio: $%d, día: %d, hora: %d, heat: %.1f" % [
		GameState.clean_money, GameState.dirty_money,
		GameState.current_day, GameState.current_hour, GameState.heat_level])
	
	# Paso 2: Guardar.
	print("\n--- Paso 2: guardo ---")
	var saved: bool = SaveSystem.save()
	print("¿Guardado exitoso?: ", saved)
	print("¿Existe save?: ", SaveSystem.has_save())
	
	# Paso 3: Resetear GameState a defaults (simula "nueva sesión").
	print("\n--- Paso 3: reseteo GameState (simulo nueva sesión) ---")
	GameState.reset_to_defaults()
	print("Tras reset — limpio: $%d, día: %d, heat: %.1f" % [
		GameState.clean_money, GameState.current_day, GameState.heat_level])
	
	# Paso 4: Cargar.
	print("\n--- Paso 4: cargo desde disco ---")
	var loaded: bool = SaveSystem.load_game()
	print("¿Cargado exitoso?: ", loaded)
	print("Estado cargado — limpio: $%d, sucio: $%d, día: %d, hora: %d, heat: %.1f" % [
		GameState.clean_money, GameState.dirty_money,
		GameState.current_day, GameState.current_hour, GameState.heat_level])
	print("Negocios poseídos: ", GameState.owned_businesses.size())
	if GameState.active_business:
		print("Negocio activo: ", GameState.active_business.display_name)
