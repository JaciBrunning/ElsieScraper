require "net/http"
require "uri"
require "base64"
require "securerandom"
require "json"

class ElsieSession
    attr_reader :user

    def initialize usr, pwd
        @user = usr
        @pwd = pwd
        @authTopic = { curtinId: usr, password: pwd}.to_json

        @baseurl = "https://elsie.curtin.edu.au/api"

        @uri = URI.parse(@baseurl)
        @http = Net::HTTP.new(@uri.host, @uri.port)
        @http.use_ssl = true

        doAuth
    end

    def makeURI path
        URI.parse("#{@baseurl}/#{path}")
    end

    def doAuth
        uri = makeURI("sessions")
        puts uri
        req = Net::HTTP::Post.new(uri.request_uri)
        req['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36'
        req['X-Correlation-ID'] = SecureRandom.uuid
        req['Content-Type'] = 'application/json;charset=UTF-8'
        req.body = @authTopic
        response = @http.request req
        @authResponse = JSON.parse(response.body)
        unless @authResponse['errors'].nil?
            throw "Auth Error: #{@authResponse['errors'].join(' ')}"
        end
        @token = @authResponse['data']['token']
    end

    def doGet path
        uri = makeURI(path)
        req = Net::HTTP::Get.new(uri.request_uri)
        req['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36'
        req['X-Correlation-ID'] = SecureRandom.uuid
        req['authorization'] = "Bearer #{@token}" if @token
        @http.request req
    end

    def get path
        JSON.parse(doGet(path).body)
    end
end