# /lib/barclay/v1.rb
require "net/http"
require "uri"
require "json"

module Barclay
  class V1
    class << self

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

      def webhooks(account_id)
        get(Settings.barclay_account_url, '/accounts/' + account_id + '/webhooks')
        self
      end

      def webhook(account_id, webhook_id)
        get(Settings.barclay_account_url, '/accounts/' + account_id + '/webhooks/' + webhook_id)
        self
      end

      def add_webhook(account_id, webhook)
        post(Settings.barclay_account_url, '/accounts/' + account_id + '/webhooks', webhook)
        self
      end

      def delete_webhook(account_id, webhook_id)
        delete(Settings.barclay_account_url, '/accounts/' + account_id + '/webhooks/' + webhook_id)
        self
      end

      def transaction(transaction_id, webhook_id)
        get(Settings.barclay_transaction_url, '/transactions/' + transaction_id)
        self
      end

      def response
        @response
      end

      def parsed_response
        JSON.parse(@response)
      end

      private
        def get(url, _uri)
          uri = URI.parse(url + _uri)
          @response =  $redis.get(_uri)
          if @response.nil?
            @response = Net::HTTP.get(uri)
            $redis.set(_uri, @response)
          end
          self
        end

        def post(url, uri, options)
          uri = URI.parse(url + uri)
          # options.merge!(self.auth)
          @response = Net::HTTP.post_form(uri, options)
          self
        end

        def delete(url, uri)
          uri = URI.parse(url + uri)
          # options.merge!(self.auth)
          @response = Net::HTTP.delete(uri)
          self
        end
    end
  end
end

