module Seek
  module UploadHandling
    module ParameterHandling
      def asset_params
        params[controller_name.downcase.singularize.to_sym]
      end

      def content_blob_params
        params[:content_blobs]
      end

      def clean_params
        if asset_params
          %w(data_url data make_local_copy).each do |key|
            asset_params.delete(key)
          end
        end
      end

      def retained_content_blob_ids
        (params[:retained_content_blob_ids] || []).map { |id| id.to_i }.sort
      end

      def model_image_present?
        params[:model_image] && params[:model_image][:image_file]
      end

      def check_for_data_or_url(blob_params)
        if (blob_params[:data]).blank? && (blob_params[:data_url]).blank?
          if blob_params.include?(:data_url)
            flash.now[:error] = 'Please select a file to upload or provide a URL to the data.'
          else
            flash.now[:error] = 'Please select a file to upload.'
          end
          false
        else
          true
        end
      end

      def check_for_valid_uri_if_present(blob_params)
        data_url_param = blob_params[:data_url]
        if !data_url_param.blank? && !valid_uri?(data_url_param)
          flash.now[:error] = "The URL '#{data_url_param}' is not valid"
          false
        else
          true
        end
      end

      def check_for_empty_data_if_present(blob_params)
        return true unless blob_params[:data_url].blank?
        Array(blob_params[:data]).each do |data|
          if !data.blank? && data.size == 0
            flash.now[:error] = 'The file that you are uploading is empty. Please check your selection and try again!'
            return false
          end
        end
        true
      end
    end
  end
end
