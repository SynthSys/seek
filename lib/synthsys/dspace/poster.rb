
module Synthsys
  module Dspace

    class Poster

      class PostError < RuntimeError; end

      def post(url,content)

        uri = URI(url)
        #puts uri.hostname
        #puts uri.port
        #puts uri.path

          req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
          #req.basic_auth user, pass
          req.body = content

          begin
            response = Net::HTTP.start(uri.hostname, uri.port) do |http|
              http.request(req)
            end

            case response
              when Net::HTTPSuccess then

                body = response.body
                if body == nil or body == ""
                  return true
                else
                  return body
                end

              when Net::HTTPResponse then
                msg = "HTTP ERROR #{response.code}"
                if response.class.body_permitted?
                  msg = msg + "\n#{response.body}"
                end
                raise PostError.new msg
              else
                msg = "Unknown response (#{response.class}) #{response}"
                raise PostError.new msg
            end
          rescue PostError => e
            raise e
          rescue Exception => e
            msg = "Got exception: #{e}"
            raise PostError.new msg
          end
      end
    end
  end
end
