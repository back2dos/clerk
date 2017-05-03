package ;

import js.html.*;
import js.Browser.*;
import haxe.unit.*;

using tink.CoreApi;

class RunTests extends TestCase {
  
  function test() {

    var div = document.createDivElement();

    div.innerHTML = '
      <form>
        <input type="text" name="foo" value="horst" />
        <input type="text" name="bar" value="2017-05-03T14:38:02Z" />
        <input type="number" name="bar[0].barf" value="0.1234" />
        <input type="number" name="bar[0].blub" />
      </form>
    ';

    var log = [];
    function add(e)
      log.push(e.name);

    function expect(s:String, ?pos:haxe.PosInfos) {
      assertEquals(s, log.join(','));
      log = [];
    }

    new clerk.Form<{ foo: String, bar:Date }>().validate(div, add);
    expect('');
    new clerk.Form<{ foo: Date, bar:String }>().validate(div, add);
    expect('foo');
    new clerk.Form<{ foo: Date, bar:Int }>().validate(div, add);
    expect('bar,foo');
    new clerk.Form<{ foo: String, bar:Array<{ barf: Float, blub:String }> }>().validate(div, add);
    expect('bar[0].blub');
    assertEquals(0.1234, new clerk.Form<{ foo: String, bar:Array<{ barf: Float, ?blub:String }> }>().validate(div, add).bar[0].barf);
    expect('');
    // trace(untyped div.firstElementChild.children[1].value);
  }

  static function main() {
    var runner = new TestRunner();
    runner.add(new RunTests());
    travix.Logger.exit(
      if (runner.run()) 0
      else 500
    );

  }
  
}