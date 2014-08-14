require 'net/http'

# module ApplicationHelper

  module PushHelper

    GCM_URI     = URI.parse("https://android.googleapis.com/gcm/send")
    GCM_HEADER  = { "Authorization" => "key=AIzaSyCH-W-G8oHPVT647mSRseuSvRhLUWMQPps", "Content-Type" => "application/json" }

    def self.push(data, *targets)
      http = Net::HTTP.new(GCM_URI.host, GCM_URI.port)
      http.use_ssl = true

      post = Net::HTTP::Post.new(GCM_URI.request_uri, GCM_HEADER)

      post.body = "#{{ "registration_ids" => targets, "data" => data }.to_json}"

      res = http.request(post)

      puts "Request #{post.body}"
      puts "Response #{res.code} #{res.message}: #{res.body}"

      # logger.debug "GGGG: #{res}"
      #
      # case res
      #   when 200
      #     logger.info "Successfully sent: #{post.form_data}"
      #   when 400
      #     logger.debug "Couldn't parse JSON supplied: #{post.form_data}"
      #   when 401
      #     logger.debug "Authentication error"
      #   else
      #     # if res > 500 and res < 599
      #     #   logger.debug "Internal GCM error: #{res}"
      #     # else
      #     #   logger.info "Unknown response: #{res}"
      #     # end
      #   end
    end

  end

# end