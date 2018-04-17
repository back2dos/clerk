package clerk.types;

#if !macro
@:genericBuild(clerk.types.RegExp.build())
class RegExp<Rest> {}
#else

import tink.macro.BuildCache;
import haxe.macro.Expr;
import haxe.macro.Type;
using tink.MacroApi;

class RegExp {
  public static function build() {
    return BuildCache.getTypeN('clerk.types.RegExp', function(ctx:BuildContextN) {
      var name = ctx.name;
      var pack = ['clerk', 'types'];
      var ct = TPath(pack.concat([name]).join('.').asTypePath());
      if(ctx.types.length > 2) ctx.pos.error('Too many type parameters, max is 2');
      var regex = getRegExp(ctx.types[0], ctx.pos);
      var error = 
        if(ctx.types.length == 2)
          macro $v{getString(ctx.types[1], ctx.pos)}
        else 
          macro 'Invalid value "' + s + $v{'" (should match ~/${regex.r}/${regex.opt})'};
      
      var def = macro class $name {
        static var regex = new EReg($v{regex.r}, $v{regex.opt});
        @:from
        public static function ofString(s:String):$ct {
          return 
            if (regex.match(s)) cast s
            else throw $error;
        }
      }
      def.pack = pack;
      def.kind = TDAbstract(macro:String, [], [macro:String]);
      def.pos = ctx.pos;
      return def;
    });
  }
  
  static function getRegExp(type:Type, pos:Position) {
    return switch type {
      case TInst(_.get() => {kind: KExpr({expr: EConst(CRegexp(r, opt))})}, _): {r: r, opt: opt};
      case _: pos.error('Expected type parameter to be a regular expression literal');
    }
  }
  
  static function getString(type:Type, pos:Position) {
    return switch type {
      case TInst(_.get() => {kind: KExpr(macro $v{(s:String)})}, _): s;
      case _: pos.error('Expected type parameter to be a string literal');
    }
  }
}

#end