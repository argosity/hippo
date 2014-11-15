require_relative "../spec_helper"

class JavascriptProcessorTest < Lanes::TestCase

SCRIPT = <<-EOS
class NS.Baz
    constructor: ->
        alert("foo")
    alert: (msg)->
        alert(msg);

class NS.Bar extends NS.Baz
    squawk:->
        this.alert("Hello World!")

class Foo extends Bar
    constructor: ->
        this.called=true
        super
    aMethod: ->
         @squawk("howdy!")

EOS

CLEANED=<<-EOS
class NS.Baz
    constructor: ->
        alert("foo")
    alert: (msg)->
        alert(msg);

class NS.Bar
    constructor: -> super
    squawk:->
        this.alert("Hello World!")

NS.Baz.extend(NS.Bar)

class Foo
    constructor: ->
        this.called=true
        super
    aMethod: ->
         @squawk("howdy!")

Bar.extend(Foo)

EOS

JS=<<-EOS
(function(Lanes, _, window, undefined) {
var Foo;

NS.Baz = (function() {
  function Baz() {
    alert("foo");
  }

  Baz.prototype.alert = function(msg) {
    return alert(msg);
  };

  return Baz;

})();

NS.Bar = (function() {
  function Bar() {
    Bar.__super__.constructor.apply(this, arguments);
  }

  Bar.prototype.squawk = function() {
    return this.alert("Hello World!");
  };

  return Bar;

})();

NS.Baz.extend(NS.Bar);

Foo = (function() {
  function Foo() {
    this.called = true;
    Foo.__super__.constructor.apply(this, arguments);
  }

  Foo.prototype.aMethod = function() {
    return this.squawk("howdy!");
  };

  return Foo;

})();

Bar.extend(Foo);

})(window.Lanes, window._, window);
EOS


    def test_coffeescript_generation
        template = API::CoffeeScriptWrapper.new{ |t| SCRIPT }
        assert_equal CLEANED, template.cleaned
        assert_equal JS.chomp, template.render
    end
end
