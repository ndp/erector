require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'
require 'active_support' # for Symbol#to_proc

module ExternalsSpec

  describe "adding dependencies" do
    before do
      @args = [:what, :ever, :is, :passed]
      @result = Erector::Dependency.new :js, '/foo.js'
      @result2 = Erector::Dependency.new :css, '/foo.css'
    end

    it "calls #interpret_args with given arguments and passes result to #push_dependency" do
      mock(Erector::Widget).interpret_args(*@args).returns(@result)
      mock(Erector::Widget).push_dependency(@result)
      Erector::Widget.depends_on *@args
    end

    describe "#push_dependency" do
      class PushyWidget < Erector::Widget
      end

      it "collects the result of Dependency.new" do
        PushyWidget.send :push_dependency, @result
        PushyWidget.send :push_dependency, @result2
        PushyWidget.instance_variable_get(:@_dependencies).should == [@result, @result2]
      end
      it "collects a list of dependencies" do
        PushyWidget.send :push_dependency, @result, @result2
        PushyWidget.instance_variable_get(:@_dependencies).should == [@result, @result2]
      end

      it "collects an array of dependencies" do
        PushyWidget.send :push_dependency, [@result, @result2]
        PushyWidget.instance_variable_get(:@_dependencies).should == [@result, @result2]
      end
    end

    it "starts out with no items in @_dependencies" do
      class Quesadilla < Erector::Widget
      end
      (Quesadilla.instance_variable_get(:@_dependencies) || []).should == []
    end


    describe '#interpret_args' do

      class Test
        include Erector::Externals
      end

      it "will infer that a .js extension is javascript" do
        x = Test.send :interpret_args,('/path/to/a.js')
        x.text.should == '/path/to/a.js'
        x.type.should == :js
      end

      it "will infer that a .css extension is a stylesheet" do
        x = Test.send :interpret_args,('/path/to/a.css')
        x.text.should == '/path/to/a.css'
        x.type.should == :css
      end

      it "will capture render options when just a file is mentioned" do
        x = Test.send(:interpret_args, '/path/to/a.css', :render=>:link)
        x.text.should == '/path/to/a.css'
        x.type.should == :css
        x.options.should == {:render=>:link} # could also be "embed"
      end

      it "embeds javascript" do
        x = Test.send :interpret_args, :js, "alert('foo')"
        x.text.should == "alert('foo')"
        x.type.should == :js
      end

      it "guesses Javascript type from .js" do
        x = Test.send :interpret_args, "/script/foo.js"
        x.text.should == "/script/foo.js"
        x.type.should == :js
      end

      it "guesses CSS type from .css" do
        x = Test.send :interpret_args, "/script/foo.css"
        x.text.should == "/script/foo.css"
        x.type.should == :css
      end

      it "add multiple files without an options hash" do
        x = Test.send :interpret_args, :js, "/script/foo.js", "/script/bar.js"
        x.size.should == 2
        x[0].text.should == "/script/foo.js"
        x[0].type.should == :js
        x[1].text.should == "/script/bar.js"
        x[1].type.should == :js
      end

      it "add multiple files with an options hash" do
        x = Test.send :interpret_args, :js, "/script/foo.js", "/script/bar.js", :embed=>true
        x.size.should == 2
        x[0].text.should == "/script/foo.js"
        x[0].type.should == :js
        x[0].options[:embed].should == true
        x[1].text.should == "/script/bar.js"
        x[1].type.should == :js
        x[1].options[:embed].should == true
      end

      it "adds multiple files from hash" do
        x = Test.send :interpret_args, :js => ["foo.js", "bar.js"]
        x.size.should == 2
        x[0].text.should == "foo.js"
        x[0].type.should == :js
        x[1].text.should == "bar.js"
        x[1].type.should == :js
      end
      it "adds multiple files from hash of different types" do
        x = Test.send :interpret_args, :js => ["foo.js", "bar.js"], :css=>'file.css'
        x.size.should == 3
        x.map(&:text).include?('foo.js')
        x.map(&:text).include?('bar.js')
        x.map(&:text).include?('file.css')
      end
      it "adds multiple files from hash and preserves the options" do
        x = Test.send :interpret_args, :js => ["foo.js", "bar.js"], :foo=>false
        x.size.should == 2
        x[0].text.should == "foo.js"
        x[0].type.should == :js
        x[0].options.should == {:foo=>false}
        x[1].text.should == "bar.js"
        x[1].type.should == :js
        x[1].options.should == {:foo=>false}
      end
    end

  end

  describe 'extracting the dependencies (integration tests)' do

    class HotSauce < Erector::Widget
      depends_on :css, "/css/tapatio.css", :media => "print"
      depends_on :css, "/css/salsa_picante.css"
      depends_on :js, "/lib/jquery.js"
      depends_on :js, "/lib/picante.js"
    end

    class SourCream < Erector::Widget
      depends_on :css, "/css/sourcream.css"
      depends_on :js, "/lib/jquery.js"
      depends_on :js, "/lib/dairy.js"
    end

    class Tabasco < HotSauce
      depends_on :js, "tabasco.js"
      depends_on :css, "/css/salsa_picante.css"
    end

    it "can be fetched via the type" do
      HotSauce.dependencies(:css).map(&:text).should == [
          "/css/tapatio.css",
          "/css/salsa_picante.css",
      ]
    end

    it "can be filtered via the class" do
      SourCream.dependencies(:css).map(&:text).should == [
          "/css/sourcream.css",
      ]
    end

    it "grabs dependencies from superclasses too" do
      Tabasco.dependencies(:js).map(&:text).should == ["/lib/jquery.js", "/lib/picante.js", "tabasco.js"]
    end

    it "retains the options" do
      HotSauce.dependencies(:css).map(&:options).should == [
          {:media => "print"},
          {}
      ]
    end

    it "removes duplicates" do
      Tabasco.dependencies(:css).map(&:text).should == [
          "/css/tapatio.css",
          "/css/salsa_picante.css",
      ]
    end

    it "works with strings or symbols" do
      HotSauce.dependencies("css").map(&:text).should == [
          "/css/tapatio.css",
          "/css/salsa_picante.css",
      ]
    end

    class Taco < Erector::Widget
      depends_on :filling, "beef"
      depends_on :filling, "beef", :media => "print"
    end

    it "considers options when removing duplicates" do
      Taco.dependencies(:filling).map(&:text).should == ["beef", "beef"]
    end


  end
end
