require 'FileUtils'
module Profiler
  # Handles the data portion of the functionality
  class Data
    
    #####################
    ##  PATH METHODS
    #####################
    
    # TODO: Refactor the name of this constant to something clearer
    PROFILE_DIR = File.expand_path("~#{ENV['USER']}/.ds/")
    def self.profile_directory_path(p_name)
      File.join(PROFILE_DIR, p_name)
    end
    
    def self.remove_profile_directory(p_name)
      FileUtils.rm_rf(profile_directory_path(p_name)) if File.exists? profile_directory_path(p_name)
    end
    
    def self.create_profile_directory(p_name)
      FileUtils.mkdir_p(profile_directory_path(p_name)) unless File.exists? profile_directory_path(p_name)
    end
    
    #######################
    ## PROFILE ACESSORS
    #######################
    
    def self.current_profile(directory)
      p_file = File.join(directory, ".ds")
      # Check to make sure that it is using a profile
      return nil unless File.exists? p_file
      
      File.read(p_file)
    end
    
    def self.profile_exists?(p_name)
      File.exists? Profiler::Data.profile_directory_path(p_name)
    end
    
    
    def self.profile_files(p_name)
      # Ignore directories
      Dir.glob(File.join(Profiler::Data.profile_directory_path(p_name), "**", "*"))\
         .delete_if{|f| File.directory? f}\
         .collect{|f| f[Profiler::Data.profile_directory_path(p_name)..f.size]}
    end
    
    def self.list_profiles
      profiles = Dir.glob(File.join(PROFILE_DIR, '*')).delete_if{ |f| File.file? f }
    end
    
    #################
    ## FILE MOVING
    #################
    
    def self.copy_file(destination, source, relative_path)
      FileUtils.cp(File.join(source, relative_path), File.join(destintation, relative_path))
    end
    
    def self.copy_to_profile(p_name, source, relative_path)
      Profiler::Data.copy_file(Profiler::Data.profile_directory_path(p_name), source, relative_path)
    end
    
    def self.remove_file(directory, relative_path)
      File.delete File.join(directory, relative_path)
    end
    
    #############################
    ## VERSION CONTROL METHODS
    #############################
    
    # TODO: The git methods need to be abstracted out to a separate module for later integration with mercurial/svn/etc.
    def self.untrack_file(relative_path)
      Kernel.system("git ls-files #{relative_path} --error-unmatch &> /dev/null && git update-index --assume-unchanged #{relative_path}")
    end
    
    def self.retrack_file(relative_path)
      Kernel.system("git ls-files #{relative_path} --error-unmatch &> /dev/null && git update-index --no-assume-unchanged #{relative_path}")
    end
    
    def self.changed_files
      # Use status to get the different modified files
      files = `git status --porcelain --untracked_files=all`.split("\n")
      # Pull out the file names of all but the deleted files
      files.collect! do |f|
        st = f.split(" ")
        st[0].start_with?('D') ? nil : st.last
      end
      # Remove the nils and return
      files.compact
    end
    
    def self.is_git_directory?(directory)
      File.exists? File.join(directory, '.git') && File.directory? File.join(directory, '.git')
    end
  end
end