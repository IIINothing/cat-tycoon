extends Node

## Gestor central de las dos economías del juego: dinero limpio y dinero sucio.
## 
## REGLA DE ORO:
## Las dos carteras NO se conocen entre sí. Ningún método mueve dinero de una
## cartera a la otra. El único sistema autorizado a cruzar ese puente será
## LaunderingService (Fase 5), mediante gasto explícito en una y depósito en la otra.
## 
## Si ves código que mezcla ambas carteras fuera de LaunderingService, es un bug
## arquitectural.

# ═══════════════════════════════════════════════════════════
# CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════

## Tamaño máximo del historial de transacciones en memoria.
## Las más viejas se descartan. Útil para debug sin gastar RAM infinita.
const MAX_TRANSACTION_HISTORY: int = 200

# ═══════════════════════════════════════════════════════════
# REGISTRO DE TRANSACCIONES
# ═══════════════════════════════════════════════════════════

## Tipo de cartera afectada por una transacción.
enum Wallet {
	CLEAN,
	DIRTY,
}

## Dirección de la transacción.
enum TransactionType {
	INCOME,   ## Entrada de dinero.
	EXPENSE,  ## Salida de dinero.
	FAILED,   ## Intento fallido (útil para debug: "el jugador no pudo comprar X").
}

## Registro de una transacción. No es un Resource (no persiste al disco),
## solo vive en memoria para debug y auditoría.
class Transaction:
	var wallet: Wallet
	var type: TransactionType
	var amount: int
	var reason: String
	var timestamp: int
	
	func _init(p_wallet: Wallet, p_type: TransactionType, p_amount: int, p_reason: String) -> void:
		wallet = p_wallet
		type = p_type
		amount = p_amount
		reason = p_reason
		timestamp = int(Time.get_unix_time_from_system())
	
	func _to_string() -> String:
		var wallet_str: String = "CLEAN" if wallet == Wallet.CLEAN else "DIRTY"
		var type_str: String = ["INCOME", "EXPENSE", "FAILED"][type]
		return "[%s][%s] $%d — %s" % [wallet_str, type_str, amount, reason]

## Historial en memoria. Array de Transaction.
var _transaction_log: Array[Transaction] = []


# ═══════════════════════════════════════════════════════════
# API PÚBLICA — CARTERA LIMPIA
# ═══════════════════════════════════════════════════════════

## Añade dinero a la cartera LIMPIA.
## reason: descripción de origen ("shop_sale", "upgrade_refund", etc.) para auditoría.
func add_clean(amount: int, reason: String) -> void:
	if amount <= 0:
		push_warning("EconomyManager.add_clean: monto inválido (%d)" % amount)
		return
	
	GameState.clean_money += amount
	GameState.is_dirty = true
	_log(Wallet.CLEAN, TransactionType.INCOME, amount, reason)
	SignalBus.clean_balance_changed.emit(GameState.clean_money)


## Intenta gastar dinero de la cartera LIMPIA.
## Devuelve true si la transacción fue exitosa, false si no hay fondos.
func spend_clean(amount: int, reason: String) -> bool:
	if amount <= 0:
		push_warning("EconomyManager.spend_clean: monto inválido (%d)" % amount)
		return false
	
	if GameState.clean_money < amount:
		_log(Wallet.CLEAN, TransactionType.FAILED, amount, reason)
		SignalBus.transaction_failed.emit("Fondos limpios insuficientes: %s" % reason)
		return false
	
	GameState.clean_money -= amount
	GameState.is_dirty = true
	_log(Wallet.CLEAN, TransactionType.EXPENSE, amount, reason)
	SignalBus.clean_balance_changed.emit(GameState.clean_money)
	return true


# ═══════════════════════════════════════════════════════════
# API PÚBLICA — CARTERA SUCIA
# ═══════════════════════════════════════════════════════════

## Añade dinero a la cartera SUCIA.
func add_dirty(amount: int, reason: String) -> void:
	if amount <= 0:
		push_warning("EconomyManager.add_dirty: monto inválido (%d)" % amount)
		return
	
	GameState.dirty_money += amount
	GameState.is_dirty = true
	_log(Wallet.DIRTY, TransactionType.INCOME, amount, reason)
	SignalBus.dirty_balance_changed.emit(GameState.dirty_money)


## Intenta gastar dinero de la cartera SUCIA.
## Devuelve true si la transacción fue exitosa, false si no hay fondos.
func spend_dirty(amount: int, reason: String) -> bool:
	if amount <= 0:
		push_warning("EconomyManager.spend_dirty: monto inválido (%d)" % amount)
		return false
	
	if GameState.dirty_money < amount:
		_log(Wallet.DIRTY, TransactionType.FAILED, amount, reason)
		SignalBus.transaction_failed.emit("Fondos sucios insuficientes: %s" % reason)
		return false
	
	GameState.dirty_money -= amount
	GameState.is_dirty = true
	_log(Wallet.DIRTY, TransactionType.EXPENSE, amount, reason)
	SignalBus.dirty_balance_changed.emit(GameState.dirty_money)
	return true


# ═══════════════════════════════════════════════════════════
# API PÚBLICA — CONSULTAS
# ═══════════════════════════════════════════════════════════

## ¿Puede el jugador permitirse un gasto limpio de este monto?
## Útil para UI (deshabilitar botones de compra).
func can_afford_clean(amount: int) -> bool:
	return GameState.clean_money >= amount

## ¿Puede el jugador permitirse un gasto sucio?
func can_afford_dirty(amount: int) -> bool:
	return GameState.dirty_money >= amount

## ¿Puede permitirse un gasto mixto (común en upgrades que cuestan ambos)?
func can_afford_mixed(clean: int, dirty: int) -> bool:
	return can_afford_clean(clean) and can_afford_dirty(dirty)


# ═══════════════════════════════════════════════════════════
# API PÚBLICA — DEBUG
# ═══════════════════════════════════════════════════════════

## Devuelve las últimas N transacciones como strings. Útil para debug overlay.
func get_recent_transactions(count: int = 10) -> Array[String]:
	var result: Array[String] = []
	var start: int = maxi(0, _transaction_log.size() - count)
	for i in range(start, _transaction_log.size()):
		result.append(_transaction_log[i].to_string())
	return result

## Imprime las últimas transacciones a la consola. Solo para desarrollo.
func debug_print_log(count: int = 20) -> void:
	print("=== Últimas %d transacciones ===" % count)
	for tx_str in get_recent_transactions(count):
		print(tx_str)


# ═══════════════════════════════════════════════════════════
# MÉTODOS PRIVADOS
# ═══════════════════════════════════════════════════════════

## Registra una transacción en el log y recorta si excede el tamaño máximo.
func _log(wallet: Wallet, type: TransactionType, amount: int, reason: String) -> void:
	var tx: Transaction = Transaction.new(wallet, type, amount, reason)
	_transaction_log.append(tx)
	
	# Mantener el log dentro del límite.
	if _transaction_log.size() > MAX_TRANSACTION_HISTORY:
		_transaction_log.pop_front()
