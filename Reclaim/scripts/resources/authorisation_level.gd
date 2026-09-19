extends Resource
class_name AuthorisationLevel

## level of the upgrade
@export var level : int

## number of cubits to get this upgrade wont be used for a while
@export var cubits : int

## The required resources for this access
@export var requirments : Array[RequirementsTemplate]

## The unlocks that getting this level will grant/upgrades
@export var unlocks : Array[UnlockTemplate]
