extends Node

## Bus central de señales globales del juego.
## Cualquier sistema puede emitir o escuchar estas señales sin conocer a otros sistemas.
## Registrado como Autoload con el nombre "SignalBus".

# ═══════════════════════════════════════════════════════════
# ECONOMÍA
# ═══════════════════════════════════════════════════════════

## Emitido cuando cambia el balance LIMPIO. new_balance es el valor actualizado.
signal clean_balance_changed(new_balance: int)

## Emitido cuando cambia el balance SUCIO.
signal dirty_balance_changed(new_balance: int)

## Emitido cuando el jugador intenta gastar pero no tiene fondos.
## Útil para que la UI muestre feedback ("No tienes suficiente dinero").
signal transaction_failed(reason: String)

# ═══════════════════════════════════════════════════════════
# TIEMPO
# ═══════════════════════════════════════════════════════════

## Emitido en cada tick del juego. delta es el tiempo real transcurrido.
signal game_tick(delta: float)

## Emitido cuando cambia la hora in-game.
signal hour_changed(new_hour: int)

## Emitido al completar un día in-game.
signal day_ended(day_number: int)

# ═══════════════════════════════════════════════════════════
# NEGOCIOS
# ═══════════════════════════════════════════════════════════

## Emitido cuando el jugador compra un nuevo negocio.
signal business_purchased(business: BusinessData)

## Emitido cuando se compra una mejora.
signal upgrade_purchased(upgrade: UpgradeData)

# ═══════════════════════════════════════════════════════════
# CLIENTES
# ═══════════════════════════════════════════════════════════

## Un cliente entró al negocio activo.
signal customer_entered(customer: CustomerData)

## Un cliente completó una compra.
signal customer_purchased(customer: CustomerData, product: ProductData, amount: int)

## Un cliente se fue sin comprar.
signal customer_left_empty(customer: CustomerData)

# ═══════════════════════════════════════════════════════════
# SUBMUNDO Y RIESGO
# ═══════════════════════════════════════════════════════════

## El nivel de heat cambió.
signal heat_changed(new_heat: float)

## Una redada policial es inminente (cuenta regresiva para esconder evidencia).
signal raid_incoming(seconds_until_raid: float)

## Dinero fue lavado exitosamente.
signal money_laundered(dirty_amount: int, clean_amount_received: int)
