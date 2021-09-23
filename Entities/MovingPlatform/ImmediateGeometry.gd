extends ImmediateGeometry


func draw_line(start: Vector3, end: Vector3, color: Color) -> void:
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	set_color(color)
	add_vertex(start)
	add_vertex(end)
	end()
