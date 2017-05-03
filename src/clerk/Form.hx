package clerk;

import js.html.*;

using StringTools;
using tink.CoreApi;

@:genericBuild(clerk.macros.Build.form())
class Form<Data> {}

class FormBase {
  function process<T>(
    form:Element, 
    onError:{ name:String, reason:String, ?element:Element }->Void,
    validate:tink.querystring.Pairs<String>->Callback<{ name:String, reason:String }>->T
  ):T {

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
          // new Namedinput.name
        // case 'select':
        case 'textarea':
          var textarea:TextAreaElement = cast e;
          switch textarea.value.trim() {
            case '': continue;
            case v: new Named(textarea.name, v); 
          }
        default: continue;
      }
    }];

    return validate(children.iterator(), function (e) {
      onError({ name: e.name, reason: e.reason, element: byName[e.name] });
    });
  }
}