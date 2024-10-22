class_name BooleanVariable extends Variable

var _val: bool
func _init(val: bool):
	self._val = val

func type() -> VariableType:
	return BooleanType.new()

func copy() -> Variable:
	return BooleanVariable.new(_val)

func value():
	return _val
