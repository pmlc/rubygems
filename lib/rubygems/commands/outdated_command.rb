require 'rubygems/command'
require 'rubygems/local_remote_options'
require 'rubygems/spec_fetcher'
require 'rubygems/version_option'

class Gem::Commands::OutdatedCommand < Gem::Command

  include Gem::LocalRemoteOptions
  include Gem::VersionOption

  def initialize
    super 'outdated', 'Display all gems that need updates'

    add_local_remote_options
    add_platform_option
  end

  def execute
    outdated.sort.each do |name|
      local   = Gem::Specification.find_all_by_name(name).max
      dep     = Gem::Dependency.new local.name, ">= #{local.version}"
      remotes = Gem::SpecFetcher.fetcher.fetch dep

      next if remotes.empty?

      remote = remotes.last.first
      say "#{local.name} (#{local.version} < #{remote.version})"
    end
  end

  def outdated
    outdateds = []

    fetcher = Gem::SpecFetcher.fetcher

    Gem::Specification.latest_specs.each do |local|
      dependency = Gem::Dependency.new local.name, ">= #{local.version}"
      remotes    = fetcher.find_matching dependency
      remotes    = remotes.map { |(_, version, _), _| version }
      latest     = remotes.sort.last

      outdateds << local.name if latest and local.version < latest
    end

    outdateds
  end
end
