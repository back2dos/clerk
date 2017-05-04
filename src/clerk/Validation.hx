package clerk;

using tink.CoreApi;

typedef Validation<T> = Outcome<T, TypedError<{ result: T, invalid:Array<Invalid> }>>;

typedef Invalid = {
  var name(default, never):String;
  var reason(default, never):String;
  var element(default, never):Option<js.html.Element>;
}