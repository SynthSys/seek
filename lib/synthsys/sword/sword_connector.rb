require 'sword2ruby'

module Synthsys
  module Sword


    class SwordConnector


      class Config < Struct.new(:username, :password, :uri); end

      class NotFound < RuntimeError; end

      def connect

        if !@alreadyConfigured
          read_configuration
        end


        #Define the authentication credentials for the connection
        @sword_user = Sword2Ruby::User.new(@config.username, @config.password)

        #Define the connection object using the username and password
        @connection = Sword2Ruby::Connection.new(@sword_user)

        #Get the Service Document
        @service = Atom::Service.new(@config.uri, @connection)


      end

      def findCollection(name,connection)
        connection.collections.each do |col|
          if col.title.to_s == name
            return col
          end
        end
        raise NotFound.new "Collection: #{name} not found"

      end

      def upload(file_path,title,collection_name,connection)

        collection = findCollection(collection_name,connection)
        deposit_receipt = collection.post_media!(:filepath=>file_path, :content_type=>"text/plain")
        puts "Deposited"
        deposit_receipt.entry.title = title
        deposit_receipt.entry.put!
        return deposit_receipt
      end

      def read_configuration
        if configured?
          #y = YAML.load_file(config_path)
          #@config=Config.new
          #@config.username=y[Rails.env]["username"]
          #@config.password=y[Rails.env]["password"]
          #@config.uri=y[Rails.env]["uri"]
          @config = Config.new
          @config.username = "dspacedemo+submit@gmail.com"
          @config.password = "dspace"
          @config.uri = "http://demo.dspace.org/swordv2/servicedocument"

          @alreadyConfigured = true
          return @config
        else
          raise Exception.new "No configuration file found"
        end
      end

      def configured?
        #File.exists?(config_path) && enabled_for_environment?
        true
      end


    end
  end
end


