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
      raise 'divided by 0' if result.nil?
    end
    result
  end

  def do_operation(token)
    op2 = pop
    op1 = pop
    raise 'missing operand' if op1.nil? || op2.nil?
    result = calculate(token, op1, op2)
    push result
  end

  def get_result(token_arr)
    token_arr.each do |token|
      if operator? token
        do_operation(token)
      elsif operand? token
        push_operand(token)
      else
        raise 'bad token'
      end
    end
    pop
  end
end

require 'highline'
rpn = RPN.new
cli = HighLine.new
loop do
  input = cli.ask '> '
  result = rpn.get_result(input.split)
  puts "> #{result}"
end
