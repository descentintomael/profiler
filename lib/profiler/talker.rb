module Profiler
  class Talker
    @@verbose = false
    @@quiet = false
    
    def self.say(msg)
      # Output unless quiet is true
      puts msg unless @@quiet
    end
    
    def self.whisper(msg)
      # Output only if verbose is true
      puts msg if @@verbose
    end
    
    def self.yell(msg)
      # Output regardless of verbosity chosen
      puts msg
    end
    
    def self.verbose=(val)
      @@verbose = val
    end
    
    def self.quiet=(val)
      @@quiet = val
    end
  end
end
