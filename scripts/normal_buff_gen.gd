# Attach this script to your SubViewport node.
extends SubViewport

# --- Assign these in the Inspector ---
@export var main_scene_root : Node3D
@export var main_camera : Camera3D
@export var normal_shader : ShaderMaterial
# ---------------------------------------

# This dictionary links original nodes to their copies
var node_map := {}
@onready var viewport_camera: Camera3D

func _ready():
	if !main_scene_root || !main_camera:
		printerr("Main scene root or Main Camera not set!")
		return

	# 1. Create and add the camera for this viewport
	# We duplicate it to copy properties like FOV, near, far, etc.
	viewport_camera = main_camera.duplicate()
	add_child(viewport_camera)

	# 2. Find and duplicate all meshes
	var original_meshes = _find_meshes_recursively(main_scene_root)
	for original_mesh: MeshInstance3D in original_meshes:
		var mesh_copy = original_mesh.duplicate()
		mesh_copy.mesh.surface_set_material(0, normal_shader)
		add_child(mesh_copy)
		node_map[original_mesh] = mesh_copy

# Sync everything every frame
func _process(_delta):
	if !is_instance_valid(main_camera):
		return

	# 1. Sync the camera transform AND properties
	viewport_camera.global_transform = main_camera.global_transform

	# You must also sync any properties that might change at runtime
	viewport_camera.fov = main_camera.fov
	viewport_camera.size = main_camera.size # For orthographic
	viewport_camera.projection = main_camera.projection

	# 2. Sync all the mesh transforms
	for original_mesh in node_map:
		if is_instance_valid(original_mesh):
			var copy_mesh = node_map[original_mesh]
			copy_mesh.global_transform = original_mesh.global_transform
		else:
			var copy_mesh = node_map.erase(original_mesh)
			if is_instance_valid(copy_mesh):
				copy_mesh.queue_free()

# Helper function to find all meshes
func _find_meshes_recursively(node):
	var meshes = []
	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child)
		meshes.append_array(_find_meshes_recursively(child))
	return meshes
