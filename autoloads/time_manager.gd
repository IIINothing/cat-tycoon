extends Node

## Corazón temporal del juego. Emite ticks regulares y gestiona el reloj in-game.
## Todos los sistemas con progreso temporal (ingresos, producción, heat) escuchan sus señales.

# ═══════════════════════════════════════════════════════════
# CONFIGURACIÓN (ajustable para balance)
# ═══════════════════════════════════════════════════════════

## Segundos reales entre ticks. Controla la granularidad de la simulación.
const TICK_INTERVAL_SECONDS: float = 1.0

## Segundos reales por cada hora in-game.
## Ej: 10.0 = un día in-game (24h) dura 4 minutos reales.
const SECONDS_PER_GAME_HOUR: float = 10.0

## Tope máximo de horas offline que se procesan al volver.
## Evita que el jugador gane una semana de plata por dejar la app cerrada.
const MAX_OFFLINE_HOURS: int = 8

# ═══════════════════════════════════════════════════════════
# ESTADO
# ═══════════════════════════════════════════════════════════

## ¿El tiempo está pausado? Cuando true, no se emiten ticks.
var is_paused: bool = false

## Acumulador de tiempo real para el siguiente tick.
var _tick_accumulator: float = 0.0

## Acumulador de tiempo real para la siguiente hora in-game.
var _hour_accumulator: float = 0.0


# ═══════════════════════════════════════════════════════════
# CICLO DE VIDA
# ═══════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	if is_paused:
		return
	
	_tick_accumulator += delta
	_hour_accumulator += delta
	
	# Emitir game_tick cada TICK_INTERVAL_SECONDS reales.
	while _tick_accumulator >= TICK_INTERVAL_SECONDS:
		_tick_accumulator -= TICK_INTERVAL_SECONDS
		SignalBus.game_tick.emit(TICK_INTERVAL_SECONDS)
	
	# Avanzar hora in-game cada SECONDS_PER_GAME_HOUR reales.
	while _hour_accumulator >= SECONDS_PER_GAME_HOUR:
		_hour_accumulator -= SECONDS_PER_GAME_HOUR
		_advance_hour()


# ═══════════════════════════════════════════════════════════
# LÓGICA INTERNA
# ═══════════════════════════════════════════════════════════

## Avanza una hora in-game. Si llegamos a 24, avanza el día.
func _advance_hour() -> void:
	GameState.current_hour += 1
	
	if GameState.current_hour >= 24:
		GameState.current_hour = 0
		GameState.current_day += 1
		SignalBus.day_ended.emit(GameState.current_day - 1)
	
	SignalBus.hour_changed.emit(GameState.current_hour)


# ═══════════════════════════════════════════════════════════
# API PÚBLICA
# ═══════════════════════════════════════════════════════════

## Pausa el tiempo. Útil para menús, diálogos, eventos de redada.
func pause() -> void:
	is_paused = true

## Reanuda el tiempo.
func resume() -> void:
	is_paused = false

## Calcula cuántos ticks deberían procesarse al volver de un cierre offline.
## Se llamará desde SaveSystem al cargar el juego.
## Devuelve la cantidad de ticks (limitada por MAX_OFFLINE_HOURS).
## Calcula cuántos ticks deberían procesarse al volver de un cierre offline.
## Se llamará desde SaveSystem al cargar el juego.
## Devuelve la cantidad de ticks (limitada por MAX_OFFLINE_HOURS).
func calculate_offline_ticks(last_timestamp: int) -> int:
	if last_timestamp <= 0:
		return 0
	
	# Time.get_unix_time_from_system() devuelve float; lo convertimos explícitamente.
	var current_timestamp: int = int(Time.get_unix_time_from_system())
	var elapsed_seconds: int = current_timestamp - last_timestamp
	
	# Tope máximo.
	var max_seconds: int = MAX_OFFLINE_HOURS * int(SECONDS_PER_GAME_HOUR)
	elapsed_seconds = mini(elapsed_seconds, max_seconds)
	
	# Cantidad de ticks equivalente.
	return int(elapsed_seconds / TICK_INTERVAL_SECONDS)
