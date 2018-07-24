# frozen_string_literal: true

require 'xcodeproj'

module Pod
  class Command
    class Playgrounds < Command
      DEFAULT_PLATFORM_NAME = :ios

      self.summary = 'Generates a Swift Playground for any Pod.'

      self.description = <<-DESC
        Generates a Swift Playground for any Pod.
      DESC

      self.arguments = [CLAide::Argument.new('PODS', true)]

      def self.options
        [
          ['--no-install', 'Skip running `pod install`'],
          ['--name', 'Name of the playground to generate'],
          ['--platform', "Platform to generate for (default: #{DEFAULT_PLATFORM_NAME})"],
          ['--platform_version', 'Platform version to generate for ' \
            "(default: #{default_version_for_platform(DEFAULT_PLATFORM_NAME)})"]
        ]
      end

      def self.default_version_for_platform(platform)
        Xcodeproj::Constants.const_get("LAST_KNOWN_#{platform.upcase}_SDK")
      end

      def initialize(argv)
        arg = argv.shift_argument
        @dependency_names = arg.split(',') if arg
        @target_name = argv.option('name', "#{@dependency_names.first}Playground")
        @install = argv.flag?('install', true)
        @platform = argv.option('platform', DEFAULT_PLATFORM_NAME).to_sym
        @platform_version = argv.option('platform_version', Playgrounds.default_version_for_platform(@platform))
        super
      end

      def validate!
        super
        help! 'At least one Pod name is required.' unless @dependency_names
      end

      def run
        # TODO: Pass platform and deployment target from configuration
        generator = Pod::CocoaPodsGenerator.new(@target_name, @dependency_names, @platform, @platform_version)
        generator.generate(@install)
      end
    end
  end
end
