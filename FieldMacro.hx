package;

import haxe.macro.Context;
import haxe.macro.Expr;

class FieldMacro
{
	macro public static function build():Array<Field>
	{
		var currentPos = Context.currentPos();

		var prev = Context.getBuildFields();
		var fields:Array<Field> = [];
		var targets:Array<{field:Field, t:Null<ComplexType>, e:Null<Expr>}> = [];
		var found:Int = 0;

		var Fields:Field = null;
		var FieldsExpr:Expr = null;
		var FlushExpr:Expr = null;

		var debug:String = "";

		for (field in prev)
		{
			if (field.access.indexOf(AStatic) > -1)
			{
				{
					switch (field.name)
					{
						case "DataField":
							switch (field.kind)
							{
								case FVar(macro:FlxSave, e):
									Fields = field;
									FieldsExpr = {expr: EField(e, 'data'), pos: e.pos};
									FlushExpr = {expr: EField(e, 'flush'), pos: e.pos};
									continue;
								case _:
							}
					}
				}

				fields.push(field);
			}
			else if (field.access.length < 1)
			{
				switch (field.kind)
				{
					// FVar(t:Null<ComplexType>, e:Null<Expr>)
					case FVar(t, e):
						targets.push({field: field, t: t, e: e});
						found++;
						continue;
					case _:
				}
			}
		}

		if (Fields == null)
		{
			// Dosen't having Core DataField
			var message:Array<String> = ["Class dosen't have Static Field:"];
			if (Fields == null)
				message.push('\tDataField:FlxSave');

			throw new Error(message.join("\n"), currentPos);
		}
		else
		{
			for (field in targets)
			{
				var t = field.t;
				var e = field.e;

				var field = field.field;
				var FieldName:String = field.name;

				var type:String = null;
				switch (t)
				{
					case TPath(p):
						type = p.name;
					case _:
						debug += '\n\t' + FieldName + ': Please specify the Fields\'s Type.';
				}

				var types:Array<String> = [];
				switch (t)
				{
					case TPath(p):
						var params = p.params;
						if (params != null && params.length > 0)
						{
							for (param in params)
							{
								switch (param)
								{
									case TPType(t):
										switch (t)
										{
											case TPath(p):
												types.push(p.name);
											case _:
										}
									case _:
								}
							}
						}
					case _:
				}

				var Document:String = FieldName + ': ' + type;
				if (types.length > 0)
				{
					Document += '\\<${types.join(", ")}\\>';
				}
                if (field.doc != null)
                {
                    Document += '\n' + field.doc;
                }

				var FpropField:Field = {
					name: FieldName,
					access: [APublic, AStatic],
					doc: Document,
					pos: currentPos,
					kind: FProp("get", "set", t, null),
					meta: null
				};

				var Extra:Expr = {
					expr: EField(FieldsExpr, FieldName),
					pos: currentPos
				};

				var ___Expr:Expr = {
					expr: EBlock([
						macro $e{Extra} = $e{e},
						{
							expr: ECall(FlushExpr, []),
							pos: currentPos
						}
					]),
					pos: currentPos
				};

				var GetterFunc:Expr = {
					expr: EBlock([
						{
							expr: EIf({
								expr: EBinop(OpEq, Extra, {
									expr: EConst(CIdent("null")),
									pos: currentPos
								}),
								pos: currentPos
							}, ___Expr, null),
							pos: currentPos
						},
						{
							expr: EReturn(Extra),
							pos: currentPos,
						}
					]),
					pos: currentPos,
				};

				var Getter:Field = {
					name: "get_" + FieldName,
					access: [Access.AInline, Access.AStatic, Access.APrivate],
					kind: FFun({
						expr: GetterFunc,
						args: [],
						ret: t,
					}),
					pos: currentPos,
				};

				var ___Expr:Expr = {
					expr: EBlock([
						macro $e{Extra} = $i{'value'},
						{
							expr: ECall(FlushExpr, []),
							pos: currentPos
						},
						{
							expr: EReturn(macro $e{Extra}),
							pos: currentPos
						}
					]),
					pos: currentPos
				};

				var SetterFunc = ___Expr; // EReturn(macro $e{Extra} = $i{'value'});

				var Setter:Field = {
					name: "set_" + FieldName,
					access: [Access.AInline, Access.AStatic, Access.APrivate],
					kind: FieldType.FFun({
						expr: SetterFunc,
						args: [
							{
								name: "value",
								type: t,
							}
						],
						ret: t,
					}),
					pos: currentPos,
				};

				fields.push(FpropField);
				fields.push(Getter);
				fields.push(Setter);

				debug += '\n\t' + type + ' -> ' + field.access + ' ' + FieldName + ': ' + t + ', ' + e + '\n --->' + Document;
			}

			// throw new Error('Found Save Fields: $found\nErros:' + debug, currentPos);
		}

		return fields;
	}

	macro public static function from():Array<Field>
	{
		var currentPos = Context.currentPos();

		var prev = Context.getBuildFields();
		var fields:Array<Field> = [];
		var targets:Array<{field:Field, t:Null<ComplexType>, e:Null<Expr>}> = [];
		var found:Int = 0;

		var Fields:Field = null;
		var FieldsExpr:Expr = null;
		var FlushExpr:Expr = null;

		var debug:String = "";

		for (field in prev)
		{
			if (field.access.indexOf(AStatic) > -1)
			{
				{
					switch (field.name)
					{
						case "DataField":
							switch (field.kind)
							{
								case FVar(macro:FlxSave, e):
									Fields = field;
									FieldsExpr = {expr: EField(e, 'data'), pos: e.pos};
									FlushExpr = {expr: EField(e, 'flush'), pos: e.pos};
									continue;
								case _:
							}
					}
				}

				fields.push(field);
			}
			else if (field.access.length < 1)
			{
				switch (field.kind)
				{
					// FVar(t:Null<ComplexType>, e:Null<Expr>)
					case FVar(t, e):
						targets.push({field: field, t: t, e: e});
						found++;
						continue;
					case _:
				}
			}
		}

		if (Fields == null)
		{
			// Dosen't having Core DataField
			var message:Array<String> = ["Class dosen't have Static Field:"];
			if (Fields == null)
				message.push('\tDataField:FlxSave');

			throw new Error(message.join("\n"), currentPos);
		}
		else
		{
			for (field in targets)
			{
				var t = field.t;
				var e = field.e;

				var field = field.field;
				var FieldName:String = field.name;

				var type:String = null;
				switch (t)
				{
					case TPath(p):
						type = p.name;
					case _:
						debug += '\n\t' + FieldName + ': Please specify the Fields\'s Type.';
				}

				var types:Array<String> = [];
				switch (t)
				{
					case TPath(p):
						var params = p.params;
						if (params != null && params.length > 0)
						{
							for (param in params)
							{
								switch (param)
								{
									case TPType(t):
										switch (t)
										{
											case TPath(p):
												types.push(p.name);
											case _:
										}
									case _:
								}
							}
						}
					case _:
				}

                var Meta:Null<Metadata> = [{
                    name: ':noCompletion',
                    params: [],
                    pos: currentPos
                }];

				var Document:String = FieldName + ': ' + type;
				if (types.length > 0)
				{
					Document += '\\<${types.join(", ")}\\>';
				}

				var FpropField:Field = {
					name: FieldName,
					access: [APublic, AStatic],
					doc: Document,
					pos: currentPos,
					kind: FProp("get", "set", t, null),
					meta: null
				};

				var Extra:Expr = {
					expr: EField(FieldsExpr, FieldName),
					pos: currentPos
				};

				var ___Expr:Expr = {
					expr: EBlock([
						macro $e{Extra} = $e{e},
						{
							expr: ECall(FlushExpr, []),
							pos: currentPos
						}
					]),
					pos: currentPos
				};

				var GetterFunc:Expr = {
					expr: EBlock([
						{
							expr: EIf({
								expr: EBinop(OpEq, Extra, {
									expr: EConst(CIdent("null")),
									pos: currentPos
								}),
								pos: currentPos
							}, ___Expr, null),
							pos: currentPos
						},
						{
							expr: EReturn(Extra),
							pos: currentPos,
						}
					]),
					pos: currentPos,
				};

				var Getter:Field = {
					name: "get_" + FieldName,
					access: [Access.AInline, Access.AStatic, /*Access.APrivate,*/],
					kind: FFun({
						expr: GetterFunc,
						args: [],
						ret: t,
					}),
					pos: currentPos,
                    meta: Meta,
				};

				var ___Expr:Expr = {
					expr: EBlock([
						macro $e{Extra} = $i{'value'},
						{
							expr: ECall(FlushExpr, []),
							pos: currentPos
						},
						{
							expr: EReturn(macro $e{Extra}),
							pos: currentPos
						}
					]),
					pos: currentPos
				};

				var SetterFunc = ___Expr; // EReturn(macro $e{Extra} = $i{'value'});

				var Setter:Field = {
					name: "set_" + FieldName,
					access: [Access.AInline, Access.AStatic, Access.APrivate],
					kind: FieldType.FFun({
						expr: SetterFunc,
						args: [
							{
								name: "value",
								type: t,
							}
						],
						ret: t,
					}),
					pos: currentPos,
                    meta: Meta,
				};

				fields.push(FpropField);
				fields.push(Getter);
				fields.push(Setter);

				debug += '\n\t' + type + ' -> ' + field.access + ' ' + FieldName + ': ' + t + ', ' + e + '\n --->' + Document;
			}

			// throw new Error('Found Save Fields: $found\nErros:' + debug, currentPos);
		}

		return fields;
	}
}
