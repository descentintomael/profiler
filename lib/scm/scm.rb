# TODO: These scm methods need to take into account the current working directory when they issue shell commands
module Profiler
  class Scm
    @supported_scms = [:git]
    @@scm_type = :git
    
    def self.choose_git
      @@scm_type = :git
    end
    
    def self.untrack_file(relative_path)
      Profiler::Git.untrack_file(relative_path) if @@scm_type == :git
    end
    
    def self.retrack_file(relative_path)
      Profiler::Git.retrack_file(relative_path) if @@scm_type == :git
    end
    
    def self.changed_files
      Profiler::Git.changed_files if @@scm_type == :git
    end
    
    def self.is_git_directory?(directory)
      Profiler::Git.is_git_directory?(directory) if @@scm_type == :git
    end
  end
  
  class Git
    # TODO: Add in a means of locally ignoring files which are not in the index (probably means add it to the local ignore)
    def self.untrack_file(relative_path)
      Kernel.system("git ls-files #{relative_path} --error-unmatch &> /dev/null && git update-index --assume-unchanged #{relative_path}")
    end
    
    def self.retrack_file(relative_path)
      Kernel.system("git ls-files #{relative_path} --error-unmatch &> /dev/null && git update-index --no-assume-unchanged #{relative_path}")
    end
    
    def self.changed_files
      # Use status to get the different modified files
      files = `git status --porcelain --untracked-files=all`.split("\n")
      # Pull out the file names of all but the deleted files
      files.collect! do |f|
        st = f.split(" ")
        st[0].start_with?('D') ? nil : st.last
      end
      # Remove the nils and return
      files.compact
    end
    
    def self.is_git_directory?(dir)
      File.exists?(File.join(dir, '.git')) && File.directory?(File.join(dir, '.git'))
    end
  end
end
