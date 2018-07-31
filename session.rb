require "net/http"
require "uri"
require "base64"
require "securerandom"
require "json"

class ElsieSession
    AGENT = "elsie-android-1.9.1-1-PRD"
    CLIENTID = "7cd27c197fa64c51ab4f28eceacd8e77"
    CLIENTSECRET = "1a7c32fd043f457eACB8B300C193D196"

    def initialize usr, pwd
        @user = usr
        @pwd = pwd
        @auth = Base64.encode64("#{usr}:#{pwd}").strip

        @baseurl = "https://cip-msa-v1-prd.au.cloudhub.io/api"

        @uri = URI.parse(@baseurl)
        @http = Net::HTTP.new(@uri.host, @uri.port)
        @http.use_ssl = true
    end

    def makeURI path
        URI.parse("#{@baseurl}/#{path}")
    end

    def doGet path
        uri = makeURI(path)
        req = Net::HTTP::Get.new(uri.request_uri)
        req['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36'
        req['X-Correlation-ID'] = SecureRandom.uuid
        req['X-Consumer-ID'] = AGENT
        req['X-Caller-ID'] = AGENT
        req['Authorization'] = "Basic #{@auth}"
        @http.request req
    end

    def get path
        JSON.parse(doGet(path).body)
    end
end