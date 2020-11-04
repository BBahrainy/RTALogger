require_relative 'lib/RTALogger/version'

Gem::Specification.new do |spec|
  spec.name          = "RTALogger"
  spec.version       = RTALogger::VERSION
  spec.authors       = ["Babak Bahreini, RTA Backend Team"]
  spec.email         = ["b.bahreini@roundtableapps.com"]


  spec.summary       = %q{An easy to use, easy to extend log manager to prepare standard log API for developers }
  spec.description   = %q{RTA Log Manager has been designed and implemented to provide standard logging API for developers.This prevents chaos in log data format. Also provide multiple extendable log repositories including wrapping existing loggers, like 'Fluentd' or implement completely new custom logger. All main features of log manager are configeable through a json config file.}
  spec.homepage      = "https://github.com/BBahrainy/RTALogger.git"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://www.rubygems.org"

  spec.metadata["homepage_uri"] = "https://github.com/BBahrainy/RTALogger.git"
  spec.metadata["source_code_uri"] = "https://github.com/BBahrainy/RTALogger.git"
  spec.metadata["changelog_uri"] = "https://github.com/BBahrainy/RTALogger.git"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "fluentd", "~> 1.11", ">= 1.11.4"
end
