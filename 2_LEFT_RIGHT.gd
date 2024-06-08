extends RoomTemplate

func _on_player_detector_body_entered(body: Node2D) -> void:
	Events.room_entered.emit(self)
	
func _ready():
	doors = [DoorPosition.LEFT, DoorPosition.RIGHT]
