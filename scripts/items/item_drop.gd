class_name ItemDrop
extends Node3D
## Yere düşen eşya: döner, hafifçe süzülür, yakındaki oyuncuya uçup envantere girer.

const GRAVITY := 18.0
const SIZE := 0.25
const PICKUP_DELAY := 0.5
const ATTRACT_RANGE := 1.8
const PICKUP_RANGE := 0.5
const LIFETIME := 300.0

static var _block_textures := {}

var item_id: int
var count := 1
var world: World
var velocity := Vector3.ZERO

var _age := 0.0
var _visual := Node3D.new()


static func spawn(parent: Node, at: Vector3, id: int, amount := 1) -> ItemDrop:
	var drop := ItemDrop.new()
	drop.item_id = id
	drop.count = amount
	drop.world = parent.get_node_or_null("World") as World
	drop.velocity = Vector3(randf_range(-1.5, 1.5), 4.0, randf_range(-1.5, 1.5))
	parent.add_child(drop)
	drop.global_position = at
	return drop


func _ready() -> void:
	add_to_group("item_drops")
	add_child(_visual)
	if Items.is_block(item_id) and world:
		var mi := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3.ONE * SIZE
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = _block_texture(item_id)
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		# BoxMesh her yüzü 3x2'lik bir UV ızgarasına dizer; tek karenin tekrarlanması için ölçekle.
		mat.uv1_scale = Vector3(3, 2, 1)
		box.material = mat
		mi.mesh = box
		_visual.add_child(mi)
	else:
		var sprite := Sprite3D.new()
		sprite.texture = Items.item_icon(item_id)
		sprite.pixel_size = SIZE * 1.1 / sprite.texture.get_width()
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		_visual.add_child(sprite)


func _block_texture(id: int) -> Texture2D:
	if not _block_textures.has(id):
		_block_textures[id] = ImageTexture.create_from_image(world.atlas.icon(id).get_image())
	return _block_textures[id]


func _physics_process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	_visual.rotation.y += delta * 1.5
	_visual.position.y = SIZE / 2.0 + sin(_age * 3.0) * 0.05

	var player := get_tree().get_first_node_in_group("player") as Player
	if player and _age > PICKUP_DELAY and player.can_pick_up(item_id):
		var target := player.global_position + Vector3.UP * 0.8
		var dist := global_position.distance_to(target)
		if dist < PICKUP_RANGE:
			count = player.pick_up(item_id, count)
			if count == 0:
				queue_free()
				return
		elif dist < ATTRACT_RANGE:
			global_position = global_position.move_toward(target, delta * 8.0)
			velocity = Vector3.ZERO
			return

	velocity.y -= GRAVITY * delta
	var next := global_position + velocity * delta
	if world and velocity.y <= 0.0 and Blocks.is_solid(world.get_block(Vector3i(next.floor()))):
		next.y = floorf(next.y) + 1.0
		velocity = Vector3.ZERO
	elif world and Blocks.is_solid(world.get_block(Vector3i(Vector3(next.x, global_position.y, next.z).floor()))):
		velocity.x = 0.0
		velocity.z = 0.0
		next.x = global_position.x
		next.z = global_position.z
	global_position = next
