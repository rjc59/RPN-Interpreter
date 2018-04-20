require_relative 'rpn_calc'
require 'highline'

rpn = RPN.new
if ARGV.count.zero?
  cli = HighLine.new
  line = 1
  loop do
    begin
      input = cli.ask '> '
    rescue Interrupt
      puts
      exit(5)
    end
    if input == ''
      line += 1
      next
    end
    input = input.split
    keyword = input[0].downcase
    var_name = ''
    exit if keyword == 'quit'
    if keyword == 'let'
      var_name = input[1]
      unless rpn.valid_var_name? var_name
        puts "Line #{line}: Invalid variable name"
        line += 1
        next
      end
      input = input.drop(2)
    elsif keyword == 'print'
      input = input.drop(1)
    elsif !(rpn.int? keyword) && !(rpn.var? keyword)
      puts "Line #{line}: Unknown keyword #{keyword}"
      line += 1
      next
    end
    begin
      result = rpn.get_result(input)
      rpn.add_var(var_name, result) unless var_name == '' || !rpn.count.zero?
    rescue MissingOperandError => err
      result = "Line #{line}: Operator #{err.operator} applied to empty stack"
    rescue ZeroDivisionError
      result = "Line #{line}: Attempted division by 0"
    rescue UninitializedVarError => err
      result = "Line #{line}: Variable #{err.var_name} is not initialized"
    rescue InvalidTokenError => err
      result = "Line #{line}: Invalid token #{err.token}"
    rescue ArgsLeftOnStackError => err
      result = "Line #{line}: #{err.num} elements in stack after evaluation"
      rpn.clear
    end
    puts result.to_s
    line += 1
  end
else
  line = 1
  ARGV.each do |file_name|
    begin
      text = File.open(file_name).read
    rescue Errno::ENOENT
      puts "File not found or error reading file: #{file_name}"
      exit(5)
    end
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |file_line|
      input = file_line.chomp
      if input == ''
        line += 1
        next
      end
      input = input.split
      keyword = input[0].downcase
      var_name = ''
      to_print = false
      exit if keyword == 'quit'
      if keyword == 'let'
        var_name = input[1]
        unless rpn.valid_var_name? var_name
          puts "Line #{line}: Invalid variable name"
          exit(5)
        end
        input = input.drop(2)
      elsif keyword == 'print'
        input = input.drop(1)
        to_print = true
      elsif !(rpn.int? keyword) && !(rpn.var? keyword)
        puts "Line #{line}: Unknown keyword #{keyword}"
        exit(4)
      end
      begin
        result = rpn.get_result(input)
        rpn.add_var(var_name, result) unless var_name == '' || !rpn.count.zero?
      rescue MissingOperandError => err
        puts "Line #{line}: Operator #{err.operator} applied to empty stack"
        exit(2)
      rescue ZeroDivisionError
        puts "Line #{line}: Attempted division by 0"
        exit(5)
      rescue UninitializedVarError => err
        puts "Line #{line}: Variable #{err.var_name} is not initialized"
        exit(1)
      rescue InvalidTokenError => err
        puts "Line #{line}: Invalid token #{err.token}"
        exit(5)
      rescue ArgsLeftOnStackError => err
        puts "Line #{line}: #{err.num} elements in stack after evaluation"
        exit(3)
      end
      puts result.to_s if to_print
      line += 1
    end
  end
end
