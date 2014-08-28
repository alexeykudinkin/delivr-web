require 'net/http'

# module ApplicationHelper

  module PushHelper

    GCM_URI     = URI.parse("https://android.googleapis.com/gcm/send")
    GCM_HEADER  = { "Authorization" => "key=AIzaSyCH-W-G8oHPVT647mSRseuSvRhLUWMQPps", "Content-Type" => "application/json" }

    def self.push(data, *targets)
      unless targets.blank? || targets.length == 0
        http = Net::HTTP.new(GCM_URI.host, GCM_URI.port)
        http.use_ssl = true

        post = Net::HTTP::Post.new(GCM_URI.request_uri, GCM_HEADER)

        post.body = "#{{ "registration_ids" => targets, "data" => data }.to_json}"

        res = http.request(post)

        Rails.logger.info "[GCM] Push: request #{post.body}"
        Rails.logger.info "[GCM] Push: response #{res.code} #{res.message}: #{res.body}"
      end
    end

  end

# end