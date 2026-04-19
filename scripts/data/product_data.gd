class_name ProductData
extends Resource

## Representa un producto vendible. Puede ser legítimo (atún, leche)
## o clandestino (catnip). La categoría determina a qué cartera va el ingreso.

enum ProductCategory {
	LEGITIMATE,   ## Ventas normales. Dinero va a cartera LIMPIA.
	SHADOW,       ## Ventas clandestinas. Dinero va a cartera SUCIA.
}

@export_group("Identity")
## Identificador único. Ej: "tuna_premium", "catnip_basic"
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Economy")
## Categoría: determina a qué economía pertenece.
@export var category: ProductCategory = ProductCategory.LEGITIMATE
## Precio unitario al que se vende al cliente.
@export var sale_price: int = 0
## Costo unitario de producir/reponer stock.
@export var production_cost: int = 0

@export_group("Shadow Ops")
## Solo relevante si category == SHADOW.
## Heat generado por cada unidad vendida. Acumula rápido si no hay tapadera.
@export var heat_per_unit: float = 0.0
## Tiempo en segundos que tarda producir una unidad (catnip requiere tiempo).
@export var production_time_seconds: float = 0.0
