# Handles error when stack doesn't have enough args for operation
class MissingOperandError < StandardError
  attr_reader :operator
  def initialize(msg = 'missing operand', operator = '+')
    @operator = operator
    super(msg)
  end
end

# Handles error when unititialized variable is referenced
class UninitializedVarError < StandardError
  attr_reader :var_name
  def initialize(msg = 'uninitialized variable', var_name = '')
    @var_name = var_name
    super(msg)
  end
end

# Handles error when invalid token is parsed
class InvalidTokenError < StandardError
  attr_reader :token
  def initialize(msg = 'invalid token', token = '')
    @token = token
    super(msg)
  end
end

# Handles error when args are left on stack after evaluation
class ArgsLeftOnStackError < StandardError
  attr_reader :num
  def initialize(msg = 'args left on stack', num = '')
    @num = num
    super(msg)
  end
end

# Handles calculations for tokens in reverse polish notation
class RPN
  def initialize
    @stack = [] # Stack of operands
    @vars = {} # Case-insensitive hash of variable -> value mappings
  end

  def push(token)
    @stack.push(token)
  end

  def pop
    result = @stack.pop
    result
  end

  def count
    @stack.count
  end

  def clear
    @stack.clear
  end

  def add(op1, op2)
    result = op1 + op2
    result
  end

  def multiply(op1, op2)
    result = op1 * op2
    result
  end

  def subtract(op1, op2)
    result = op1 - op2
    result
  end

  # Returns nil if dividing by 0 (to be caught when checking result)
  def divide(op1, op2)
    begin
      result = op1 / op2
    rescue ZeroDivisionError
      result = nil
    end
    result
  end

  def valid_var_name?(string)
    regex = Regexp.new('^[a-zA-Z]{1}$')
    match = regex.match(string)
    return false if match.nil?

    match[0] == string
  end

  def add_var(name, value)
    @vars[name.downcase] = value
  end

  def get_var(name)
    result = @vars[name.downcase]
    result
  end

  def var?(name)
    @vars.key?(name.downcase)
  end

  def int?(string)
    string.to_i.to_s == string
  end

  def operator?(token)
    operators = ['+', '-', '*', '/']
    if operators.include? token
      true
    else
      false
    end
  end

  def operand?(token)
    if int?(token) || var?(token)
      true
    else
      false
    end
  end

  def push_operand(operand)
    if int? operand
      push operand.to_i
    elsif var? operand
      push get_var(operand)
    end
  end

  def calculate(token, op1, op2)
    case token
    when '+'
      result = add(op1, op2)
    when '-'
      result = subtract(op1, op2)
    when '*'
      result = multiply(op1, op2)
    when '/'
      result = divide(op1, op2)
      raise ZeroDivisionError if result.nil?
    end
    result
  end

  def do_operation(token)
    op2 = pop
    op1 = pop
    if op1.nil? || op2.nil?
      raise MissingOperandError.new('missing operand', token)
    end
    result = calculate(token, op1, op2)
    push result
  end

  def get_result(token_arr)
    token_arr.each do |token|
      if operator? token
        do_operation(token)
      elsif operand? token
        push_operand(token)
      elsif valid_var_name? token
        raise UninitializedVarError.new('uninitialized variable', token)
      else
        raise InvalidTokenError.new('invalid token', token)
      end
    end
    raise ArgsLeftOnStackError.new('args left on stack', count) if count != 1
    pop
  end
end
