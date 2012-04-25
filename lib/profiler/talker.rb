module Profiler
  class Talker
    @@verbose = false
    @@quiet = false
    
    def say(msg)
      # Output unless quiet is true
      puts msg unless @@quiet
    end
    
    def whisper(msg)
      # Output only if verbose is true
      puts msg if @@verbose
    end
    
    def yell(msg)
      # Output regardless of verbosity chosen
      puts msg
    end
    
    def verbose=(val)
      @@verbose = val
    end
    
    def quiet=(val)
      @@quiet = val
    end
  end
end
