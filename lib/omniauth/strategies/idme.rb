require "omniauth/strategies/oauth2"

module OmniAuth
  module Strategies
    class IDme < OmniAuth::Strategies::OAuth2

      option :name,   "idme"
      option :scope,  "military"

      option :client_options, {
        :site               => "https://api.id.me",
        :authorize_url      => "https://api.id.me/oauth/authorize",
        :token_url          => "https://api.id.me/oauth/token"
      }

      option :authorize_options, [:scope, :display]

      uid { attributes['uuid'] }

      info do
        {
          name:       [attributes['fname'],attributes['lname']].join(' '),
          email:      attributes['email'],
          first_name: attributes['fname'],
          last_name:  attributes['lname'],
          location:   attributes['zip'],
          birth_date: attributes['birth_date']
        }
      end

      extra do
        {
          group:      data['status'].first['group'],
          subgroup:   data['status'].first['subgroups'].first,
          branch:     attributes['military_member_branch'] || attributes['military_branch'],
          uuid:       attributes['uuid'],
          verfied:    data['status'].first['verified'],
          raw_info:   data
        }
      end

      def data
        @data ||= access_token.get("/api/public/v3/attributes.json").parsed
        # debugger
      end

      def attributes
        data['attributes'].map {|t| [t['handle'],t['value']]}.to_h
      end

      def headers
        { "X-API-ORIGIN" => "OMNIAUTH-IDME" }
      end

    end
  end
end

OmniAuth.config.add_camelization "idme", "IDme"
