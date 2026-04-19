extends Node

## Contenedor global del estado del jugador. Solo DATOS, sin lógica.
## Otros sistemas (EconomyManager, TimeManager, etc.) leen y modifican este estado
## siguiendo las reglas del juego.
## 
## Reglas de diseño:
## - NO poner métodos con reglas de negocio aquí (validaciones, cálculos complejos).
## - SÍ poner getters/setters simples si ayudan a la legibilidad.
## - Todo lo persistente del jugador vive aquí y en ningún otro lugar.

# ═══════════════════════════════════════════════════════════
# ECONOMÍA
# ═══════════════════════════════════════════════════════════

## Dinero obtenido por medios legítimos. Solo EconomyManager debería modificarlo.
var clean_money: int = 0

## Dinero obtenido por operaciones del submundo.
var dirty_money: int = 0

# ═══════════════════════════════════════════════════════════
# TIEMPO
# ═══════════════════════════════════════════════════════════

## Día in-game actual. Empieza en 1.
var current_day: int = 1

## Hora in-game actual (0-23).
var current_hour: int = 8

## Timestamp Unix de la última vez que el juego se guardó.
## Usado por TimeManager para calcular progreso offline.
var last_save_timestamp: int = 0

# ═══════════════════════════════════════════════════════════
# POSESIONES
# ═══════════════════════════════════════════════════════════

## Negocios que el jugador posee actualmente.
var owned_businesses: Array[BusinessData] = []

## Mejoras que el jugador ha comprado (en cualquier negocio).
var purchased_upgrades: Array[UpgradeData] = []

## Referencia al negocio en el que el jugador está "ubicado" ahora mismo.
## null si está en un menú global o entre ubicaciones.
var active_business: BusinessData = null

# ═══════════════════════════════════════════════════════════
# RIESGO
# ═══════════════════════════════════════════════════════════

## Nivel actual de sospecha policial. Rango lógico: 0.0 a 100.0
var heat_level: float = 0.0

## ¿Hay una redada en curso o inminente?
var raid_active: bool = false

# ═══════════════════════════════════════════════════════════
# META
# ═══════════════════════════════════════════════════════════

## ¿El estado ha sido modificado desde la última vez que se guardó?
## Útil para auto-save inteligente (solo guarda si hay cambios).
var is_dirty: bool = false


# ═══════════════════════════════════════════════════════════
# HELPERS DE CONSULTA (lectura, sin lógica de negocio)
# ═══════════════════════════════════════════════════════════

## ¿El jugador posee este negocio específico?
func owns_business(business: BusinessData) -> bool:
	return business in owned_businesses

## ¿El jugador ya compró este upgrade?
func has_upgrade(upgrade: UpgradeData) -> bool:
	return upgrade in purchased_upgrades

## Reinicia el estado a valores iniciales. Usado para "New Game".
func reset_to_defaults() -> void:
	clean_money = 0
	dirty_money = 0
	current_day = 1
	current_hour = 8
	last_save_timestamp = 0
	owned_businesses.clear()
	purchased_upgrades.clear()
	active_business = null
	heat_level = 0.0
	raid_active = false
	is_dirty = false
