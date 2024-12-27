extends Node
class_name StateMachine

var player : CharacterBody2D # NOTE(Arokh Slade, 2024 12 25): must be set by user (player controller) upon instantiation
@onready var state : State = IdleState.new(self)

enum StateName {
	NONE = 0,
	IDLE = 10,
	RUNNING = 20,
	AIRBORNE,
	SLIDING
}

enum Direction {
	NONE, LEFT, RIGHT
}

# TODO(ArokhSlade, 2024 12 25): 
# have a singleton dictionary of StateName : State 

class State:
	var state_machine : StateMachine
	var name : StateName
	
	func transition() -> State:
		return self
		
	func physics_process(_delta) -> void:
		return
		
	func _init(p_state_machine : StateMachine):
		state_machine = p_state_machine
	
	func update_label():
		state_machine.player.state_label.text = str(StateName.find_key(name))
		
	func exit_state() -> void:
		return

class IdleState extends State:	
	
	func _init(p_state_machine : StateMachine):
		super(p_state_machine)
		name = StateName.IDLE
		
	func transition() -> State:		
		if state_machine.player.is_on_floor():
			if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
				var new_state = RunState.new(state_machine)
				return new_state
		#if up (and left/right) : jump, pass direction
		
		return self
	
	func physics_process(delta) -> void :
		var player = state_machine.player
		player.velocity += player.get_gravity() * delta		
		player.move_and_slide()


class RunState extends State:
	
	func _init(p_state_machine : StateMachine):
		super(p_state_machine)
		name = StateName.RUNNING
		
	func transition() -> State :
		if state_machine.player.is_on_floor():
			if Input.is_action_pressed("right") or Input.is_action_pressed("left"):				
				return self
		
		exit_state()
		return IdleState.new(state_machine)
	
	func exit_state():
		state_machine.player.velocity.x = 0.0
		
	func physics_process(delta) -> void:
		var player = state_machine.player
		player.velocity += player.get_gravity() * delta
		player.velocity.x = player.speed * Input.get_axis("left", "right")
		player.move_and_slide()
		

# NOTE(ArokhSlade, 2024 12 25):
# get input
# change state
# execute state logic
# example: idle -> input:right, on_floor:true -> new state: running(right) -> process: position changed, animation:run, sound:steps
func _physics_process(delta):
	state = state.transition()
	state.update_label()
	state.physics_process(delta)
