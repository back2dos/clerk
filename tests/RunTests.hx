package ;

import js.html.*;
import js.Browser.*;
import haxe.unit.*;
import clerk.*;
import clerk.types.*;

using tink.CoreApi;

typedef SignupData = {
  name:String,
  email:Email,
  password:MinLength<8, 'Password too short'>,
}

class RunTests extends TestCase {

  function expect<T>(div:Element, s:String, form:{ function validate(e:Element):Validation<T>; }, ?pos:haxe.PosInfos) {
    var ret = form.validate(div);
    
    assertEquals(s, switch ret {
      case Success(_): '';
      case Failure(e): [for (e in e.data.invalid) e.name].join(',');
    }, pos);

    return switch ret {
      case Success(v): v;
      case Failure(e): e.data.result;
    }
  }
  
  function test() {
    var div = document.createDivElement();
    
    div.innerHTML = '
      <form>
        <input type="text" name="name" value="John Doe" />
        <input type="email" name="email" value="john.doe@example.com" />
        <input type="password" name="password" value="12345" />
      </form>
    ';

    expect(div, 'password', new Form<SignupData>());

    div.innerHTML = '
      <form>
        <input type="text" name="name" value="John Doe" />
        <input type="email" name="email" value="john.doe" />
        <input type="password" name="password" value="12345678" />
      </form>
    ';

    expect(div, 'email', new Form<SignupData>());

    div.innerHTML = '
      <form>
        <input type="text" name="foo" value="horst" />
        <input type="text" name="bar" value="2017-05-03T14:38:02Z" />
        <input type="number" name="bar[0].barf" value="0.1234" />
        <input type="number" name="bar[0].blub" />
        <select name="lala" multiple>
          <option value="foo" selected />
          <option value="bar" selected />
          <option value="horst" selected />
        </select>
      </form>
    ';

    expect(div, '', new Form<{ foo: String, bar:Date }>());
    expect(div, 'foo', new Form<{ foo: Date, bar:String }>());
    expect(div, 'bar,foo', new Form<{ foo: Date, bar:Int }>());
    expect(div, 'bar[0].blub', new Form<{ foo: String, bar:Array<{ barf: Float, blub:String }> }>());
    assertEquals(0.1234, expect(div, '', new Form<{ foo: String, bar:Array<{ barf: Float, ?blub:String }> }>()).bar[0].barf);
  }
  
  function testEmpty() {
    var div = document.createDivElement();
    
    div.innerHTML = '
      <form>
        <input type="text" name="foo" value="John Doe" />
        <input type="text" name="bar" value="" />
        <input type="text" name="baz" />
      </form>
    ';
    expect(div, 'bar,baz', new Form<{ foo:NotEmpty, bar:NotEmpty, baz:NotEmpty }>());
  }
  
  function testRegex() {
    var div = document.createDivElement();
    
    div.innerHTML = '
      <form>
        <input type="text" name="foo" value="haxe" />
      </form>
    ';
    expect(div, '', new Form<{ foo:RegExp<~/axe/i>}>());
    expect(div, '', new Form<{ foo:RegExp<~/haxe/i>}>());
    expect(div, 'foo', new Form<{ foo:RegExp<~/js/i>}>());
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