extends Node


func _ready():
	pass

func GetItem(t, n):
	return get_node(t).get_node(n)

func GetValue(t, n, c):
	if c[0] == "_":
		return GetItem(t, n).get_node(c.substr(1))
	else:
		return GetItem(t, n).get(c)

func Contains(t, n):
	if get_node(t).get_node_or_null(n):
		return true
	else:
		return false

# todo: finish and test this?
func GetWhere(t, c, comparator, comparison):
	var expr = Expression.new()
	
	var results = []
	for n in get_node(t).get_children():
		var val = n.get(c)
		var exprStr = "\"%s\" %s \"%s\"" % [val, comparator, comparison]
		expr.parse(exprStr)
		var result = expr.execute()
		if result:
			results.append(n)
	
	return results
