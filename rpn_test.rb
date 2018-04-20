require 'simplecov'
SimpleCov.start

require 'minitest/autorun'

require_relative 'rpn_calc'

class RPNTest < Minitest::Test
  def setup
    @rpn = RPN::new()
  end

  # Test that pushing a token to the stack works
  def test_push
    token = 1
    @rpn.push(token)
    assert_equal 1, @rpn.pop
  end

  # Test that popping from an empty stack returns nil
  def test_pop_empty
    assert_nil @rpn.pop
  end

  # Test that empty stack is empty
  def test_empty
    assert_equal 0, @rpn.count
  end

  # Test clearing the stack with one item in it
  def test_clear
    token = 1
    @rpn.push(token)
    @rpn.clear
    assert_equal 0, @rpn.count
  end

  # Test adding two ints
  def test_add
    assert_equal 20, @rpn.add(10, 10)
  end

  # Test subtracting two ints
  def test_subtract
    assert_equal -1, @rpn.subtract(0, 1)
  end

  # Test multiplying two ints
  def test_multiply
    assert_equal -10, @rpn.multiply(10, -1)
  end

  # Test dividing by 0 returns nil
  def test_divide_zero
    assert_nil @rpn.divide(1, 0)
  end

  # Test checking that var name is valid
  def test_valid_var_name
    assert @rpn.valid_var_name?("h")
  end

  # Test checking detection of invalid var name
  def test_invalid_var_name
    refute @rpn.valid_var_name?("h3ll0")
  end

  # Test adding a variable
  def test_add_var
    @rpn.add_var("X", 10)
    assert_equal 10, @rpn.get_var("X")
  end

  # Test that var is added in case insensitive way
  def test_add_var_insensitive
    @rpn.add_var("V", 10)
    assert_equal 10, @rpn.get_var("v")
  end

  # Test getting var that doesn't exist returns nil
  def test_get_var_nil
    assert_nil @rpn.get_var("Y")
  end

  # Test checking if var exists
  def test_var?
    @rpn.add_var("X", 10)
    assert @rpn.var?("X")
  end

  # Test checking if string is string representation of an int
  def test_int?
    assert @rpn.int?("1000")
  end

  # Test detection of string that's not string representation of an int
  def test_int_invalid
    refute @rpn.int?("10hello")
  end

  # Test that token can be identified as operator
  def test_operator?
    assert @rpn.operator?("+")
  end

  # Test that int can be identified as operand
  def test_operand_int
    assert @rpn.operand?("1000")
  end

  # Test that var can be identified as operand
  def test_operand_var
    @rpn.add_var("X", 10)
    assert @rpn.operand?("X")
  end

  # Test that non-existent var name isn't an operand
  def test_operand_invalid
    refute @rpn.operand?("b")
  end

  # Test that pushing integer operand pushes it as an int
  def test_push_operand_int
    @rpn.push_operand("1000")
    assert_equal 1000, @rpn.pop
  end

  # Test that pushing var operand pushes the value of that variable
  def test_push_operand_var
    @rpn.add_var("X", 10)
    @rpn.push_operand("X")
    assert_equal 10, @rpn.pop
  end

  # Test that calculating with different tokens works
  def test_calculate
    assert_equal 20, @rpn.calculate('+', 10, 10)
    assert_equal 0, @rpn.calculate('-', 10, 10)
    assert_equal 100, @rpn.calculate('*', 10, 10)
    assert_equal 1, @rpn.calculate('/', 10, 10)
  end

  # Test that do_operation raises exception if there aren't two operands on the stack
  def test_do_operation_nil_oper
    @rpn.push(10)
    assert_raises('missing operand') { @rpn.do_operation('+') }
  end

  # Test evaluation of expression as array of tokens
  def test_get_result
    token_arr = ['3', '4', '5', '*', '-']
    assert_equal -17, @rpn.get_result(token_arr)
  end

  # Test evaluation of expression as array of tokens with vars
  def test_get_result_vars
    @rpn.add_var("a", 3)
    @rpn.add_var("b", 4)
    @rpn.add_var("c", 5)
    token_arr = ['a', 'b', 'c', '*', '-']
    assert_equal -17, @rpn.get_result(token_arr)
  end
end
