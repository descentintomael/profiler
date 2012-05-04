
module Profiler
  # Handles the data portion of the functionality
  class Data
    @@profiler_prefix = 'ds'
    
    @@working_dir = ''
    # TODO: Refactor the name of this constant to something clearer
    @@profile_dir = File.expand_path("~#{ENV['USER']}/.#{@@profiler_prefix}/")
    #####################
    ##  ACTION METHODS
    #####################
    
    def self.diff(profiles)
      profiles = Data.list_profiles if profiles.empty?
      
      if Profiler::Talker.quiet?
        verbosity = '--brief'
      elsif !Profiler::Talker.verbose?
        verbosity = '--suppress-common-lines'
      end
      
      profiles.each do |p_name|
        Profiler::Talker.say "Differences for #{p_name}"
        Profiler::Talker.indent
        
        Profiler::Data.profile_files(p_name).each do |f|
          file_diff = `diff #{verbosity} --new-file --report-identical-files -d #{File.join(Data.profile_directory_path(p_name), f)} #{File.join(@@working_dir, f)}`
        end
        
        Profiler::Talker.dedent
      end
    end
    
    
    #####################
    ##  PATH METHODS
    #####################
    
    def self.profile_directory_path(p_name)
      File.join(@@profile_dir, p_name)
    end
    
    def self.remove_profile_directory(p_name)
      FileUtils.rm_rf(profile_directory_path(p_name)) if File.exists? profile_directory_path(p_name)
    end
    
    def self.create_profile_directory(p_name)
      FileUtils.mkdir_p(profile_directory_path(p_name)) unless File.exists? profile_directory_path(p_name)
    end
    
    def self.working_dir=(dir)
      @@working_dir = dir
    end
    
    def self.profile_dir=(dir)
      @@profile_dir = dir
    end
    
    def self.working_dir
      @@working_dir
    end
    
    def self.profile_dir
      @@profile_dir
    end
    
    def self.profiler_prefix
      @@profiler_prefix
    end
    
    #######################
    ## PROFILE ACESSORS
    #######################
    
    def self.current_profiles
      Dir.glob(File.join(@@working_dir, ".#{@@profiler_prefix}", '*'))\
         .delete_if{ |f| File.file? f }\
         .sort{ |a,b| File.ctime(a) <=> File.ctime(b) }\
         .collect{ |f| File.basename(f) }\
         .reverse
    end
    
    def self.profile_exists?(p_name)
      File.exists? Profiler::Data.profile_directory_path(p_name)
    end
    
    
    def self.profile_files(p_name)
      # Ignore directories
      Dir.glob(File.join(Profiler::Data.profile_directory_path(p_name), "**", "*"), File::FNM_DOTMATCH)\
         .delete_if{|f| File.directory? f}\
         .collect{|f| f[(Profiler::Data.profile_directory_path(p_name).to_s.size + 1) .. f.size]}
    end
    
    def self.list_profiles
      Dir.glob(File.join(@@profile_dir, '*')).delete_if{ |f| File.file? f }.collect{ |f| f[@@profile_dir.length .. f.size] }
    end
    
    def self.backed_up_files(p_name)
      working_profile_path = File.join(@@working_dir, ".#{@@profiler_prefix}", p_name).to_s
      Dir.glob(File.join(working_profile_path, "**", "*"))\
         .delete_if{ |f| File.directory? f }\
         .collect{ |f| f[(working_profile_path.size + 1) .. f.size] }
    end
    
    #################
    ## FILE MOVING
    #################
    
    # TODO: it should be source, destination to be more UNIX-y
    def self.copy_file(destination, source, relative_path)
      FileUtils.mkdir_p(File.dirname(File.join(destination, relative_path)))
      FileUtils.cp(File.join(source, relative_path), File.join(destination, relative_path))
    end
    
    def self.remove_file(directory, relative_path)
      File.delete File.join(directory, relative_path)
    end
    
    def self.copy_to_profile(p_name, relative_path)
      Profiler::Data.copy_file(Profiler::Data.profile_directory_path(p_name), @@working_dir, relative_path)
    end
    
    def self.copy_to_project(p_name, relative_path)
      Profiler::Data.copy_file(@@working_dir, Profiler::Data.profile_directory_path(p_name), relative_path)
      Scm.untrack_file(relative_path)
    end
    
    def self.remove_from_project(p_name, relative_path)
      Profiler::Data.remove_file(@@working_dir, relative_path)
      Profiler::Data.restore_file(p_name, relative_path)
      Scm.retrack_file(relative_path)
    end
    
    def self.backup_file(p_name, relative_path)
      # TODO: Figure out how to backup versions
      FileUtils.mkdir_p(File.join(@@working_dir, ".#{@@profiler_prefix}", p_name)) unless File.exists? File.join(@@working_dir, ".#{@@profiler_prefix}", p_name)
      Profiler::Data.copy_file(File.join(@@working_dir, ".#{@@profiler_prefix}", p_name), @@working_dir, relative_path) if File.exists? File.join(@@working_dir, relative_path)
    end
    
    def self.restore_file(p_name, relative_path)
      Profiler::Data.copy_file(@@working_dir, File.join(@@working_dir, ".#{@@profiler_prefix}", p_name), relative_path)
    end
    
  end
end