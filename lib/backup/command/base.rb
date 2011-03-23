# encoding: utf-8

module Backup
  module Commands
    class Base
      include Backup::CLI
      include Backup::Configuration::Helpers
    end
  end
end