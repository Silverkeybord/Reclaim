class_name WeaponData
extends Resource

@export var key : String
## bullet shooting type options (hitscan, projectile)
@export var bullet_type : Global.SHOT_TYPE

@export_group("Basic Stats")
## damage delt to enemies
@export var damage : int
## time inbetween each shot with no upgrades
@export var cool_down : float
## the resource for the sound of the weapon
@export var shoot_resource : SoundInfo
## the hit sound whe you hit an enemy
@export var hit_resource : SoundInfo
## probablity of a crit
@export_range(0, 1, 0.01) var cirt_rate : float
## damge multiplier on a successful crit
@export_range(1, 5, 0.1) var critical_multiplier : float = 1.5


func get_critical() -> float:
	if randf() < cirt_rate:
		return true
	else:
		return false
