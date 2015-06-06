require "lanes/spec_helper"

class CoffeeScriptProcessor < Lanes::TestCase

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
    FILE: FILE
    constructor: -> super
    squawk:->
        this.alert("Hello World!")

NS.Baz.extend(NS.Bar)

class Foo
    FILE: FILE
    constructor: ->
        this.called=true
        super
    aMethod: ->
         @squawk("howdy!")

Bar.extend(Foo)

EOS

JS=<<-EOS
(function(Lanes,Foo,_,LC,React,BS,FILE,window,undefined){
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
  Bar.prototype.FILE = FILE;

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
  Foo.prototype.FILE = FILE;

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

})(window.Lanes,(window.Lanes ? window.Lanes['Foo'] : null),window.Lanes.Vendor.ld,window.Lanes.Components,window.Lanes.Vendor.React,window.Lanes.Vendor.ReactBootstrap,{namespace:window.Lanes['Foo'],extensionName:'Foo',path:[\"foo\",\"bar\",\"baz\"]}, window);
EOS

Scope = Struct.new(:logical_path)

    def test_coffeescript_generation
        template = API::CoffeeScriptProcessor.new{ |t| SCRIPT }
        assert_equal CLEANED, template.cleaned


        assert_equal JS.chomp, template.render(Scope.new("foo/bar/baz"))
    end
end
