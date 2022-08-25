extends Control

signal exit
signal start_game
signal value_changed
signal keybinds_change

var active_menu_tree = []
var active_menu = null;
enum ButtonType {JOY, KEYBOARD}
var waiting_button_press = false
var waiting_button_type
var ignore_next_accept_action = false

var keyboard_buttons_icons = {
	keyboard_alt 		= preload("res://assets/inputs/keyboard-alt.png"),
	keyboard_ctrl 		= preload("res://assets/inputs/keyboard-ctrl.png"),
	keyboard_esc 		= preload("res://assets/inputs/keyboard-esc.png"),
	keyboard_shift 		= preload("res://assets/inputs/keyboard-shift.png"),
	keyboard_tab 		= preload("res://assets/inputs/keyboard-tab.png"),
	keyboard_space 		= preload("res://assets/inputs/keyboard-space.png"),
	keyboard_default 	= preload("res://assets/inputs/keyboard-button.png")
}

var controller_buttons_icons = {
	joy_btn_0 = preload("res://assets/inputs/joy-button-a.png"),
	joy_btn_1 = preload("res://assets/inputs/joy-button-b.png"),
	joy_btn_2 = preload("res://assets/inputs/joy-button-x.png"),
	joy_btn_3 = preload("res://assets/inputs/joy-button-y.png"),
	joy_btn_4 = preload("res://assets/inputs/joy-button-lb.png"),
	joy_btn_5 = preload("res://assets/inputs/joy-button-rb.png"),
	joy_btn_6 = preload("res://assets/inputs/joy-button-lt.png"),
	joy_btn_7 = preload("res://assets/inputs/joy-button-rt.png"),
	joy_btn_8 = preload("res://assets/inputs/joy-button-l.png"),
	joy_btn_9 = preload("res://assets/inputs/joy-button-r.png"),
	joy_btn_12 = preload("res://assets/inputs/joy-button-dpad-up.png"),
	joy_btn_13 = preload("res://assets/inputs/joy-button-dpad-down.png"),
	joy_btn_14 = preload("res://assets/inputs/joy-button-dpad-left.png"),
	joy_btn_15 = preload("res://assets/inputs/joy-button-dpad-right.png")
}




func _ready():
	$MainMenu.show()
	active_menu = $MainMenu
	activate_first()

	# Make buttons take focus on hover
	var buttons = []
	find_by_class(self, "Button", buttons)

	for button in buttons:
		button.connect("mouse_entered", self, "_on_menu_option_mouse_entered", [button])

func update_key_binds_ui(keybinds):
	for action in keybinds.keys():
		var action_node = $ControlsMenu/Inputs.get_node(action)

		# Keyboard button
		if keybinds[action]['key_codes'].size():
			var key_name = OS.get_scancode_string(int(keybinds[action]['key_codes'][0]))
			action_node.get_node("keyboard").text = key_name

			if key_name == "Alt":
				action_node.get_node("keyboard").icon = keyboard_buttons_icons["keyboard_alt"]
				action_node.get_node("keyboard").text = ""
			elif key_name == "Control":
				action_node.get_node("keyboard").icon = keyboard_buttons_icons["keyboard_ctrl"]
				action_node.get_node("keyboard").text = ""
			elif key_name == "Escape":
				action_node.get_node("keyboard").icon = keyboard_buttons_icons["keyboard_esc"]
				action_node.get_node("keyboard").text = ""
			elif key_name == "Shift":
				action_node.get_node("keyboard").icon = keyboard_buttons_icons["keyboard_shift"]
				action_node.get_node("keyboard").text = ""
			elif key_name == "Tab":
				action_node.get_node("keyboard").icon = keyboard_buttons_icons["keyboard_tab"]
				action_node.get_node("keyboard").text = ""
			elif key_name == "Space":
				action_node.get_node("keyboard").icon = keyboard_buttons_icons["keyboard_space"]
				action_node.get_node("keyboard").text = ""
			else:
				action_node.get_node("keyboard").icon = keyboard_buttons_icons["keyboard_default"]

			if action_node.get_node("keyboard").text == "Left":
				action_node.get_node("keyboard").text = "←"
			elif action_node.get_node("keyboard").text == "Right":
				action_node.get_node("keyboard").text = "→"
			elif action_node.get_node("keyboard").text == "Up":
				action_node.get_node("keyboard").text = "↑"
			elif action_node.get_node("keyboard").text == "Down":
				action_node.get_node("keyboard").text = "↓"
		else:
			action_node.get_node("keyboard").text = ""

		# Controller button
		if keybinds[action]['joy_buttons'].size():
			action_node.get_node("joy_button").icon = controller_buttons_icons["joy_btn_" + keybinds[action]['joy_buttons'][0]]
		else:
			action_node.get_node("joy_button").icon = null
		
func _on_Exit_pressed():
	emit_signal("exit")


func _on_Settings_pressed():
	active_menu_tree.push_front(active_menu)
	active_menu = $SettingsMenu
	activate_first()
	$MainMenu.hide()
	$SettingsMenu.show()

func _on_StartGame_pressed():
	emit_signal("start_game")

func activate_first():
	active_menu.get_children()[0].grab_focus()



func _on_menu_option_gui_input(event:InputEvent):
	var focused_menu_option = active_menu.get_focus_owner()
	if focused_menu_option:
		var progressBar = focused_menu_option.get_node("ProgressBar")
		var checkbox = focused_menu_option.get_node("CheckBox")
		
		if progressBar:
			if event.is_action_pressed("ui_right"):
				progressBar.increase()
			if event.is_action_pressed("ui_left"):
				progressBar.decrease()
		elif checkbox:
			if event.is_action_pressed("ui_accept"):
				checkbox.pressed = !checkbox.pressed
				emit_signal("value_changed", focused_menu_option, checkbox.pressed)


func _on_Back_pressed():
	if active_menu_tree.size() == 0:
		return false

	active_menu.hide()
	active_menu = active_menu_tree.pop_front()
	active_menu.show()
	activate_first()
	return true


func _on_CheckBox_toggled(button_pressed:bool):	
	emit_signal("value_changed", active_menu.get_focus_owner().get_parent(), button_pressed)


func _on_Controls_pressed():
	active_menu_tree.push_front(active_menu)
	active_menu.hide()
	active_menu = $ControlsMenu
	$ControlsMenu.show()
	activate_first()


func _on_keyboard_bind_pressed():
	if !waiting_button_press:
		$ControlsWaitingInputPopup.show()
		waiting_button_press = true
		waiting_button_type = ButtonType.KEYBOARD
	
	
func _on_joy_button_bind_pressed():
	if !waiting_button_press && !ignore_next_accept_action:
		$ControlsWaitingInputPopup.show()
		waiting_button_press = true
		waiting_button_type = ButtonType.JOY
	else:
		ignore_next_accept_action = false


func _on_controls_input(event:InputEvent):
	if waiting_button_press:
		if event.is_pressed():
			var focused_menu_option = active_menu.get_focus_owner()
			var action = focused_menu_option.get_parent().name
	
			if event is InputEventKey && waiting_button_type == ButtonType.KEYBOARD:
				emit_signal("keybinds_change", waiting_button_type, action, event.scancode)
				reset_waiting_for_button()
			elif event is InputEventJoypadButton && waiting_button_type == ButtonType.JOY:
				var allowed = [0,1,2,3,4,5,6,7,8,9,12,13,14,15]

				if event.is_action_pressed("ui_accept"):
					ignore_next_accept_action = true

				if allowed.has(event.button_index):
					emit_signal("keybinds_change", waiting_button_type, action, event.button_index)
					reset_waiting_for_button()
			
func reset_waiting_for_button():
	$ControlsWaitingInputPopup.hide()
	waiting_button_press = false
	waiting_button_type = null

func find_by_class(node: Node, className : String, result : Array) -> void:
	if node.is_class(className) :
		result.push_back(node)
	for child in node.get_children():
		find_by_class(child, className, result)

func _on_menu_option_mouse_entered(obj):
	obj.grab_focus()


func _on_ProgressBar_value_changed(object, value):
	emit_signal("value_changed", active_menu.get_focus_owner(), value)
