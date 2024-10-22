class_name CompoundStatement extends Statement

var _stmt1: Statement;
var _stmt2: Statement;

func _init(stmt1: Statement, stmt2: Statement):
	self._stmt1 = stmt1
	self._stmt2 = stmt2


func evaluate(env: LanguageEnvironment) -> Variable:
	_stmt1.evaluate(env);
	return _stmt2.evaluate(env);
