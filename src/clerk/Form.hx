package clerk;

import js.html.*;

using StringTools;
using tink.CoreApi;
@:genericBuild(clerk.macros.Build.form())
class Form<Data> {}

class FormBase {
  function process<T>(
    form:Element, 
    validate:tink.querystring.Pairs<String>->Callback<{ name:String, reason:String }>->T
  ):Validation<T> {

    var byName = new Map();
    var children = [for (e in form.querySelectorAll('[name]')) {
      
      var e:Element = cast e;
      
      byName[e.getAttribute('name')] = e;

      switch e.nodeName.toLowerCase() {
        case 'input': 
          var input:InputElement = cast e;
          new Named(
            input.name,
            switch input {
              case { type : 'radio' | 'checkbox', checked: false }: continue; 
              case _.value.trim() => '': continue;
              default: input.value;
            }
          );
        case 'select':
          var select:SelectElement = cast e;
          new Named(select.name, select.value);//TODO: find out how multiple selects represent their data
        case 'textarea':
          var textarea:TextAreaElement = cast e;
          switch textarea.value.trim() {
            case '': continue;
            case v: new Named(textarea.name, v); 
          }
        default: continue;
      }
    }];
    var errors = [];
    var ret = validate(children.iterator(), function (e) {
      errors.push({
        name: e.name,
        reason: e.reason,
        element: switch byName[e.name] {
          case null: None;
          case v: Some(v);
        }
      });
    });
    return switch errors {
      case []: Success(ret);
      default: Failure(Error.typed(UnprocessableEntity, 'Invalid form', { result: ret, invalid: errors }));
    }
  }
}

