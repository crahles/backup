# encoding: utf-8

module Backup
  module Command
    class Base
      include Backup::CLI
      include Backup::Configuration::Helpers
    end
  end
end