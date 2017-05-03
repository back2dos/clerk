package clerk.macros;

import tink.macro.BuildCache;
using tink.MacroApi;

class Build {
  static function form() {
    return BuildCache.getType('clerk.Form', function (ctx:BuildContext) {
      var name = ctx.name,
          ct = ctx.type.toComplex();
      return macro class $name extends clerk.Form.FormBase {
        public function new() {}
        public function validate(form:js.html.Element, onError):$ct {
          return process(form, onError, function (data, report) 
            return new tink.querystring.Parser<String->$ct>(report).parse(data)
          );
        }
      }
    });
  }
}