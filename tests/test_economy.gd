extends Node

func _ready() -> void:
	print("=== Test EconomyManager ===")
	
	# Me suscribo a las señales para ver los cambios.
	SignalBus.clean_balance_changed.connect(_on_clean_changed)
	SignalBus.dirty_balance_changed.connect(_on_dirty_changed)
	SignalBus.transaction_failed.connect(_on_transaction_failed)
	
	print("\n--- Caso 1: ingresos legítimos ---")
	EconomyManager.add_clean(100, "venta_atun_inicial")
	EconomyManager.add_clean(50, "venta_leche")
	
	print("\n--- Caso 2: gasto válido ---")
	var ok: bool = EconomyManager.spend_clean(80, "compra_estanterias")
	print("¿Gasto exitoso?: ", ok)
	
	print("\n--- Caso 3: gasto que falla ---")
	var fail: bool = EconomyManager.spend_clean(9999, "intento_compra_imposible")
	print("¿Gasto exitoso?: ", fail)
	
	print("\n--- Caso 4: cartera sucia ---")
	EconomyManager.add_dirty(200, "venta_catnip_basic")
	var spent_dirty: bool = EconomyManager.spend_dirty(150, "soborno_oficial")
	print("¿Soborno exitoso?: ", spent_dirty)
	
	print("\n--- Caso 5: helper can_afford ---")
	print("¿Puedo permitirme $50 limpios?: ", EconomyManager.can_afford_clean(50))
	print("¿Puedo permitirme $500 limpios?: ", EconomyManager.can_afford_clean(500))
	print("¿Puedo pagar mixto ($20 limpio + $30 sucio)?: ", EconomyManager.can_afford_mixed(20, 30))
	
	print("\n--- Caso 6: log de transacciones ---")
	EconomyManager.debug_print_log()
	
	print("\n--- Balance final ---")
	print("Limpio: $", GameState.clean_money)
	print("Sucio:  $", GameState.dirty_money)


func _on_clean_changed(new_balance: int) -> void:
	print("💵 [LIMPIO] balance actualizado: $", new_balance)

func _on_dirty_changed(new_balance: int) -> void:
	print("💸 [SUCIO] balance actualizado: $", new_balance)

func _on_transaction_failed(reason: String) -> void:
	print("❌ Transacción fallida: ", reason)
