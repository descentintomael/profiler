require 'spec_helper'

describe Profiler::Scm do
  # NOTE: Going to place all the should_receives on the Git object since my assumption at this point is that we are using git
  
  it "should untrack a file" do
    path = 'd1/f1'
    Kernel.should_receive(:system).with("git ls-files #{path} --error-unmatch &> /dev/null && git update-index --assume-unchanged #{path}")
    Profiler::Scm.untrack_file(path)
  end
  
  it "should retrack a file" do
    path = 'd1/f1'
    Kernel.should_receive(:system).with("git ls-files #{path} --error-unmatch &> /dev/null && git update-index --no-assume-unchanged #{path}")
    Profiler::Scm.retrack_file(path)
  end
  
  it "should list all changed files" do
    paths = [" M f1","?? d2/f2","?? f3","?? d4/f4"]
    Profiler::Git.should_receive(:'`').with("git status --porcelain --untracked-files=all").and_return(paths.join("\n"))
    Profiler::Scm.changed_files.should =~ ["f1","d2/f2","f3","d4/f4"]
  end
  
  it "should not list deleted changed files" do
    paths = [" M f1","D  d2/f2","?? f3","?? d4/f4"]
    Profiler::Git.should_receive(:'`').with("git status --porcelain --untracked-files=all").and_return(paths.join("\n"))
    Profiler::Scm.changed_files.should =~ ["f1","f3","d4/f4"]
  end
  
  it "should determine if this is a git directory" do
    within_construct do |c|
      c.directory 'my_proj_dir' do |d|
        d.directory '.git'
        Profiler::Scm.is_git_directory?(d).should be_true
      end
    end
  end
end