package ruby;
using Inspect;

class ParseSpec {
  public static function parse(rubyCode:String) {
    return ruby.Parse.fromString(rubyCode);
  }

  // public static function exprs(exprs) {
  //   return Exprs(Start(exprs));
  // }

  public static function describe(d:spaceCadet.Description) {
    var parsed:ruby.Parse.Ast;
    d.before(function(a) parsed = null);

    d.describe('Parsing', function(d) {

      d.describe('expressions', function(d) {
        d.it('parses single expressions', function(a) {
          a.isTrue(parse('nil').isNil);
        });
        d.it('parses multiple expressions', function(a) {
          parsed = parse('9;4');
          a.isTrue(parsed.isExprs);
          var exprs = parsed.toExprs();
          a.eq(2, exprs.length);
          a.eq(9, exprs.get(0).toInteger().value);
          a.eq(4, exprs.get(1).toInteger().value);
        });
      });

      d.describe('literals', function(d) {
        d.example('nil',   function(a) {
          parsed = parse('nil');
          a.isTrue(parsed.isNil);
          parsed.toNil();
        });
        d.example('true',  function(a) {
          parsed = parse('true');
          a.isTrue(parsed.isTrue);
          parsed.toTrue();
        });
        d.example('false', function(a) {
          parsed = parse('false');
          a.isTrue(parsed.isFalse);
          parsed.toFalse();
        });
        d.example('self',  function(a) {
          parsed = parse('self');
          a.isTrue(parsed.isSelf);
          parsed.toSelf();
        });
        d.example('integers', function(a) {
          parsed = parse('1');
          a.isTrue(parsed.isInteger);
          a.eq(1, parsed.toInteger().value);

          parsed = parse('-123');
          a.isTrue(parsed.isInteger);
          a.eq(-123, parsed.toInteger().value);
        });
        d.example('float', function(a) {
          parsed = parse('-12.34');
          a.isTrue(parsed.isFloat);
          a.eq(-12.34, parsed.toFloat().value);

          parsed = parse('1.0');
          a.isTrue(parsed.isFloat);
          a.eq(1.0, parsed.toFloat().value);
        });
        d.example('string', function(a) {
          parsed = parse('"abc"');
          a.isTrue(parsed.isString);
          a.eq("abc", parsed.toString().value);
        });
      });


      d.describe('variables', function(d) {
        d.context('Constant', function(a) {
          d.example('with no namespace', function(a) {
            parsed = parse("A");
            a.isTrue(parsed.isConst);
            var const = parsed.toConst();
            a.eq("A", const.name);
            a.eq(true, const.ns.isDefault);
          });
          d.example('with a namespace', function(a) {
            parsed = parse("A::B");
            var const = parsed.toConst();
            a.eq("B", const.name);
            a.eq("A", const.ns.toConst().name);
            a.eq(true, const.ns.toConst().ns.isDefault);
          });
        });
        d.example('setting and getting local vars', function(a) {
          var exprs = parse("a = 1; a").toExprs();
          a.eq(2, exprs.length);

          a.isTrue(exprs.get(0).isSetLvar);
          var setlvar = exprs.get(0).toSetLvar();
          a.eq('a', setlvar.name);
          a.eq(1, setlvar.value.toInteger().value);

          a.isTrue(exprs.get(1).isGetLvar);
          a.eq('a', exprs.get(1).toGetLvar().name);
        });
        d.example('setting and getting instance vars', function(a) {
          var exprs = parse("@a = 1; @a").toExprs();
          a.eq(2, exprs.length);

          a.isTrue(exprs.get(0).isSetIvar);
          var setivar = exprs.get(0).toSetIvar();
          a.eq('@a', setivar.name);
          a.eq(1, setivar.value.toInteger().value);

          a.isTrue(exprs.get(1).isGetIvar);
          a.eq('@a', exprs.get(1).toGetIvar().name);
        });
      });

      d.describe('sending messages', function(d) {
        d.it('parses the target, message, and arguments', function(a) {
          parsed = parse("true.something(false)");
          a.isTrue(parsed.isSend);
          var send = parsed.toSend();
          a.isTrue(send.target.isTrue);
          a.eq("something", send.message);
          a.eq(1, send.arguments.length);
          a.isTrue(send.arguments[0].isFalse);
        });
      });

      d.describe('class definitions', function(d) {
        d.it('parses the namespace, name, superclas, and body', function(a) {
          parsed = parse("class A::B < C; 1; end");
          a.isTrue(parsed.isOpenClass);
          var klass = parsed.toOpenClass();
          a.eq('B', klass.ns.toConst().name);
          a.eq('A', klass.ns.toConst().ns.toConst().name);
          a.eq('C', klass.superclass.toConst().name);
          a.eq(1,   klass.body.toInteger().value);
        });

        d.it('parses defaults -- no namespace, superclass, or body', function(a) {
          parsed = parse("class A; end");
          a.isTrue(parsed.isOpenClass);
          var klass = parsed.toOpenClass();
          a.eq('A', klass.ns.toConst().name);
          a.isTrue(klass.ns.toConst().ns.isDefault);
          a.isTrue(klass.superclass.isDefault);
          a.isTrue(klass.body.isDefault);
        });
      });

      // d.describe('module definitions', function(d) {
      // });

      d.describe('method definitions', function(d) {
        d.example('with no parameters or body', function(a) {
          parsed = parse("def bland_method; end");
          a.isTrue(parsed.isDef);
          var def = parsed.toDef();
          a.eq("bland_method", def.name);
          a.eq(0, def.parameters.length);
          a.isTrue(def.body.isDefault);
        });
        d.example('with a body', function(a) {
          var def = parse("def hasbody; true; end").toDef();
          a.isTrue(def.body.isTrue);
        });
        d.example('with required and rest args', function(a) {
          var def = parse("def hasargs(req, *rst); end").toDef();
          a.eq(2, def.parameters.length);

          var req = def.parameters[0];
          a.eq(req.type, Required);
          a.eq('req', req.name);

          var rest = def.parameters[1];
          a.eq(rest.type, Rest);
          a.eq('rst', rest.name);
        });
      });
    });
  }
}
