extends Node

## Gestor de persistencia del estado del juego.
## Solo conoce GameState: serializa sus datos a JSON y los restaura al cargar.
## 
## NO guarda contenido del juego (BusinessData, UpgradeData, etc.) — esos viven
## en el proyecto como archivos .tres. Solo guarda IDs y los resuelve al cargar.

# ═══════════════════════════════════════════════════════════
# CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════

## Ruta del archivo de guardado. "user://" resuelve a carpeta segura en cada plataforma.
const SAVE_PATH: String = "user://savegame.json"

## Versión del formato. Incrementar cuando cambie la estructura del save.
const SAVE_VERSION: int = 1

## Intervalo de auto-save en segundos. Solo guarda si GameState.is_dirty.
const AUTO_SAVE_INTERVAL: float = 30.0

## Rutas donde buscar resources para resolver IDs al cargar.
## Si agregas nuevos tipos de resources, agrega su carpeta aquí.
const BUSINESS_RESOURCE_DIR: String = "res://resources/businesses/"
const UPGRADE_RESOURCE_DIR: String = "res://resources/upgrades/"

# ═══════════════════════════════════════════════════════════
# ESTADO INTERNO
# ═══════════════════════════════════════════════════════════

## Timer interno para auto-save.
var _autosave_accumulator: float = 0.0

## Caches de lookup por ID. Se llenan en _ready() para resolver IDs rápido.
var _businesses_by_id: Dictionary = {}
var _upgrades_by_id: Dictionary = {}


# ═══════════════════════════════════════════════════════════
# CICLO DE VIDA
# ═══════════════════════════════════════════════════════════

func _ready() -> void:
	# Construye los caches de ID→Resource para lookups rápidos al cargar.
	_build_resource_caches()
	
	# Suscribirse a eventos del sistema operativo (móvil: app pausada/cerrada).
	get_tree().root.connect("close_requested", _on_close_requested)


func _process(delta: float) -> void:
	# Auto-save: si hay cambios pendientes y pasó el intervalo.
	_autosave_accumulator += delta
	if _autosave_accumulator >= AUTO_SAVE_INTERVAL:
		_autosave_accumulator = 0.0
		if GameState.is_dirty:
			save()


## Notificaciones del sistema: pausa de aplicación en móvil (WM_GO_BACKGROUND_REQUEST).
## CRÍTICO: Android puede matar la app en cualquier momento; guardar aquí es seguro.
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if GameState.is_dirty:
			save()


# ═══════════════════════════════════════════════════════════
# API PÚBLICA
# ═══════════════════════════════════════════════════════════

## Guarda el GameState actual al disco.
## Devuelve true si tuvo éxito.
func save() -> bool:
	var data: Dictionary = _serialize_game_state()
	
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: no se pudo abrir %s para escritura" % SAVE_PATH)
		return false
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	
	# Actualizar timestamp y marcar como limpio.
	GameState.last_save_timestamp = int(Time.get_unix_time_from_system())
	GameState.is_dirty = false
	
	print("[SaveSystem] Guardado exitoso → ", SAVE_PATH)
	return true


## Carga el GameState desde disco. Si no hay archivo, deja GameState en defaults.
## Devuelve true si se cargó un archivo, false si no existía o hubo error.
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveSystem] No hay save previo, usando defaults.")
		return false
	
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveSystem: no se pudo abrir %s para lectura" % SAVE_PATH)
		return false
	
	var raw: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(raw)
	if parse_result != OK:
		push_error("SaveSystem: save corrupto — %s" % json.get_error_message())
		return false
	
	var data: Dictionary = json.data
	
	# Verificar versión. En el futuro podríamos migrar formatos viejos aquí.
	var version: int = data.get("version", 0)
	if version != SAVE_VERSION:
		push_warning("SaveSystem: save de versión %d, se esperaba %d" % [version, SAVE_VERSION])
	
	_deserialize_game_state(data)
	print("[SaveSystem] Cargado exitoso desde ", SAVE_PATH)
	return true


## Elimina el save actual. Útil para "New Game" o testing.
func delete_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	GameState.reset_to_defaults()
	print("[SaveSystem] Save eliminado.")
	return true


## ¿Existe un save previo?
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


# ═══════════════════════════════════════════════════════════
# SERIALIZACIÓN
# ═══════════════════════════════════════════════════════════

## Convierte GameState a un Dictionary serializable a JSON.
func _serialize_game_state() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"timestamp": int(Time.get_unix_time_from_system()),
		"economy": {
			"clean_money": GameState.clean_money,
			"dirty_money": GameState.dirty_money,
		},
		"time": {
			"current_day": GameState.current_day,
			"current_hour": GameState.current_hour,
			"last_save_timestamp": GameState.last_save_timestamp,
		},
		"possessions": {
			"owned_business_ids": _resources_to_ids(GameState.owned_businesses),
			"purchased_upgrade_ids": _resources_to_ids(GameState.purchased_upgrades),
			"active_business_id": String(GameState.active_business.id) if GameState.active_business else "",
		},
		"risk": {
			"heat_level": GameState.heat_level,
			"raid_active": GameState.raid_active,
		},
	}


## Restaura GameState desde un Dictionary cargado del JSON.
func _deserialize_game_state(data: Dictionary) -> void:
	var economy: Dictionary = data.get("economy", {})
	GameState.clean_money = economy.get("clean_money", 0)
	GameState.dirty_money = economy.get("dirty_money", 0)
	
	var time: Dictionary = data.get("time", {})
	GameState.current_day = time.get("current_day", 1)
	GameState.current_hour = time.get("current_hour", 8)
	GameState.last_save_timestamp = time.get("last_save_timestamp", 0)
	
	var possessions: Dictionary = data.get("possessions", {})
	GameState.owned_businesses = _ids_to_businesses(possessions.get("owned_business_ids", []))
	GameState.purchased_upgrades = _ids_to_upgrades(possessions.get("purchased_upgrade_ids", []))
	
	var active_id: String = possessions.get("active_business_id", "")
	GameState.active_business = _businesses_by_id.get(active_id) if active_id != "" else null
	
	var risk: Dictionary = data.get("risk", {})
	GameState.heat_level = risk.get("heat_level", 0.0)
	GameState.raid_active = risk.get("raid_active", false)
	
	GameState.is_dirty = false


# ═══════════════════════════════════════════════════════════
# RESOLUCIÓN DE IDs ↔ RESOURCES
# ═══════════════════════════════════════════════════════════

## Escanea las carpetas de resources y llena los caches de ID→Resource.
func _build_resource_caches() -> void:
	_businesses_by_id = _scan_resources(BUSINESS_RESOURCE_DIR)
	_upgrades_by_id = _scan_resources(UPGRADE_RESOURCE_DIR)
	print("[SaveSystem] Caches listos: %d negocios, %d upgrades" % [
		_businesses_by_id.size(),
		_upgrades_by_id.size(),
	])


## Escanea un directorio y devuelve un Dictionary {id: Resource}.
func _scan_resources(dir_path: String) -> Dictionary:
	var result: Dictionary = {}
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		push_warning("SaveSystem: no pude abrir %s" % dir_path)
		return result
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var res: Resource = load(dir_path + file_name)
			if res != null and res.get("id") != null:
				result[String(res.id)] = res
		file_name = dir.get_next()
	
	return result


## Convierte un Array de resources a un Array de strings (sus IDs).
func _resources_to_ids(resources: Array) -> Array[String]:
	var ids: Array[String] = []
	for res in resources:
		if res != null and res.get("id") != null:
			ids.append(String(res.id))
	return ids


func _ids_to_businesses(ids: Array) -> Array[BusinessData]:
	var result: Array[BusinessData] = []
	for id in ids:
		if _businesses_by_id.has(id):
			result.append(_businesses_by_id[id])
	return result


func _ids_to_upgrades(ids: Array) -> Array[UpgradeData]:
	var result: Array[UpgradeData] = []
	for id in ids:
		if _upgrades_by_id.has(id):
			result.append(_upgrades_by_id[id])
	return result


# ═══════════════════════════════════════════════════════════
# EVENTOS
# ═══════════════════════════════════════════════════════════

## Se llama cuando el usuario cierra la ventana (desktop) o similar.
func _on_close_requested() -> void:
	if GameState.is_dirty:
		save()
