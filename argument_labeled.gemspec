require 'rubygems'
require 'rake/gempackagetask'

VERSION = "0.1.1"

spec = Gem::Specification.new do |s|
  s.name              = "argument_labeled"
  s.summary           = 'argument_labeled comes with a bunch of convenient methods for making "named arguments" (hashes as method arguments) in Ruby less painfull'
  s.description       = s.summary
  s.version           = VERSION
  s.author            = "Nardo Nykolyszyn"
  s.email             = "nardonykolyszyn@gmail.com"
  s.date              = Time.now.strftime "%Y-%m-%d"
  s.require_path      = "lib"
  s.homepage          = "https://github.com/nardonykolyszyn/argument_labeled"

  s.required_ruby_version = '>= 1.9.1'

  s.add_development_dependency "baretest"

  s.files = FileList["bin/*", "lib/**/*.rb", "[A-Z]*", "examples/**/*"].to_a
  s.executables = [""]
end

Rake::GemPackageTask.new(spec)do |pkg|
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
  end
rescue LoadError
end

task :test do
  begin
    require "baretest"
  rescue LoadError => e
    puts "Could not run tests: #{e}"
  end

  BareTest.load_standard_test_files(
                                    :verbose => false,
                                    :setup_file => 'test/setup.rb',
                                    :chdir => File.absolute_path("#{__FILE__}/../")
                                    )

  BareTest.run(:format => "cli", :interactive => false)
end
