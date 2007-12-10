require File.join(File.dirname(__FILE__), '..', 'spec_helper')
 
module SequenceSpec
  class Foo < Treetop::Runtime::SyntaxNode
  end
  
  describe "a sequence of labeled terminal symbols followed by a node class declaration and a block" do
    testing_expression 'foo:"foo" bar:"bar" baz:"baz" <SequenceSpec::Foo> { def a_method; end }'
  
    it "upon successfully matching input, instantiates an instance of the declared node class with element accessor methods and the method from the inline module" do
      parse('foobarbaz') do |result|
        result.should_not be_nil
        result.should be_an_instance_of(Foo)      
        result.should respond_to(:a_method)
        result.foo.text_value.should == 'foo'
        result.bar.text_value.should == 'bar'
        result.baz.text_value.should == 'baz'
      end
    end
    
    it "successfully matches at a non-zero index" do
      parse('---foobarbaz', :index => 3) do |result|
        result.should_not be_nil
        result.should be_nonterminal
        (result.elements.map {|elt| elt.text_value}).join.should == 'foobarbaz'
      end
    end
  
    it "fails to match non-matching input, recording the parse failure of first non-matching terminal" do
      parse('---foobazbaz', :index => 3) do |result|
        result.should be_nil
        parser.index.should == 3
        terminal_failures = parser.terminal_failures
        terminal_failures.size.should == 1
        failure = terminal_failures.first
        failure.index.should == 6
        failure.expected_string.should == 'bar'
      end
    end  
  end

  describe "a sequence of non-terminals" do
    testing_grammar %{
      grammar TestGrammar
        rule sequence
          foo bar baz {
            def baz
              'override' + super.text_value
            end
          }
        end
      
        rule foo 'foo' end
        rule bar 'bar' end
        rule baz 'baz' end
      end
    }
  
    it "defines accessors for non-terminals automatically that can be overridden in the inline block" do
      parse('foobarbaz') do |result|
        result.foo.text_value.should == 'foo'
        result.bar.text_value.should == 'bar'
        result.baz.should == 'overridebaz'
      end
    end
  end
end
