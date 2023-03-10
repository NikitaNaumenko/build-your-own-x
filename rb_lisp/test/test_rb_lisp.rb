# frozen_string_literal: true

require "test_helper"

class TestRbLisp < Minitest::Test
  def test_parse_build_ast
    assert { ::RbLisp::Parser.parse("(+ 1 2)") == [:+, 1, 2] }
  end

  def test_parse_build_nested_ast
    assert do
      ::RbLisp::Parser.parse("(+ 1 2 (+ 3 4 (- 25 15 (* 500 400))))") == [:+, 1, 2,
                                                                          [:+, 3, 4, [:-, 25, 15, [:*, 500, 400]]]]
    end
  end
end
