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
