class_name ComplexVariable extends Variable

var _val: Vector2
func _init(val: Vector2):
	self._val = val

func type() -> VariableType:
	return ComplexType.new()

func copy() -> Variable:
	return ComplexVariable.new(Vector2(self._val.x, self._val.y))

func value():
	return _val
