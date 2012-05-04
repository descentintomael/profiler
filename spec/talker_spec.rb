require 'spec_helper'

describe Profiler::Talker do
  before :each do
    Profiler::Talker.reset
    @output = StringIO.new
    Profiler::Talker.io=@output
  end
  
  context "verbose" do
    before :each do
      Profiler::Talker.verbose = true
      Profiler::Talker.quiet = false
    end

    it {Profiler::Talker.quiet?.should be_false}
    it {Profiler::Talker.verbose?.should be_true}
    
    it "should whisper" do
      Profiler::Talker.whisper("Hello, world!")
      @output.string.rstrip.should == "Hello, world!"
    end
    
    it "should say" do
      Profiler::Talker.say("Hello, world!")
      @output.string.rstrip.should == "Hello, world!"
    end
    
    it "should yell" do
      Profiler::Talker.yell("Hello, world!")
      @output.string.rstrip.should == "Hello, world!"
    end
  end
  
  context "quiet" do
    before :each do
      Profiler::Talker.quiet = true
      Profiler::Talker.verbose = false
    end
    
    it {Profiler::Talker.quiet?.should be_true}
    it {Profiler::Talker.verbose?.should be_false}
    
    it "shouldn't whisper" do
      Profiler::Talker.whisper("Hello, world!")
      @output.string.rstrip.should be_empty
    end
    
    it "shouldn't say" do
      Profiler::Talker.say("Hello, world!")
      @output.string.rstrip.should be_empty
    end
    
    it "should yell" do
      Profiler::Talker.yell("Hello, world!")
      @output.string.rstrip.should == "Hello, world!"
    end
  end
  
  context "normal" do
    before :each do
      Profiler::Talker.quiet = false
      Profiler::Talker.verbose = false
    end

    it {Profiler::Talker.quiet?.should be_false}
    it {Profiler::Talker.verbose?.should be_false}
    
    it "shouldn't whisper" do
      Profiler::Talker.whisper("Hello, world!")
      @output.string.rstrip.should be_empty
    end
    
    it "should say" do
      Profiler::Talker.say("Hello, world!")
      @output.string.rstrip.should == "Hello, world!"
    end
    
    it "should yell" do
      Profiler::Talker.yell("Hello, world!")
      @output.string.rstrip.should == "Hello, world!"
    end
  end
  
  it "should indent" do
    Profiler::Talker.indent
    Profiler::Talker.yell("Hello, world!\nAnd goodbye.")
    @output.string.rstrip.should == "\tHello, world!\n\tAnd goodbye."
  end
  
  it "should dedent" do
    # Indent twice and then dedent so we should get the same output as above
    Profiler::Talker.indent
    Profiler::Talker.indent
    Profiler::Talker.dedent
    Profiler::Talker.yell("Hello, world!\nAnd goodbye.")
    @output.string.rstrip.should == "\tHello, world!\n\tAnd goodbye."
  end
end