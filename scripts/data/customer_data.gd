class_name CustomerData
extends Resource

## Arquetipo de cliente felino. Define comportamiento, preferencias
## y posible amenaza encubierta.

enum CustomerArchetype {
	REGULAR,       ## Gato común de barrio. Compra poco pero frecuente.
	WEALTHY,       ## Gato rico. Compra caro, exige calidad.
	ADDICT,        ## Cliente del submundo. Solo busca catnip.
	TOURIST,       ## Visitante ocasional. Impulsivo, impredecible.
	UNDERCOVER_COP,## Policía encubierto. Parece normal pero investiga.
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export var archetype: CustomerArchetype = CustomerArchetype.REGULAR

@export_group("Behavior")
## Presupuesto aproximado por visita. El código final randomizará alrededor de este valor.
@export var avg_budget: int = 0
## Probabilidad (0.0 a 1.0) de comprar algo al entrar al negocio.
@export_range(0.0, 1.0) var purchase_probability: float = 0.5
## Productos que este arquetipo prefiere. Aumenta chance de compra si el negocio los vende.
@export var preferred_products: Array[ProductData]

@export_group("Shadow Interaction")
## ¿Puede este cliente comprar productos SHADOW?
## Los gatos "normales" no saben que existe el catnip clandestino.
@export var can_buy_shadow: bool = false

@export_group("Threat")
## Si es true, cada compra observada genera heat en vez de ingresos.
## Usado para UNDERCOVER_COP y futuros arquetipos hostiles.
@export var is_threat: bool = false
## Heat generado por visita si is_threat es true.
@export var threat_heat_per_visit: float = 0.0
