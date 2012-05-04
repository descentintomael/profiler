require 'spec_helper'

describe Profiler do
  context "creating a profile" do
    it "should create a profile" do
      profiles = ['p1']
      args = "--create --append=false #{profiles.join(' ')}".shellsplit
      Profiler::Profile.should_receive(:create_profile).with(profiles.first, false)
      Profiler::run(args)
    end
    
    it "should append to existing profile" do
      profiles = ['p1']
      args = "--create #{profiles.join(' ')}".shellsplit
      Profiler::Profile.should_receive(:create_profile).with(profiles.first, true)
      Profiler::run(args)
    end
    
    it "should not create a profile if no name is given" do
      args = "--create".shellsplit
      lambda {  Profiler::run(args) }.should raise_error SystemExit
    end
    
    
    it "should not create a profile if multiple names are given" do
      profiles = ['p1','p2']
      args = "--create #{profiles.join(' ')}".shellsplit
      lambda {  Profiler::run(args) }.should raise_error SystemExit
    end
  end
  
  context "viewing a profile" do
    it "should show files in profile" do
      profiles = ['p1','p2']
      args = "--show #{profiles.join(' ')}".shellsplit
      profiles.each { |p_name| Profiler::Data.should_receive(:profile_files).with(p_name).and_return(['file1']) }
      profiles.each { |p_name| Profiler::Data.should_receive(:profile_exists?).with(p_name).and_return(true) }
      
      Profiler::Talker.should_receive(:indent).twice
      Profiler::Talker.should_receive(:say).with(kind_of(String)).exactly(4).times
      Profiler::Talker.should_receive(:dedent).twice
      Profiler::run(args)
    end
    
    it "should show diff between profile and current dir" do
      profiles = ['p1','p2']
      args = "--diff #{profiles.join(' ')}".shellsplit
      
      profiles.each { |p_name| Profiler::Data.should_receive(:profile_exists?).with(p_name).and_return(true) }
      Profiler::Data.should_receive(:diff).with(profiles)
      Profiler::run(args)
    end
    
    it "should list all profiles" do
      profiles = ['p1','p2']
      args = "--list-all".shellsplit
      
      Profiler::Data.should_receive(:list_profiles).and_return(profiles)
      profiles.each {|p| Profiler::Talker.should_receive(:say).with(p) }
      Profiler::run(args)
    end
    
    it "should list applied profiles" do
      profiles = ['p1','p2']
      args = "--list".shellsplit
      
      Profiler::Data.should_receive(:current_profiles).and_return(profiles)
      profiles.each {|p| Profiler::Talker.should_receive(:say).with(p) }
      Profiler::run(args)
    end
  end
  
  context "deleting a profile" do
    it "should delete a profile that exists" do
      profiles = ['p1','p2']
      args = "--delete #{profiles.join(' ')}".shellsplit
      
      # Stub all the output stuff since it is only incidental to this functioning
      Profiler::Talker.stub(:say)
      Profiler::Talker.stub(:whisper)
      profiles.each { |p_name| Profiler::Data.should_receive(:profile_exists?).with(p_name).and_return(true) }
      profiles.each { |p_name| Profiler::Profile.should_receive(:delete_profile).with(p_name) }
      Profiler::run(args)
    end
    
    it "should error if profile doesn't exist" do
      profiles = ['p1']
      args = "--delete #{profiles.join(' ')}".shellsplit
      Profiler::Data.stub(:profile_exists?).and_return(false)
      lambda {  Profiler::run(args) }.should raise_error SystemExit
    end
    
    it "should error with no profile given" do
      args = "--delete".shellsplit
      lambda {  Profiler::run(args) }.should raise_error SystemExit
    end
  end
  
  context "applying a profile" do
    it "should apply and overwrite profiles" do
      profiles = ['p1','p2']
      args = "--append=false #{profiles.join(' ')}".shellsplit
      
      profiles.each { |p_name| Profiler::Data.should_receive(:profile_exists?).with(p_name).and_return(true) }
      profiles.each { |p_name| Profiler::Profile.should_receive(:apply_profile).with(p_name, false).and_return(true) }
      
      Profiler::run(args)
    end
    
    it "should apply and append profiles" do
      profiles = ['p1','p2']
      args = "#{profiles.join(' ')}".shellsplit
      
      profiles.each { |p_name| Profiler::Data.should_receive(:profile_exists?).with(p_name).and_return(true) }
      profiles.each { |p_name| Profiler::Profile.should_receive(:apply_profile).with(p_name, true).and_return(true) }
      
      Profiler::run(args)
    end
    
    it "should error with no profiles" do
      lambda {  Profiler::run("") }.should raise_error SystemExit
    end
    
    it "should error with non-existent profile" do
      args = "p1".shellsplit
      Profiler::Data.stub(:profile_exists?).and_return(false)
      lambda {  Profiler::run(args) }.should raise_error SystemExit
    end
  end
end
