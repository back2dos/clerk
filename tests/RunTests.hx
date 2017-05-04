package ;

import js.html.*;
import js.Browser.*;
import haxe.unit.*;
import clerk.*;

using tink.CoreApi;

abstract Password(String) to String {
  @:from static function ofString(s:String):Password 
    return 
      if (s.length < 8) throw 'password too short';
      else cast s;
}

abstract Email(String) to String {
  @:from static function ofString(s:String):Email
    return 
      if (~/[^@]+@[^@]+/.match(s)) cast s;
      else throw 'Invalid email $s';
}

typedef SignupData = {
  name:String,
  email:Email,
  password:Password
}


class RunTests extends TestCase {
  
  function test() {
    var div = document.createDivElement();

    function expect<T>(s:String, form:{ function validate(e:Element):Validation<T>; }, ?pos:haxe.PosInfos) {
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

    div.innerHTML = '
      <form>
        <input type="text" name="name" value="John Doe" />
        <input type="email" name="email" value="john.doe@example.com" />
        <input type="password" name="password" value="12345" />
      </form>
    ';

    expect('password', new Form<SignupData>());

    div.innerHTML = '
      <form>
        <input type="text" name="name" value="John Doe" />
        <input type="email" name="email" value="john.doe" />
        <input type="password" name="password" value="12345678" />
      </form>
    ';

    expect('email', new Form<SignupData>());

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

    expect('', new Form<{ foo: String, bar:Date }>());
    expect('foo', new Form<{ foo: Date, bar:String }>());
    expect('bar,foo', new Form<{ foo: Date, bar:Int }>());
    expect('bar[0].blub', new Form<{ foo: String, bar:Array<{ barf: Float, blub:String }> }>());
    assertEquals(0.1234, expect('', new Form<{ foo: String, bar:Array<{ barf: Float, ?blub:String }> }>()).bar[0].barf);
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