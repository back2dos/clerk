package clerk.types;

#if !macro
@:genericBuild(clerk.types.MinLength.build())
class MinLength<Rest> {}
#else

import tink.macro.BuildCache;
import haxe.macro.Expr;
import haxe.macro.Type;
using tink.MacroApi;

class MinLength {
  public static function build() {
    return BuildCache.getTypeN('clerk.types.MinLength', function(ctx:BuildContextN) {
      var name = ctx.name;
      var pack = ['clerk', 'types'];
      var ct = TPath(pack.concat([name]).join('.').asTypePath());
      if(ctx.types.length > 2) ctx.pos.error('Too many type parameters, max is 2');
      var length = getInt(ctx.types[0], ctx.pos);
      var error = ctx.types.length == 2 ? getString(ctx.types[1], ctx.pos) : 'Too short, minimum length is $length';
      
      var def = macro class $name {
        @:from
        public static function ofString(s:String):$ct {
          return 
            if (s.length < $v{length}) throw $v{error};
            else cast s;
        }
      }
      def.pack = pack;
      def.kind = TDAbstract(macro:String, [], [macro:String]);
      def.pos = ctx.pos;
      return def;
    });
  }
  
  static function getInt(type:Type, pos:Position) {
    return switch type {
      case TInst(_.get() => {kind: KExpr(macro $v{(i:Int)})}, _): Std.parseInt(i);
      case _: pos.error('Expected type parameter to be a integer literal');
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