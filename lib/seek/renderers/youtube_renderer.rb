module Seek
  module Renderers
    class YoutubeRenderer < BlobRenderer
      def can_render?
        content_blob && content_blob.url && is_youtube_url?(content_blob.url) && extract_video_code(content_blob.url)
      end

      def render
        code = extract_video_code(content_blob.url)
        "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/#{code}\" frameborder=\"0\" allowfullscreen></iframe>"
      rescue Exception => exception
        if Seek::Config.exception_notification_enabled
          data = { message: 'rendering error', renderer: self, item: content_blob.inspect }
          ExceptionNotifier.notify_exception(exception, data: data)
        end
        ''
      end

      def is_youtube_url?(url)
        parsed_url = URI.parse(url)
        (parsed_url.host.end_with?('youtube.com') || parsed_url.host.end_with?('youtu.be')) &&
            parsed_url.scheme =~ /(http|https)/
      rescue
        false
      end

      def extract_video_code(url)
        match = url.match(/\?v\=([-a-zA-Z0-9]+)/) ||
            url.match(/youtu\.be\/([-a-zA-Z0-9]+)/) ||
            url.match(/\/v\/([-a-zA-Z0-9]+)/) ||
            url.match(/\/embed\/([-a-zA-Z0-9]+)/)
        if match
          match[1]
        else
          nil
        end
      end
    end
  end
end
