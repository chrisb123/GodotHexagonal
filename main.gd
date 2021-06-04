tool
extends Node2D

export (AtlasTexture) var atlas
var tex_size = Vector2(96,96)
var height = 24
export (int) var size = 32
export (Color) var color
export (bool) var pointy = false

var height_scaled = 2*size/(tex_size.y)*height
var hex_grid = {}
var tiles = []
var ysort:YSort = YSort.new()
var sprites = {}

func _enter_tree():
	add_child(ysort)
	tiles.append(atlas.duplicate())
	tiles[0].region = Rect2(Vector2(0,0),tex_size)
	tiles.append(atlas.duplicate())
	tiles[1].region = Rect2(Vector2(96,0),tex_size)
	tiles.append(atlas.duplicate())
	tiles[2].region = Rect2(Vector2(96*2,0),tex_size)

func add_hex(hex:Vector2,tile=0)->bool:
	if hex_grid.has(hex):
		print("Point exists")
		return false
	var hexdata = gen_hex(hex)
	hex_grid[hex] = hexdata
	update()
	var s = Sprite.new()
	sprites[hex] = s
	s.texture = tiles[tile]
	ysort.add_child(s)
	s.position = hex_to_pixel(hex)
	s.scale = Vector2(sqrt(3)*size/tex_size.x,2*size/(tex_size.y-height))
#	s.scale *= 0.95
	return true

func _draw():
	for i in hex_grid:
		draw_polyline(hex_grid[i], color)
	
func get_sprite(pos):
	var hex = pixel_to_hex(pos)
	if sprites.has(hex):
		return sprites[hex]
	return null
	
func gen_hex(hex:Vector2)->PoolVector2Array:
	var pos = hex_to_pixel(hex)
	var hexarray:PoolVector2Array
	for i in range(0,7):
		hexarray.append(hex_corner(pos, size, i))
	return hexarray

func hex_corner(center:Vector2, size, i)->Vector2:
	var angle_deg:float
	var angle_rad:float
	if pointy:
		angle_deg = 60 * i - 30
	else:
		angle_deg = 60 * i
	angle_rad = PI / 180 * angle_deg
	return Vector2(center.x + size * cos(angle_rad),
				 center.y + size * sin(angle_rad))

func hex_to_pixel(hex:Vector2)->Vector2:
	var x
	var y
	if pointy:
		x = size * (sqrt(3) * hex.x  +  sqrt(3)/2 * hex.y)
		y = size * (                        3.0/2 * hex.y)
	else:
		x = size * (     3.0/2 * hex.x                    )
		y = size * (sqrt(3 )/2 * hex.x  +  sqrt(3) * hex.y)
	return Vector2(x, y)
	
func pixel_to_hex(point:Vector2)->Vector2:
	var q
	var r
	if pointy:
		q = (sqrt(3)/3 * point.x  -  1.0/3 * point.y) / size
		r = (                        2.0/3 * point.y) / size
	else:
		q = ( 2.0/3 * point.x                        ) / size
		r = (-1.0/3 * point.x  +  sqrt(3)/3 * point.y) / size
	return hex_round(Vector2(q, r))
	
func hex_round(hex:Vector2)->Vector2:
	return cube_to_axial(cube_round(axial_to_cube(hex)))

func cube_round(cube:Vector3)->Vector3:
	var rx = round(cube.x)
	var ry = round(cube.y)
	var rz = round(cube.z)

	var x_diff = abs(rx - cube.x)
	var y_diff = abs(ry - cube.y)
	var z_diff = abs(rz - cube.z)

	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry-rz
	elif y_diff > z_diff:
		ry = -rx-rz
	else:
		rz = -rx-ry

	return Vector3(rx, ry, rz)
	
func cube_to_axial(cube:Vector3)->Vector2:
	var q = cube.x
	var r = cube.z
	return Vector2(q, r)

func axial_to_cube(hex:Vector2)->Vector3:
	var x = hex.x #q
	var z = hex.y #r
	var y = -x-z
	return Vector3(x, y, z)
