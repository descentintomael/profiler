Gem::Specification.new do |s|
  s.name         = 'profiler'
  s.version      = '0.0.1'
  s.summary      = "Create development configuration profiles"
  s.description  = "Easily apply your configuration files in a transparent way and keep them hidden from hidden from git at the same time."
  s.authors      = ["Sean Todd"]
  s.email        = 'iphone.reply@gmail.com'
  s.files        = ["lib/profiler.rb",
                    "lib/trollop.rb",
                    "lib/profiler/data.rb",
                    "lib/profiler/profile.rb",
                    "lib/profiler/talker.rb",
                    "lib/scm/scm.rb",
                    "spec/data_spec.rb",
                    "spec/profiler_spec.rb",
                    "spec/scm_spec.rb",
                    "spec/spec.opts",
                    "spec/spec_helper.rb",
                    "spec/talker_spec.rb",
                    "ChangeLog.markdown",
                    "Gemfile",
                    "Gemfile.lock",
                    "LICENSE",
                    "README.markdown",
                    "Rakefile",
                    "bin/profiler",
                    "profiler.gemspec"]
  s.homepage     = 'http://github.com/descentintomael/profiler'
  s.require_path = '.'
  s.default_executable = %q{profiler}
  s.executables = ["profiler"]
end