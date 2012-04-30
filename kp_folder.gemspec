Gem::Specification.new do |s|
  s.name = 'kp_folder'
  s.version = '0.0.1'
  s.date = '2012-05-01'
  s.summary = "kuaipan sync folder command tool"
  s.description = "You can define folders which should be synced by 'kp' command."
  s.authors = ["tiemei"]
  s.email = 'jiadongkai@gmail.com'
  s.files = [
    "lib/kp_folder/config.rb",
    "lib/kp_folder.rb",
    "bin/kf",
    "Gemfile",
    "Gemfile.lock",
    "README.rdoc",
    "Rakefile",
    "kp_folder.gemspec",
    "test/kp_folder/test_config.rb",
    "test/test_client.rb"
    ]
  s.require_paths = ["lib"]
  s.executables << 'kp'
#s.executables << 'hola_tiemei'
  s.homepage = 'http://rubygems.org/gems/kp_folder'
  s.required_ruby_version = '>= 1.9.3'
  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency 'kuaipan', '~> 0.0.1'

end
