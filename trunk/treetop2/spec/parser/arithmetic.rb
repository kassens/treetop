class Arithmetic < CompiledParser

  def parse(input)
    prepare_to_parse(input)
    return _nt_additive
  end
  
  node_classes[:additive_0] = Class.new(SequenceSyntaxNode)
  node_classes[:additive_0].class_eval do
    def value
      arg_1.value + arg_2.value
    end
    
    def arg_1
      elements[0]
    end
    
    def arg_2
      elements[2]
    end
  end
  
  node_classes[:additive_1] = Class.new(TerminalSyntaxNode)
  
  def _nt_additive
    e0 = lambda do 
      start_index_0 = index
      
      r = nil
      e1 = lambda { self._nt_number }
      e2 = lambda { parse_terminal('+', self.class.node_classes[:additive_1]) }
      e3 = lambda { self._nt_additive }
      
      results = []

      results << (r = e1.call)
      return parse_failure(start_index_0, results) if r.failure?

      results << (r = e2.call)
      return parse_failure(start_index_0, results) if r.failure?

      results << (r = e3.call)
      return parse_failure(start_index_0, results) if r.failure?

      self.class.node_classes[:additive_0].new(input, start_index_0...index, results)
    end
    
    e4 = lambda { self._nt_number }
        
    failed_results = []
    r = e0.call
    if r.success?
      return r
    else
      failed_results << r
      r = e4.call
      if r.success?
        r.update_nested_failures(failed_results)
        return r
      else
        ParseFailure.new(failed_results)
      end
    end
  end
  
  node_classes[:number_0] = Class.new(SequenceSyntaxNode)
  node_classes[:number_0].class_eval do
    def value
      text_value.to_i
    end
  end
  node_classes[:number_1] = Class.new(TerminalSyntaxNode)
  node_classes[:number_2] = Class.new(TerminalSyntaxNode)
  node_classes[:number_3] = Class.new(SequenceSyntaxNode)
  
  def _nt_number
    start_index_0 = index
    
    e0 = exp[:e0] ||= lambda { parse_char_class('1-9', self.class.node_classes[:number_1]) }
    e1 = exp[:e1] = lambda do
      start_index_1 = index
      e2 =  lambda { parse_char_class('0-9', self.class.node_classes[:number_2]) }
      results = []
      while true
        results << (r = e2.call)
        return self.class.node_classes[:number_3].new(input, start_index_1...index, results) if r.failure?
      end
    end
    
    results = []
    
    results << (r = e0.call)
    return parse_failure(start_index_0, results) if r.failure?

    results << (r = e1.call)
    return parse_failure(start_index_0, results) if r.failure?
    
    self.class.node_classes[:number_0].new(input, start_index_0...index, results)
  end
  
  protected
  attr_reader :s
  
end