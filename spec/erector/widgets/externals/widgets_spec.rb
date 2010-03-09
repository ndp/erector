require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module Erector
  module Widgets
    module Externals
      describe JavascriptUsage do
        subject {JavascriptUsage.new :src=>"/dinner.js"}

        its(:to_s) {should == '<script src="/dinner.js" type="text/javascript"></script>'}

        it 'should equal one created with same options' do
          (subject == JavascriptUsage.new(:src=>"/dinner.js")).should == true
        end
        it 'should not equal one created with extra options' do
          (subject == JavascriptUsage.new(:src=>"/dinner.js", :options=>{:use_cdn=>true})).should == false
        end
        it 'should not equal one created with different path' do
          (subject == JavascriptUsage.new(:src=>"/lunch.js")).should == false
        end
        it 'should not equal StylesheetUsage with same file' do
          (subject == StylesheetUsage.new(:href=>"/dinner.js")).should == false
        end
      end

      describe StylesheetUsage do
        describe 'render with default options' do
          subject {StylesheetUsage.new :href=>"/css/tapatio.css"}
          its(:to_s) {should == '<link href="/css/tapatio.css" media="all" rel="stylesheet" type="text/css" />'}

          it 'should equal one created with same parameters' do
            (subject == StylesheetUsage.new(:href=>"/css/tapatio.css")).should == true
          end
          it 'should not equal one created with different name' do
            (subject == StylesheetUsage.new(:href=>"/css/salmon.css")).should == false
          end
          it 'should not equal one created with extra params' do
            (subject == StylesheetUsage.new(:href=>"/css/tapatio.css", :media=>'audio')).should == false
          end
        end

        describe 'render with media type' do
          subject {StylesheetUsage.new :href=>"/css/tapatio.css", :media => "print"}
          its(:to_s) {should == '<link href="/css/tapatio.css" media="print" rel="stylesheet" type="text/css" />'}
        end

      end
      describe JavascriptEmbed do
        subject {JavascriptEmbed.new :body=>'alert("works!");'}

        its(:to_s) {should == '<script type="text/javascript">alert("works!");</script>'}
      end

      describe StylesheetEmbed do
        subject {StylesheetEmbed.new :body=>'.red { color: blue }'}
        its(:to_s) {should == '<style type="text/css">.red { color: blue }</style>'}
      end

    end
  end
end
