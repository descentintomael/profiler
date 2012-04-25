module Profiler
  class Talker
    @@verbose = false
    @@quiet = false
    @@indent_count = 0
    
    def self.say(msg)
      # Output unless quiet is true
      puts msg_indent(msg) unless @@quiet
    end
    
    def self.whisper(msg)
      # Output only if verbose is true
      puts msg_indent(msg) if @@verbose
    end
    
    def self.yell(msg)
      # Output regardless of verbosity chosen
      puts msg_indent(msg)
    end
    
    def self.verbose=(val)
      @@verbose = val
    end
    
    def self.quiet=(val)
      @@quiet = val
    end
    
    def self.indent
      @@indent_count += 1
    end
    
    def self.dedent
      # Note, this does a little bit extra to make sure that the lowest the indent count can go is zero
      @@indent_count = [@@indent_count - 1, 0].max
    end
    
    # TODO: this needs a better name
    def self.msg_indent(msg)
      msg.split("\n").join("\n" + ("\t" * @@indent_count))
    end
  end
end
