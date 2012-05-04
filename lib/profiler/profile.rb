module Profiler
  class Profile
    # Create a profile based off modified files in the current directory
    # If append is true, it will append to the matching profile
    # If append is false, it will delete the current profile if one exists
    def self.create_profile(p_name, append=true)
      Profiler::Talker.say "Creating profile #{p_name} from changed files" unless append
      Profiler::Talker.say "Appending changed files to profile #{p_name}" if append

      # Remove the current profile is append is false
      Profiler::Data.remove_profile_directory(p_name) unless append
      # Create the profile directory (won't do anything if it already exists)
      Profiler::Data.create_profile_directory(p_name)

      Profiler::Scm.changed_files.each do |f|
        Profiler::Talker.whisper "Adding file #{relative_path} to profile #{p_name}"
        Profiler::Data.copy_to_profile(p_name, f)
      end
    end

    def self.retract_profile(p_name)
      Profiler::Talker.say "Retracting profile #{p_name}"
      Profiler::Data.backed_up_files(p_name).each do |relative_path|
        Profiler::Talker.whisper "Restoring file #{relative_path} from profile #{p_name}"
        Profiler::Data.remove_from_project(p_name, relative_path)
      end
    end
    
    def self.retract_profiles(p_names = nil)
      if p_names
        Profiler::Talker.whisper "Profiles #{p_names.join(',')} will be retracted"
        # Sort the profiles based off of time of application
        applied_profiles = Profiler::Data.current_profiles
        p_names.sort!{ |a,b| applied_profiles.index(a) <=> applied_profiles.index(b) }
      else
        Profiler::Talker.whisper "All applied profiles will be retracted"
        p_names = Profiler::Data.current_profiles
      end
      p_names.each do |p_name|
        Profiler::Profile.retract_profile(p_name)
      end
    end

    def self.apply_profile(p_name, append=true)
      Profiler::Profile.retract_all_profiles unless append
      
      # Don't re-apply a profile if it is already applied
      if Profiler::Data.current_profiles.include?(p_name)
        Talker.say "Profile #{p_name} is already applied, skipping"
        return
      end
      
      Profiler::Talker.say "Applying profile #{p_name}"
      Profiler::Data.profile_files(p_name).each do |relative_path|
        Profiler::Talker.whisper "Applying file #{relative_path} from profile #{p_name}"
        Profiler::Data.copy_to_project(p_name, relative_path)
      end
    end
    
    def self.delete_profile(p_name)
      Talker.say "Deleting profile #{p_name} from your stored profiles"
      Profiler::Data.remove_profile_directory(p_name)
    end
  end
end