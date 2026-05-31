extends ColorRect

var datura_pop := []
var max_points := 200
var graph_size := Vector2(144, 144)

func datura_pop_update() -> void:
	var count = Util.get_all_group_node("datura").size()
	datura_pop.append(count)

	if datura_pop.size() > max_points:
		datura_pop.pop_front()

	update_graph()

func update_graph() -> void:
	queue_redraw()

func _draw() -> void:
	if datura_pop.size() < 2:
		return

	var max_y = 1
	for v in datura_pop:
		max_y = max(max_y, v)

	var step_x = graph_size.x / float(max(datura_pop.size() - 1, 1))

	for i in range(datura_pop.size() - 1):
		var x1 = i * step_x
		var x2 = (i + 1) * step_x

		var y1 = graph_size.y - (datura_pop[i] / max_y) * graph_size.y
		var y2 = graph_size.y - (datura_pop[i + 1] / max_y) * graph_size.y

		draw_line(Vector2(x1, y1), Vector2(x2, y2), Color.WHITE, 1)
