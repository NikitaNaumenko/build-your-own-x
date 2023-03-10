class RbLisp::Parser
  def self.parse(exp)
    build_ast(tokenize(exp))
  end

  def self.tokenize(exp)
    exp.gsub(/\s\s+/, " ").gsub("(", " ( ").gsub(")", " ) ").split(" ")
  end

  def self.build_ast(tokens)
    return if tokens.empty?

    token = tokens.shift

    case token
    when "("
      list = []
      list << build_ast(tokens) while tokens.first != ")"
      tokens.shift
      list
    when ")"
      raise "wrong parenteses"
    else
      build_ast_node(token)
    end
  end

  def self.build_ast_node(token)
    case token
    when "(" || ")"
      nil
    when token[/\d+/]
      token.to_i
    else
      token.to_sym
    end
  end
end
