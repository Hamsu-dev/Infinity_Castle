extends Node2D

const ROOM_SIZE = Vector2(320, 176)  # Set to your room size in pixels
const MAX_ROOMS = 10  # Maximum number of rooms per floor

enum RoomType {
	NORMAL,
	BOSS,
	SHOP
}

enum DoorPosition {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var directions = {
	DoorPosition.UP: Vector2(0, -1),
	DoorPosition.DOWN: Vector2(0, 1),
	DoorPosition.LEFT: Vector2(-1, 0),
	DoorPosition.RIGHT: Vector2(1, 0)
}

var room_data = {
	"dungeon_room": { "scene": preload("res://Doors/dungeon_room.tscn"), "doors": [DoorPosition.UP, DoorPosition.DOWN, DoorPosition.LEFT, DoorPosition.RIGHT] },
	"3_BOTTOM_MISSING": { "scene": preload("res://Doors/3_BOTTOM_MISSING.tscn"), "doors": [DoorPosition.UP, DoorPosition.LEFT, DoorPosition.RIGHT] },
	"3_TOP_MISSING": { "scene": preload("res://Doors/3_TOP_MISSING.tscn"), "doors": [DoorPosition.DOWN, DoorPosition.LEFT, DoorPosition.RIGHT] },
	"3_LEFT_MISSING": { "scene": preload("res://Doors/3_LEFT_MISSING.tscn"), "doors": [DoorPosition.UP, DoorPosition.DOWN, DoorPosition.RIGHT] },
	"3_RIGHT_MISSING": { "scene": preload("res://Doors/3_RIGHT_MISSING.tscn"), "doors": [DoorPosition.UP, DoorPosition.DOWN, DoorPosition.LEFT] },
	"2_DOOR_LEFT_BOTTOM": { "scene": preload("res://Doors/2_DOOR_LEFT_BOTTOM.tscn"), "doors": [DoorPosition.UP, DoorPosition.RIGHT] },
	"2_DOOR_RIGHT_BOTTOM": { "scene": preload("res://Doors/2_DOOR_RIGHT_BOTTOM.tscn"), "doors": [DoorPosition.UP, DoorPosition.LEFT] },
	"2_DOOR_TOP_LEFT": { "scene": preload("res://Doors/2_DOOR_TOP_LEFT.tscn"), "doors": [DoorPosition.DOWN, DoorPosition.RIGHT] },
	"2_Door_UP_RIGHT": { "scene": preload("res://Doors/2_Door_UP_RIGHT.tscn"), "doors": [DoorPosition.DOWN, DoorPosition.LEFT] },
	"2_LEFT_RIGHT": { "scene": preload("res://Doors/2_LEFT_RIGHT.tscn"), "doors": [DoorPosition.LEFT, DoorPosition.RIGHT] },
	"2_door_up_down": { "scene": preload("res://Doors/2_door_up_down.tscn"), "doors": [DoorPosition.UP, DoorPosition.DOWN] },
	"TOP_DOOR_ONLY": { "scene": preload("res://Doors/TOP_DOOR_ONLY.tscn"), "doors": [DoorPosition.UP] },
	"BOTTOM_DOOR_ONLY": { "scene": preload("res://Doors/BOTTOM_DOOR_ONLY.tscn"), "doors": [DoorPosition.DOWN] },
	"LEFT_DOOR_ONLY": { "scene": preload("res://Doors/LEFT_DOOR_ONLY.tscn"), "doors": [DoorPosition.LEFT] },
	"RIGHT_DOOR_ONLY": { "scene": preload("res://Doors/RIGHT_DOOR_ONLY.tscn"), "doors": [DoorPosition.RIGHT] }
}

var grid = {}
var rooms = []

func _ready():
	generate_level()

func generate_level():
	var start_position = Vector2(0, 0)
	add_room(start_position, "dungeon_room")
	
	place_special_rooms()
	fill_with_normal_rooms()
	validate_and_adjust_rooms()

func place_special_rooms():
	var boss_position = get_best_empty_position()
	if boss_position != null:
		add_room(boss_position, "dungeon_room")

	var shop_position = get_best_empty_position()
	if shop_position != null:
		add_room(shop_position, "dungeon_room")

func fill_with_normal_rooms():
	while rooms.size() < MAX_ROOMS:
		var pos = get_best_empty_position()
		if pos != null and !grid.has(pos):
			add_room(pos, "dungeon_room")

func add_room(position, room_type):
	var room_scene = room_data[room_type]["scene"]
	var room_instance = room_scene.instantiate()
	var room_doors = room_data[room_type]["doors"]

	# Adjust the room position based on the grid position
	var grid_position = position * ROOM_SIZE
	room_instance.position = grid_position
	add_child(room_instance)
	rooms.append({ "instance": room_instance, "doors": room_doors })
	
	grid[position] = room_instance  # Make sure to store the instance in the grid
	
	connect_doors(position, room_instance, room_doors)

func connect_doors(position, room_instance, room_doors):
	for direction in directions.keys():
		var neighbor_pos = position + directions[direction]
		if grid.has(neighbor_pos):
			var neighbor_instance = grid[neighbor_pos]
			var neighbor_doors = get_doors(neighbor_instance)
			if direction in room_doors and opposite_direction(direction) in neighbor_doors:
				var door = room_instance.get_node(door_name(direction))
				var neighbor_door = neighbor_instance.get_node(door_name(opposite_direction(direction)))
				connect_door(door, neighbor_door)

func get_doors(room_instance):
	for room in rooms:
		if room["instance"] == room_instance:
			return room["doors"]
	return []

func connect_door(door, neighbor_door):
	door.visible = true
	neighbor_door.visible = true

func validate_and_adjust_rooms():
	for position in grid.keys():
		var room_instance = grid[position]
		var room_doors = get_doors(room_instance)
		for direction in directions.keys():
			var neighbor_pos = position + directions[direction]
			if !grid.has(neighbor_pos) and direction in room_doors:
				var door = room_instance.get_node(door_name(direction))
				if door:
					door.queue_free()

func direction_to_vector(direction):
	return directions[direction]

func opposite_direction(direction):
	match direction:
		DoorPosition.UP:
			return DoorPosition.DOWN
		DoorPosition.DOWN:
			return DoorPosition.UP
		DoorPosition.LEFT:
			return DoorPosition.RIGHT
		DoorPosition.RIGHT:
			return DoorPosition.LEFT
	return -1

func door_name(direction):
	match direction:
		DoorPosition.UP:
			return "DoorUp"
		DoorPosition.DOWN:
			return "DoorDown"
		DoorPosition.LEFT:
			return "DoorLeft"
		DoorPosition.RIGHT:
			return "DoorRight"
	return ""

func get_best_empty_position():
	var best_positions = []
	for pos in grid.keys():
		for direction in directions.keys():
			var new_pos = pos + directions[direction]
			if !grid.has(new_pos):
				best_positions.append(new_pos)
	return best_positions[randi() % best_positions.size()] if best_positions.size() > 0 else null

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
