extends CharacterBody2D

@export var speed : int = 100

@onready var state_machine : StateMachine = $StateMachine
@onready var state_label = $StateLabel

func _ready():
	state_machine.player = self
	
