extends Node

# script that deals with tutorials for what the player can do

var with_controller = false

var expected := 0b00000000
var learned  := 0b00000000

var attack
var grab
var roll
var defend
var move_aim

var timer = Timer.new()
signal timeout

func _ready() -> void:
	get_nodes()
	add_child(timer)
	timer.timeout.connect(func():timeout.emit())

func get_nodes():
	var scheme = "keyboard"
	if with_controller or Input.get_connected_joypads().size() > 0:
		scheme = "controller"
	
	attack =   get_node(scheme + "/Attack")
	grab =     get_node(scheme + "/Grab")
	roll =     get_node(scheme + "/Roll")
	defend =   get_node(scheme + "/Defend")
	move_aim = get_node(scheme + "/MoveAim")

func player_acted(what):
	if is_bit_set(learned, what):
		return
	
	learned += int(pow(2, what))
	
	t(1.5)
	await timeout
	match what:
		PlayerControls.Actions.GRAB:
			grab.hide()
		PlayerControls.Actions.ROLL:
			roll.hide()
		PlayerControls.Actions.DEFEND:
			defend.hide()
		PlayerControls.Actions.MOVEAIM:
			move_aim.hide()
		PlayerControls.Actions.ATTACK:
			attack.hide()

func expect_player(what):
	
	if not is_bit_set(learned, what):
		var act = int(pow(2, what))
		expected += act
	else:
		return
	
	match what:
		PlayerControls.Actions.GRAB:
			grab.show()
		PlayerControls.Actions.ROLL:
			roll.show()
		PlayerControls.Actions.DEFEND:
			defend.show()
		PlayerControls.Actions.MOVEAIM:
			move_aim.show()

func is_bit_set(x, pos):
	var m = 1 << pos
	return (x & m) != 0

func _on_player_act(what: Variant) -> void:
	player_acted(what)

func _on_player_expect(what: Variant) -> void:
	expect_player(what)

func t(wait_time):
	timer.wait_time = wait_time
	timer.start()
