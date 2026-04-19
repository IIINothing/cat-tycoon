class_name BusinessData
extends Resource

## Representa un tipo de negocio que el jugador puede poseer y operar.
## Cada instancia (.tres) define un negocio específico: tienda, hotel, casino, etc.

## Identificador único del negocio. Usado por sistemas para referenciarlo.
## Ejemplo: "shop_basic", "hotel_downtown", "casino_royale"
@export var id: StringName = &""

## Nombre mostrado al jugador en UI.
@export var display_name: String = ""

## Descripción corta para tooltips o pantalla de compra.
@export_multiline var description: String = ""

## Costo en dinero LIMPIO para adquirir este negocio.
@export var purchase_cost: int = 0

## Ingreso base por tick (antes de upgrades y modificadores).
## Un "tick" lo define TimeManager; por ahora piensa en segundos reales.
@export var base_income_per_tick: int = 0

## ¿Este negocio puede usarse como tapadera para operaciones sucias?
## Una tienda pequeña probablemente sí, un kiosko callejero quizá no.
@export var can_host_shadow_ops: bool = false

## Capacidad máxima de lavado por día in-game.
## 0 significa que no sirve como tapadera (ignorado si can_host_shadow_ops es false).
@export var laundering_capacity_per_day: int = 0

## Eficiencia de lavado: cuánto dinero limpio sale por cada 100 sucios lavados.
## Ej: 70 = 70% eficiencia, se "pierde" 30% en el proceso.
@export_range(0, 100) var laundering_efficiency: int = 70

## Escena que se instancia cuando el jugador entra a este negocio.
## Se asigna desde el Inspector arrastrando el .tscn correspondiente.
@export var location_scene: PackedScene
