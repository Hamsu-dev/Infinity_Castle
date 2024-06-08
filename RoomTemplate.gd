class_name RoomTemplate
extends Node2D

enum DoorPosition {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var doors = []

func has_door(position: DoorPosition) -> bool:
	return position in doors
