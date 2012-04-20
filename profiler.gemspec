Gem::Specification.new do |s|
  s.name         = 'porfiler'
  s.version      = '0.0.1'
  s.summary      = "Create development configuration profiles"
  s.description  = "Easily apply your configuration files in a transparent way and keep them hidden from hidden from git at the same time."
  s.authors      = ["Sean Todd"]
  s.email        = 'iphone.reply@gmail.com'
  s.files        = Dir['lib/**/*.rb'] + Dir['bin/*'] # spell this out later
  s.homepage     = 'http://github.com/descentintomael/profiler'
  s.require_path = '.'
end