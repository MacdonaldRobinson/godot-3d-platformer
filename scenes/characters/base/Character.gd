extends KinematicBody
class_name Character

onready var animation_tree:AnimationTree = $AnimationTree
onready var mesh:Spatial = $Mesh

var gravity:Vector3 = Vector3.ZERO

enum AnimationTreeState {
	WALK = 0,
	RUN = 1
}

func get_current_state_machine_index():
	var path = "parameters/anim_tree_state/current"		
	return animation_tree[path]
	
func get_current_state_machine_name():
	match get_current_state_machine_index():
		AnimationTreeState.WALK:
			return "walk"
		AnimationTreeState.RUN:
			return "run"

func set_anim_tree_state(new_anim_state):
	var path = "parameters/anim_tree_state/current"
	animation_tree.set(path, new_anim_state)
	

func play_animation(travel_to_animation):
	var path = "parameters/"+get_current_state_machine_name()+"/playback"
	animation_tree[path].travel(travel_to_animation)

func _input(event):
	if Input.is_action_just_pressed("sprint"):
		match get_current_state_machine_index():
			AnimationTreeState.WALK:
				set_anim_tree_state(AnimationTreeState.RUN)
			AnimationTreeState.RUN:
				set_anim_tree_state(AnimationTreeState.WALK)

func _physics_process(delta):			
	var root_motion:Transform = animation_tree.get_root_motion_transform()
	var v = root_motion.origin / delta

	if is_on_floor():
		gravity = Vector3.ZERO
	else:		 
		gravity += Vector3(0.0, -9.8, 0)
		
	v += gravity

	var dir:Vector3 = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		dir.z -= 1
	elif Input.is_action_pressed("backward"):
		dir.z += 1		
	elif Input.is_action_pressed("left"):
		dir.x -= 1		
	elif Input.is_action_pressed("right"):
		dir.x += 1
		
	if dir.length_squared() > 0.01:
		dir = dir.rotated(Vector3.UP, Globals.camera_spring_arm.rotation.y)
		
		var player_heading_2d: Vector2 = Vector2(transform.basis.z.x, transform.basis.z.z)
		var desired_heading_2d: Vector2 = Vector2(dir.x, dir.z)
		
		var phi: float = desired_heading_2d.angle_to(player_heading_2d)
		phi = phi * delta * 3
		rotation.y += phi
		
		v = v.rotated(Vector3.UP, rotation.y)
		
		play_animation("forward")
			
	else:
		play_animation("idle")

	animation_tree["parameters/"+get_current_state_machine_name()+"/conditions/jump"] = Input.is_action_pressed("jump")
	
	move_and_slide(v, Vector3.UP)
