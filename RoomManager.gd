extends Node2D

const ROOM_SIZE = Vector2(320, 176)  # Set to your room size in pixels
const MAX_ROOMS = 10  # Maximum number of rooms per floor

enum RoomType {
	NORMAL,
	BOSS,
	SHOP
}

var room_scenes = {
	RoomType.NORMAL: [],
	RoomType.BOSS: [],
	RoomType.SHOP: []
}

var grid = {}
var rooms = []

func _ready():
	load_rooms()
	generate_level()

func load_rooms():
	# Load your room scenes
	room_scenes[RoomType.NORMAL] = [
		preload("res://dungeon_room.tscn"),  # Use the same room for all types for testing
	]
	room_scenes[RoomType.BOSS] = [
		preload("res://Boss_room.tscn")
	]
	room_scenes[RoomType.SHOP] = [
		preload("res://shop_room.tscn")
	]

func generate_level():
	var start_position = Vector2(0, 0)
	grid[start_position] = RoomType.NORMAL
	add_room(start_position, RoomType.NORMAL)
	
	# Ensure boss room and shop room are added
	place_special_rooms()

	# Fill remaining spaces with normal rooms up to the maximum number of rooms
	fill_with_normal_rooms()

func place_special_rooms():
	var boss_position = get_best_empty_position()
	grid[boss_position] = RoomType.BOSS
	add_room(boss_position, RoomType.BOSS)

	var shop_position = get_best_empty_position()
	grid[shop_position] = RoomType.SHOP
	add_room(shop_position, RoomType.SHOP)

func fill_with_normal_rooms():
	while rooms.size() < MAX_ROOMS:
		var pos = get_best_empty_position()
		if pos != null and !grid.has(pos):
			grid[pos] = RoomType.NORMAL
			add_room(pos, RoomType.NORMAL)

func add_room(position, room_type):
	var room_scene = room_scenes[room_type][randi() % room_scenes[room_type].size()]
	var room_instance = room_scene.instantiate()

	# Adjust the room position based on the grid position
	var grid_position = position * ROOM_SIZE
	room_instance.position = grid_position
	add_child(room_instance)
	rooms.append(room_instance)
	
	grid[position] = room_instance  # Make sure to store the instance in the grid
	
	connect_doors(position, room_instance)

func connect_doors(position, room_instance):
	var directions = {
		Vector2(1, 0): "DoorLeft",
		Vector2(-1, 0): "DoorRight",
		Vector2(0, 1): "DoorUp",
		Vector2(0, -1): "DoorDown"
	}

	for direction in directions.keys():
		var neighbor_pos = position + direction
		if grid.has(neighbor_pos):
			var neighbor_instance = grid[neighbor_pos]
			if room_instance.has_node(directions[direction]) and neighbor_instance.has_node(directions[-direction]):
				var door = room_instance.get_node(directions[direction])
				var neighbor_door = neighbor_instance.get_node(directions[-direction])
				connect_door(door, neighbor_door)

func connect_door(door, neighbor_door):
	door.visible = false
	neighbor_door.visible = false

func get_best_empty_position():
	var best_positions = []
	for pos in grid.keys():
		for direction in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
			var new_pos = pos + direction
			if !grid.has(new_pos):
				best_positions.append(new_pos)
	return best_positions[randi() % best_positions.size()] if best_positions.size() > 0 else null


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
