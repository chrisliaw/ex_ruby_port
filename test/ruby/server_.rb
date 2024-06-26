require 'bundler'
require 'erlang/etf'
require 'stringio'

module RubyExPort
  class RubyServer
    def self.say(first, second)
      puts "first : #{first} / second : #{second}"
      "first : #{first} / second : #{second}"
    end
  end
end

@input = IO.new(3)
@output = IO.new(4)
@output.sync = true
# @input = STDIN
# @output = STDOUT

def receive_input
  encoded_length = @input.read(4)
  return nil unless encoded_length

  length = encoded_length.unpack1('N')
  # @request_id, cmd = Erlang.binary_to_term(@input.read(length))
  cmd = Erlang.binary_to_term(@input.read(length))
  puts "Received command : #{cmd}"
  cmd
end

def send_response(value)
  # response = Erlang.term_to_binary(Erlang::Tuple[@request_id, value])
  response = Erlang.term_to_binary(Erlang::Tuple[Erlang::Atom['ok'], value])
  @output.write([response.bytesize].pack('N'))
  @output.write(response)
  true
end

context = binding
while (cmd = receive_input)
  puts "Ruby Command: #{cmd[0]}\r"
  # puts "command : #{cmd[1]}.send(:#{cmd[2]}, *#{cmd[3].to_a})}"
  res = if !cmd[1].nil? and !cmd[1].empty?
          eval("#{cmd[1]}.send(:#{cmd[2]}, *#{cmd[3].to_a})", context, __FILE__, __LINE__)
        else
          eval("send(:#{cmd[2]}, *#{cmd[3].to_a})", context, __FILE__, __LINE__)
        end
  # res = send(cmd[0], *cmd[1])
  # res = eval(cmd[1], context)
  puts "Eval result: #{res.inspect}\n\r"
  send_response(res)
end
puts 'Ruby: exiting'
