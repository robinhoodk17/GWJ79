@tool
extends  EditorScenePostImport

var bar_spot_script : Script = preload("res://scripts/terrain/bar_spot.gd")

func _post_import(scene: Node) -> Object:
	iterate(scene, scene)
	return(scene)


func iterate(node : Node3D, root : Node3D):
	pass
	#if node != null:
		#var node_name : String = node.name.to_lower()
		#if node_name.contains("water"):
			#if node.get_child(0) is StaticBody3D:
				#node.get_child(0).change_t
				#var staticBody : StaticBody3D = node.get_child(0)
				#staticBody.add_to_group("cyllinder",true)
				#staticBody.physics_material_override = physics_Material_floor
				#print_debug(node_name, "  added to group cyllinder")
				#if node.position != Vector3(0,0,0):
					#printerr("WARNING!!! " + node_name + " TRANSFORM IS NOT 0,0,0!!!!!!!!!")
				#if node.transform.basis.get_scale() != Vector3(1,1,1):
					#printerr("WARNING!!! " + node_name + " scale IS NOT 1,1,1!!!!!!!!!")
