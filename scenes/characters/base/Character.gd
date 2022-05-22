extends KinematicBody
class_name Character

onready var animation_tree:AnimationTree = $AnimationTree
onready var tween:Tween = $Tween

var gravity:float = 9.8
onready var mesh:Spatial = $Mesh

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
	animation_tree["parameters/"+get_current_state_machine_name()+"/conditions/jump"] = Input.is_action_pressed("jump")
		
	var xAxis = Input.get_action_strength("left") - Input.get_action_strength("right")
	var zAxis = Input.get_action_strength("forward") - Input.get_action_strength("backward")
	var yAxis = 0

	var direction = Vector3(xAxis, yAxis, zAxis).normalized()
	
	if Input.is_action_pressed("forward"):
		play_animation("forward")
	elif Input.is_action_pressed("backward"):
		play_animation("backward")		
	elif Input.is_action_pressed("left"):	
		play_animation("left")
	elif Input.is_action_pressed("right"):	
		play_animation("right")
	else:
		play_animation("idle")	
	
	
		
	var root_motion:Transform = animation_tree.get_root_motion_transform()
	var velocity = root_motion.origin / delta
			
	if direction != Vector3.ZERO:
		rotation_degrees.y = Globals.camera_spring_arm.rotation_degrees.y - 180
#		tween.interpolate_property(self,"rotation_degrees",
#				rotation_degrees,
#				Vector3(rad2deg(0),
#					Globals.camera_spring_arm.rotation_degrees.y - 180,
#					rad2deg(0)),
#				0.25)
#		tween.start()
	
			
	velocity = transform.basis.xform(velocity)
	
	move_and_slide(velocity, Vector3.UP)
