require 'trollop'
require 'fileutils'
require 'profiler/data'
require 'profiler/profile'
require 'profiler/talker'
require 'scm/scm'

module Profiler
  DATA_DIR = File.expand_path("~#{ENV['USER']}/.ds/")
  def self.parse_opts(args)
    opts = Trollop::options(args) do
      # TODO: Add in duplicate profile option
      opt :create, "Create a new profile"
      opt :delete, "Delete a profile"
      opt :retract, "Undo applied profile"
      opt :append, "Append profile to what is already applied", :default => true
      opt :show, "Show the files in this profile"
      opt :diff, "Show the diff between this profile's files and the current repo"
      opt :list, "Print what profile(s) are currently applied" # TODO: list/show might not be the best verbs to use here.
      opt :list_all, "List all available profiles"
      opt :dry_run, "Only print out what would happen"
      opt :verbose, "Print out everything"
      opt :quiet, "Print out nothing"
      opt :untrack, "Make source control ignore these changes", :default => true
    end
    opts.merge({:profiles => args})
  end
  
  def self.verify_opts(opts)
    Trollop::die :hg, "not yet implemented" if opts[:hg]
    Trollop::die :dry_run, "not yet implemented" if opts[:dry_run]
    
    Trollop::die "must provide at least one profile name" if opts[:profiles].empty? && !opts[:list] && !opts[:retract] && !opts[:list_all]
    
    Trollop::die :create, "only supply one profile name if you wish to create a profile" if opts[:create] && opts[:profiles].size > 1
    # I'm going to support multiple profile deletions at once until someone complains
    # Trollop::die :delete, "only supply one profile name if you wish to delete a profile" if opts[:delete] && opts[:profiles].size > 1
    
    # Check that the provided profiles exist and that one was provided if needed
    if !(opts[:create] || opts[:retract] || opts[:list] || opts[:list_all])
      Trollop::die "The selected action requires a profile name." if opts[:profiles].empty?
      
      opts[:profiles].each do |p_name|
        Trollop::die "profile #{p_name} doesn't exist, please use --list to see all available profiles" unless Profiler::Data.profile_exists? p_name
      end
    end
    
    # return the opts for chaining
    opts
  end
  
  def self.run(args=ARGV)
    Profiler::Data.working_dir = Dir.pwd
    opts = self.verify_opts(self.parse_opts(args)).freeze
    
    Profiler::Talker.verbose = opts[:verbose]
    Profiler::Talker.quiet = opts[:quiet]
    
    if opts[:create]
      # Only need to work on the first one since the opt verification doesn't allow more than one
      Profiler::Profile.create_profile(opts[:profiles].first, opts[:append])
    elsif opts[:delete]
      opts[:profiles].each do |p_name|
        # Mention that the profile is being deleted
        Profiler::Talker.say "Deleting profile #{p_name}"
        
        # Output the files quietly
        Profiler::Talker.indent
        Profiler::Data.profile_files(p_name).each do |file|
          Profiler::Talker.whisper file
        end
        Profiler::Talker.dedent
        
        Profiler::Profile.delete_profile(p_name)
      end
    elsif opts[:retract]
      Profiler::Profile.retract_profiles(opts[:profiles])
    elsif opts[:show]
      opts[:profiles].each do |p_name|
        files = Profiler::Data.profile_files(p_name)
        Profiler::Talker.say "Files for #{p_name}"
        Profiler::Talker.indent
        files.each {|f| Profiler::Talker.say f }
        Profiler::Talker.dedent
      end
    elsif opts[:list_all]
      profiles = Profiler::Data.list_profiles
      profiles.each {|p| Profiler::Talker.say p}
    elsif opts[:list]
      profiles = Profiler::Data.current_profiles
      profiles.each {|p| Profiler::Talker.say p}
    elsif opts[:diff]
      Profiler::Data.diff(opts[:profiles])
    else
      opts[:profiles].each do |p_name|
        Profiler::Profile.apply_profile(p_name, opts[:append])
      end
    end
  end
  
  
end