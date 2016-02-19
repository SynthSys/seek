
module Synthsys
  module Dspace

    class Poster

      def post(url,content)

        uri = URI(url)
        #puts uri.hostname
        #puts uri.port
        #puts uri.path

          req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
          req.body = content
          res = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(req)
          end
      end
    end
  end
end
