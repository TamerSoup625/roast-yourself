extends Sprite2D


const MAX_OFFSET: float = 800

@export var my_noise: FastNoiseLite

var noise_x: FastNoiseLite
var noise_y: FastNoiseLite
var pos: float = 0.0


func _ready():
	noise_x = my_noise.duplicate()
	noise_y = my_noise.duplicate()
	randomize()
	noise_x.seed = randi()
	noise_y.seed = randi()


func _process(delta):
	region_rect.position = Vector2(
		noise_x.get_noise_1d(pos) * MAX_OFFSET,
		noise_y.get_noise_1d(pos) * MAX_OFFSET,
	)
	pos += delta
