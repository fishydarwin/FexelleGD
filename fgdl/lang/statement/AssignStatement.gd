class_name AssignStatement extends Statement

var _varName: String;
var _stmt: ExpressionStatement;

func _init(varName: String, stmt: Statement):
	self._varName = varName
	self._stmt = stmt


func evaluate(env: LanguageEnvironment) -> Variable:
	# TODO: implement statement
	return null
