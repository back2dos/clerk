package clerk.types;

abstract Email(String) to String {
  static var regex = ~/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i; // http://try.haxe.org/#0B65c
  @:from static function ofString(s:String):Email
    return 
      if (regex.match(s)) cast s;
      else throw 'Invalid email "$s"';
}