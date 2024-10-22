class_name VariableExpression extends ExpressionStatement

var varName: String;

func _init(varName: String):
	self._varName = varName

func evaluate(env: LanguageEnvironment) -> Variable:
	return env.get_variable_value(varName)
