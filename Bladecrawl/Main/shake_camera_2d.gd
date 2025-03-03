extends Camera2D


var noise_y: int = 0
var trauma: float = 0.0
var trauma_power:int = 2

@export var decay: float = 1
@export var max_offset: Vector2 = Vector2(30,30)
@export var max_roll: float = 0.05
@export var noise: Noise = FastNoiseLite.new()


func _ready():
	randomize()
	noise.noise_type = 3
	noise.seed = randi()

func add_trauma(ammount: float):
	trauma = min(trauma + ammount, 0.3)

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0.0)
		shake()


func shake():
	var amount: float = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * clamp(noise.get_noise_2d(noise.seed, noise_y),-0.8,0.8)
	offset.x = max_offset.x * amount * clamp(noise.get_noise_2d(noise.seed*2, noise_y),-0.8,0.8)
	offset.y = max_offset.y * amount * clamp(noise.get_noise_2d(noise.seed*3, noise_y),-0.8,0.8)


func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_F3:
			add_trauma(0.7)
