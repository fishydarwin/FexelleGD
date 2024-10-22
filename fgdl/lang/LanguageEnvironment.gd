class_name LanguageEnvironment extends Object

var _variables: Dictionary;
var _functions: Dictionary;
var _errors: Array

func _init():
	_variables = {}
	_functions = {}
	_errors = []

func has_variable(name: String) -> bool:
	return name in _variables

func set_variable_value(name: String, value: Variable):
	_variables[name] = value

func get_variable_value(name: String) -> Variable:
	if name not in _variables:
		_errors.push_back("No variable %s" % name)
		return null
	else:
		return _variables[name]

func has_function(name: String) -> bool:
	return name in _functions

func add_function(name: String, param_types: Array):
	if name in _functions:
		_errors.push_back("Double function declaration: %s()" % name)
		return null
	_functions[name] = param_types

func get_function_param_types(name: String) -> Array:
	return _functions[name].duplicate()

func get_errors() -> Array:
	return _errors.duplicate()

func clear_errors():
	_errors.clear()
