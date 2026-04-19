class_name UpgradeData
extends Resource

## Representa una mejora que el jugador puede comprar para un negocio.
## Las mejoras modifican atributos del negocio o desbloquean nuevas funcionalidades.

## Tipos de efectos que una mejora puede producir.
## Cada sistema del juego interpreta effect_value según este tipo.
enum UpgradeType {
	INCOME_MULTIPLIER,        ## Multiplica ingresos legítimos. effect_value = multiplicador (1.5 = +50%)
	LAUNDERING_CAPACITY,      ## Aumenta capacidad diaria de lavado. effect_value = cantidad extra
	LAUNDERING_EFFICIENCY,    ## Mejora % de eficiencia de lavado. effect_value = puntos porcentuales (+10 = +10%)
	HEAT_REDUCTION,           ## Reduce heat generado. effect_value = fracción (0.2 = -20%)
	SHADOW_PRODUCTION_RATE,   ## Más catnip por tick. effect_value = multiplicador
	SHADOW_STORAGE,           ## Más almacenamiento de catnip. effect_value = cantidad extra
}

## Identificador único. Ej: "shop_better_shelves", "shop_hidden_room"
@export var id: StringName = &""

## Nombre mostrado al jugador.
@export var display_name: String = ""

## Descripción para tooltip o pantalla de compra.
@export_multiline var description: String = ""

## ¿A qué negocio se aplica esta mejora?
## Si es null, la mejora es genérica (aplica a cualquier negocio).
@export var applies_to: BusinessData

## Tipo de efecto. Determina cómo se interpreta effect_value.
@export var upgrade_type: UpgradeType = UpgradeType.INCOME_MULTIPLIER

## Valor numérico del efecto. Interpretado según upgrade_type.
@export var effect_value: float = 0.0

## Costo en dinero LIMPIO.
@export var cost_clean: int = 0

## Costo en dinero SUCIO. Algunas mejoras del submundo solo se pagan con dinero sucio.
@export var cost_dirty: int = 0

## Mejora previa requerida. Si es null, no tiene prerrequisito.
## Permite construir árboles de mejoras (una desbloquea la siguiente).
@export var requires: UpgradeData
