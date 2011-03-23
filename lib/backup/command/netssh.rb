# encoding: utf-8

##
# Only load the Net::SFTP library/gem when the Backup::Commands::SSH class is loaded
Backup::Dependency.load('net-ssh')

module Backup
  module Command
    class NetSSH < Base

      ##
      # Server credentials
      attr_accessor :username, :password

      ##
      # Server IP Address and SSH port
      attr_accessor :ip, :port

      ##
      # Creates a new instance of the Net::SSH object
      # First it sets the defaults (if any exist) and then evaluates
      # the configuration block which may overwrite these defaults
      def initialize(&block)
        load_defaults!
 
        @port ||= 22
        @commands = Array.new

        instance_eval(&block) if block_given?

        @time = TIME
      end

      ##
      # Performs the mysqldump command and outputs the
      # data to the specified path based on the 'trigger'
      def perform!
        Logger.message("#{ self.class } started executing commands.")
        @commands.each do |command|
          run_command(command)
        end
      end
      
      ##
      # Adds a command to the @commands array
      def add(command)
        @commands << command
      end
      
      ##
      # Establishes a connection to the remote server and returns the Net::SSH object.
      # Not doing any instance variable caching because this object gets persisted in YAML
      # format to a file and will issues. This, however has no impact on performance since it only
      # gets invoked once per object for a #transfer! and once for a remove! Backups run in the
      # background anyway so even if it were a bit slower it shouldn't matter.
      def connection
        Net::SSH.start(ip, username, :password => password, :port => port)
      end

      ##
      # If no block has been provided, it'll return the array of @directories.
      # If a block has been provided, it'll evaluate it and add the given command to the @commands
      def commands(&block)
        unless block_given?
          return @commands.map do |command|
            "'#{command}'"
          end.join("\s")
        end
        instance_eval(&block)
      end
      
      def run_command(command)
      # open a new channel and configure a minimal set of callbacks, then run
      # the event loop until the channel finishes (closes)
        channel = connection.open_channel do |ch|
          ch.exec "#{command}" do |ch, success|
            raise "could not execute command" unless success

            # "on_data" is called when the process writes something to stdout
            ch.on_data do |c, data|
              Logger.message(data)
            end

            # "on_extended_data" is called when the process writes something to stderr
            ch.on_extended_data do |c, type, data|
              Logger.warn(data)
            end

            ch.on_close { 
              Logger.message("Done.")
            }
          end
        end
        channel.wait
      end
    end
  end
end
