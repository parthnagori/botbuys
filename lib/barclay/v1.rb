# /lib/barclay/v1.rb
require "net/http"
require "uri"
require "json"

module Barclay
  class V1
    class << self

      # def auth
      #   return {  "subscriber_id" => Settings.barclay_subscriber_id,
      #             "subscriber_token" => Settings.barclay_subscriber_token }
      # end

      def customers()
        get(Settings.barclay_customer_url, 'customers')
        self
      end

      def customer(customer_id)
        get(Settings.barclay_customer_url, 'customers/' + customer_id)
        self
      end

      def accounts(account_id)
        get(Settings.barclay_account_url, 'accounts/' + account_id)
        self
      end

      def internal_accounts(account_id)
        get(Settings.barclay_account_url, 'accounts/' + account_id + '/internal-accounts')
        self
      end

      def internal_account(account_id, internal_account_id)
        get(Settings.barclay_account_url, 'accounts/' + account_id + '/internal-accounts/' + internal_account_id)
        self
      end

      def payees(account_id)
        get(Settings.barclay_account_url, '/accounts/' + account_id + '/payees')
        self
      end

      def add_payee(account_id, payee)
        post(Settings.barclay_account_url, '/accounts/' + account_id + '/payees', payee)
        self
      end

      def payee(account_id, payee_id)
        get(Settings.barclay_account_url, '/accounts/' + account_id + '/payees/' + payee_id)
        self
      end

      def transactions(account_id)
        get(Settings.barclay_account_url, '/accounts/' + account_id + '/transactions')
        self
      end

      def add_transaction(account_id, transaction)
        post(Settings.barclay_account_url, '/accounts/' + account_id + '/transactions', transaction)
        self
      end

      def response
        @response
      end

      def parsed_response
        JSON.parse(@response.body)
      end

      private
        def post(url, uri, options)
          uri = URI.parse(url + uri)
          # options.merge!(self.auth)
          @response = Net::HTTP.post_form(uri, options)
          self
        end

        def get(url, uri)
          uri = URI.parse(url + uri)
          # options.merge!(self.auth)
          @response = Net::HTTP.get(uri)
          self
        end
    end
  end
end
