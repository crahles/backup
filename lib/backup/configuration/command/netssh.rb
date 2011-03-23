# encoding: utf-8

module Backup
  module Configuration
    module Command
      class NetSSH < Base
        class << self

          ##
          # Server credentials
          attr_accessor :username, :password

          ##
          # Server IP Address and SSH port
          attr_accessor :ip, :port

        end
      end
    end
  end
end
