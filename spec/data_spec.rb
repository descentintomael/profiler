require 'spec_helper'

describe Profiler::Data do
  before :each do
    # Create the working directory
    @working_dir = create_construct
    Profiler::Data.working_dir = @working_dir
    # Create the profile directory
    @ds_dir = create_construct
    Profiler::Data.profile_dir = @ds_dir
  end
  
  context "Profiler::Data#diff" do
    # OPTIMIZE: I don't like that it is including the whole diff string here.  Should just check for the paths and the verbosity argument.
    before :all do
      @profiles = ['p1','p2']
    end
    
    before :each do
      @profiles.each { |p_name| Profiler::Talker.should_receive(:say).with("Differences for #{p_name}") }
      Profiler::Data.stub(:profile_files).and_return(["f1"])
      Profiler::Talker.should_receive(:indent).twice
      Profiler::Talker.should_receive(:dedent).twice
      Profiler::Data.should_not_receive(:list_profiles)
    end
    
    it "should print out a diff quietly" do
      Profiler::Talker.stub(:quiet?).and_return(true)
      @profiles.each { |p_name| Profiler::Data.should_receive(:'`').with("diff --brief --new-file --report-identical-files -d #{File.join(@ds_dir, p_name, 'f1')} #{File.join(@working_dir, 'f1')}") }
      Profiler::Data.diff(@profiles)
    end
    
    it "should print out a verbose diff" do
      Profiler::Talker.stub(:quiet?).and_return(false)
      Profiler::Talker.stub(:verbose?).and_return(true)
      @profiles.each { |p_name| Profiler::Data.should_receive(:'`').with("diff  --new-file --report-identical-files -d #{File.join(@ds_dir, p_name, 'f1')} #{File.join(@working_dir, 'f1')}") }
      Profiler::Data.diff(@profiles)
    end
    
    it "should print out a regular diff" do
      Profiler::Talker.stub(:quiet?).and_return(false)
      Profiler::Talker.stub(:verbose?).and_return(false)
      @profiles.each { |p_name| Profiler::Data.should_receive(:'`').with("diff --suppress-common-lines --new-file --report-identical-files -d #{File.join(@ds_dir, p_name, 'f1')} #{File.join(@working_dir, 'f1')}") }
      Profiler::Data.diff(@profiles)
    end
    
  end
  
  context "Returning directory paths" do
    it "should return profile path" do
      p_name = "p1"
      @ds_dir.directory 'p1' do |d|
        Profiler::Data.profile_directory_path(p_name).should == File.join(@ds_dir, p_name)
      end
    end
    
    it "should return root profile path" do
      Profiler::Data.profile_dir.should == @ds_dir
    end
    
    it "should return working directory" do
      Profiler::Data.working_dir.should == @working_dir
    end
  end
  
  context "creating and deleting profiles" do
    it "should create profile directory if it doesn't exist" do
      p_name = "p1"
      @ds_dir.directory 'p1' do |d|
        FileUtils.should_not_receive(:mkdir_p)
        Profiler::Data.create_profile_directory(p_name)
      end
    end 

    it "shouldn't create profile directory if it exists" do
      p_name = "p1"
      FileUtils.should_receive(:mkdir_p).with(File.join(@ds_dir, p_name))
      Profiler::Data.create_profile_directory(p_name)
    end 
    
    it "should delete a profile directory" do
      p_name = "p1"
      @ds_dir.directory 'p1' do |d|
      FileUtils.should_receive(:rm_rf).with(File.join(@ds_dir, p_name))
        Profiler::Data.remove_profile_directory(p_name)
      end
    end
    
    it "should verify profile existence" do
      p_name = "p1"
      @ds_dir.directory 'p1' do |d|
        FileUtils.should_not_receive(:mkdir_p)
        Profiler::Data.profile_exists?(p_name).should be_true
      end
    end
  end
  
  context "showing profile files" do
    before :each do
      @profiles = ['p1', 'p2']
      @files = ["f1","d2/f2"]
      @profiles.each do |p_name|
        FileUtils.mkdir_p(File.join(@working_dir, ".ds", p_name))
        FileUtils.mkdir_p(File.join(@ds_dir, p_name))
        @files.each do |f|
          f_path = File.join(@working_dir, ".ds", p_name, f)
          FileUtils.mkdir_p(File.dirname(f_path))
          FileUtils.touch(f_path)
          
          f_path = File.join(@ds_dir, p_name, f)
          FileUtils.mkdir_p(File.dirname(f_path))
          FileUtils.touch(f_path)
        end
      end
    end
    
    it "should list profiles applied" do
      Profiler::Data.current_profiles.should =~ @profiles
    end
    
    it "should list profile files" do
      @profiles.each { |p_name| Profiler::Data.profile_files(p_name).should =~ @files }
    end
    
    it "should list backed up files" do
      @profiles.each { |p_name| Profiler::Data.backed_up_files(p_name).should =~ @files }
    end
  end
  
  context "moving files" do
    before :each do
      # Create profile and a file inside it
      @profile = 'p1'
      @profile_file = 'd1/f1'
      @profile_path = File.join(@ds_dir, @profile)
      # Add in a file
      f_path = File.join(@profile_path, @profile_file)
      FileUtils.mkdir_p(File.dirname(f_path))
      FileUtils.touch(f_path)
      
      # Create a file in the working directory
      @working_file = 'd2/f2'
      @working_filepath = File.join(@working_dir, @working_file)
      FileUtils.mkdir_p(File.dirname(@working_filepath))
      FileUtils.touch(@working_filepath)
    end
    
    it "should copy a file" do
      # TODO: Add in alternate case for when the source file doesn't exist or the destination already exists
      # Where to copy to
      project_file_path = File.join(@working_dir, @profile_file)
      # It should create the directory if it doesn't exist
      FileUtils.should_receive(:mkdir_p).with(File.dirname(project_file_path))
      # It should copy the file over
      FileUtils.should_receive(:cp).with(File.join(@profile_path, @profile_file), project_file_path)
      Profiler::Data.copy_file(@working_dir, @profile_path, @profile_file)
    end
    
    it "should remove a file" do
      File.should_receive(:delete).with(File.join(@profile_path, @profile_file))
      Profiler::Data.remove_file(@profile_path, @profile_file)
    end
    
    it "should copy a file to the profile" do
      Profiler::Data.should_receive(:copy_file).with(@profile_path, @working_dir, @working_file)
      Profiler::Data.copy_to_profile(@profile, @working_file)
    end
    
    it "should copy a file to the working directory" do
      Profiler::Data.should_receive(:copy_file).with(@working_dir, @profile_path, @profile_file)
      Profiler::Scm.should_receive(:untrack_file).with(@profile_file)
      Profiler::Data.copy_to_project(@profile, @profile_file)
    end
    
    it "should backup a copy of the file" do
      # TODO: Add in alternate cases for when the directory exists and when the file doesn't exist
      FileUtils.should_receive(:mkdir_p).with(File.join(@working_dir, ".ds", @profile)) # It should make the backup dir if it doesn't exist
      Profiler::Data.should_receive(:copy_file).with(File.join(@working_dir, ".ds", @profile), @working_dir, @working_file) # It should call copy file if the file exists
      Profiler::Data.backup_file(@profile, @working_file)
    end
    
    it "should restore the file" do
      Profiler::Data.should_receive(:copy_file).with(@working_dir, File.join(@working_dir, ".ds", @profile), @working_file)
      Profiler::Data.restore_file(@profile, @working_file)
    end
  end
  
  after :each do
    @working_dir.destroy!
    @ds_dir.destroy!
  end
end