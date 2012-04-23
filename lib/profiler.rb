require 'trollop'

class Profiler
  DATA_DIR = File.expand_path("~#{ENV['USER']}/.ds/")
  def self.parse_opts
    opts = Trollop::options do
      # TODO: Add in duplicate profile option
      opt :create, "Create a new profile"
      opt :delete, "Delete a profile"
      opt :retract, "Undo applied profile"
      opt :append, "Append profile to what is already applied"
      opt :show, "Show the files diff in this profile"
      opt :diff, "Show the diff between this profile's files and the current repo"
      opt :list, "Print what profile(s) are currently applied" # TODO: list/show might not be the best verbs to use here.
      opt :hg, "Use mercurial instead of git (NOT READY)"
      opt :dry_run, "Only print out what would happen"
      opt :verbose, "Print out everything"
      opt :quiet, "Print out nothing"
      opt :untrack, "Make source control ignore these changes", :defalt => true
    end
    opts.merge({:profiles})
  end
  
  def self.verify_opts(opts)
    Trollop::die :hg, "not yet implemented" if opts[:hg]
    Trollop::die :append, "not yet implemented" if opts[:append]
    Trollop::die :diff, "not yet implemented" if opts[:diff]
    
    Trollop::die "must provide at least one profile name" if opts[:profiles].empty? && !opts[:list] && !opts[:retract]
    
    Trollop::die :create, "only supply one profile name if you wish to create a profile" if opts[:create] && opts[:profiles].size > 1
    Trollop::die :delete, "only supply one profile name if you wish to delete a profile" if opts[:delete] && opts[:profiles].size > 1
  end
  
  def self.run
    # TODO: Add in call to create the  profile if that is the option selected
    
  end
  
  # Create a profile based off modified files in the current directory
  # If overwrite is true, it will delete the matching profile if it exists
  # If overwrite is false, it will append to the matching profile
  def self.create_profile(name, overwrite=false)
    # Remove the current profile is overwrite is false
    Profiler::Data.remove_profile_directory(name)
    # Create the profile directory
    Profiler::Data.create_profile_directory(name)
    
    Profiler::Data.changed_files.each do |f|
      Profiler::Data.copy_to_profile(name, f)
    end
  end
  
  def self.retract_last_profile
    # TODO Figure out how to safely back up the files to be changed so that this method can back out the changes
  end
  
  def self.apply_profile
    
  end
end