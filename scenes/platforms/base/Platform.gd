extends Spatial
class_name Platform

onready var mesh = $MeshInstance

func _ready():
	randomize()
	
	var newMaterial:SpatialMaterial = SpatialMaterial.new()
	newMaterial.albedo_color = Color(randf(), randf(), randf())
	mesh.material_override = newMaterial

func _process(delta):
	pass
