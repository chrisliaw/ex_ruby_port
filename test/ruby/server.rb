require 'bundler'
require 'ruby_ex_port'

module RubyTest
  class RubyServer
    def self.say(first, second)
      puts "first : #{first} / second : #{second}"
      "first : #{first} / second : #{second}"
    end
  end

  class SecondClass
    def say_some(jan)
      puts "say_some : #{jan}"
    end
  end
end

RubyExPort::PortServer.new(ARGV).start
