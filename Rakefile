# frozen_string_literal: true

require "yaml"

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: [:rubocop, :spec]

namespace :definitions do
  desc "Format definitions.yml"
  task :format do
    path = File.join(__dir__, "lib", "definitions.yml")
    definitions = YAML.safe_load_file(path)

    definitions.each_value do |kind|
      kind.each do |name, list|
        next if name == "with_options"

        list.sort!
      end
    end

    File.write(path, YAML.dump(definitions))
  end
end

Dir.glob(File.join("lib/tasks/**/*.rake")).each { |file| load file }
