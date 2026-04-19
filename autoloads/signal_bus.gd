extends Node

## Bus central de señales globales del juego.
## ...

# ═══════════════════════════════════════════════════════════
# ECONOMÍA
# ═══════════════════════════════════════════════════════════

## Emitido cuando cambia el balance LIMPIO. new_balance es el valor actualizado.
@warning_ignore("unused_signal")
signal clean_balance_changed(new_balance: int)

## Emitido cuando cambia el balance SUCIO.
@warning_ignore("unused_signal")
signal dirty_balance_changed(new_balance: int)

## Emitido cuando el jugador intenta gastar pero no tiene fondos.
@warning_ignore("unused_signal")
signal transaction_failed(reason: String)

# ═══════════════════════════════════════════════════════════
# TIEMPO
# ═══════════════════════════════════════════════════════════

@warning_ignore("unused_signal")
signal game_tick(delta: float)

@warning_ignore("unused_signal")
signal hour_changed(new_hour: int)

@warning_ignore("unused_signal")
signal day_ended(day_number: int)

# ═══════════════════════════════════════════════════════════
# NEGOCIOS
# ═══════════════════════════════════════════════════════════

@warning_ignore("unused_signal")
signal business_purchased(business: BusinessData)

@warning_ignore("unused_signal")
signal upgrade_purchased(upgrade: UpgradeData)

# ═══════════════════════════════════════════════════════════
# CLIENTES
# ═══════════════════════════════════════════════════════════

@warning_ignore("unused_signal")
signal customer_entered(customer: CustomerData)

@warning_ignore("unused_signal")
signal customer_purchased(customer: CustomerData, product: ProductData, amount: int)

@warning_ignore("unused_signal")
signal customer_left_empty(customer: CustomerData)

# ═══════════════════════════════════════════════════════════
# SUBMUNDO Y RIESGO
# ═══════════════════════════════════════════════════════════

@warning_ignore("unused_signal")
signal heat_changed(new_heat: float)

@warning_ignore("unused_signal")
signal raid_incoming(seconds_until_raid: float)

@warning_ignore("unused_signal")
signal money_laundered(dirty_amount: int, clean_amount_received: int)
