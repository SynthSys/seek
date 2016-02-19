
module Synthsys
  module Dspace

    class DspaceUploaderConnector

      class Config < Struct.new(:uri); end

      class DepositError < RuntimeError; end

      def deposit(dataSharePack)
        read_configuration unless @alreadyConfigured

        poster = Synthsys::Dspace::Poster.new

        deposit = prepare_deposit(dataSharePack)

        response = poster.post(@config.uri,deposit.to_json)

        case response
          when Net::HTTPSuccess then
            return true
          when Net::HTTPResonse then
            msg = 'Deposit failed'
            if response.body_permitted?
              msg = "Deposit failed:\n #{response.body}"
            end
            raise DepositError.new msg
          else
            msg = "Deposit failed, unknown response #{response}"
            raise DepositError.new msg
        end

      end

      def prepare_deposit(dataSharePack)

        deposit = {
            collection: dataSharePack.collection,

            title: dataSharePack.title,
            description: dataSharePack.description,
            funder: dataSharePack.funder,
            depositor: dataSharePack.depositor,
            publisher: dataSharePack.publisher,
            creators: dataSharePack.creators,
            keywords: dataSharePack.keywords,
            subject: dataSharePack.subject,
            toc: dataSharePack.toc,
            licence: dataSharePack.license,
            type: "Dataset"
        }

        #TODO deal with source link and dates
        #public String source;
        #public String createdAtStr;
        #public String updatedAtStr;

        deposit[:filePath] = prepareDataPackage(dataSharePack)
        deposit[:fileType] = 'application/zip'
        deposit[:fileName] = makeDepositFileName(dataSharePack)
        return deposit

      end

      def prepareDataPackage(dataSharePack)
        content = dataSharePack.snapshot.content_blob
        if content == nil
          raise Exception.new "No content blob in snapshot: #{dataSharePack.snapshot.id}"
        end
        path = content.filepath
        if !File.file?(path)
          raise Exception.new "Content file #{path} does not exists for snapshot: #{dataSharePack.snapshot.id}"
        end
        return path
      end

      def makeDepositFileName(dataSharePack)
        parent = dataSharePack.snapshot.resource
        return "#{parent.class}.#{parent.id}.ro.zip"
      end

      def read_configuration
        if configured?
          #y = YAML.load_file(config_path)
          #@config=Config.new
          #@config.username=y[Rails.env]["username"]
          #@config.password=y[Rails.env]["password"]
          #@config.uri=y[Rails.env]["uri"]
          @config = Config.new
          @config.uri = 'http://localhost:8550/deposit'

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
