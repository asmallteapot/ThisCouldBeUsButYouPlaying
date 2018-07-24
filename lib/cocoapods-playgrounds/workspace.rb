# frozen_string_literal: true

require 'cocoapods'
require 'cocoapods-playgrounds/playground'
require 'xcodeproj'

module Pod
  class WorkspaceGenerator
    def initialize(target_name, dependency_names, platform = :ios, deployment_target = '9.0')
      @target_name = target_name
      @target_dir = Pathname.new(@target_name)
      @dependency_names = dependency_names
      @platform = platform
      @deployment_target = deployment_target
    end

    def generate(install = true)
      @cwd = Pathname.getwd
      `rm -fr '#{@target_dir}'`
      FileUtils.mkdir_p(@target_dir)

      Dir.chdir(@target_dir) do
        setup_project(install)

        generator = Pod::PlaygroundGenerator.new(@platform, @dependency_names)
        path = generator.generate(@target_name)
      end

      `open #{workspace_path}` if install
    end

    private

    def setup_project(install = true)
      raise NotImplementedError.new("#{self.class.name}#setup_project must be overridden.")
    end

    def names
      @dependency_names.map do |name|
        if !(@cwd + name).exist? && name.include?('/')
          File.dirname(name)
        else
          File.basename(name, '.podspec')
        end
      end
    end

    def workspace_extension
      raise NotImplementedError.new("#{self.class.name}#workspace_extension must be overridden.")
    end

    def workspace_path
      @target_dir + "#{@target_name}.#{workspace_extension}"
    end

    def generate_project
      project_path = "#{@target_name}.xcodeproj"
      project = Xcodeproj::Project.new(project_path)

      target = project.new_target(:application,
                                  @target_name,
                                  @platform,
                                  @deployment_target)
      target.build_configurations.each do |config|
        config.build_settings['ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME'] = 'LaunchImage'
        config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = ''
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
        config.build_settings['DEFINES_MODULE'] = 'NO'
        config.build_settings['EMBEDDED_CONTENT_CONTAINS_SWIFT'] = 'NO'
        # TODO: define swift version correctly
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end

      # TODO: Should be at the root of the project
      project.new_file("#{@target_name}.playground")
      project.save
    end
  end
end
