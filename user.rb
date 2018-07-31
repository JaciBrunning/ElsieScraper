class ElsieUser

    def initialize session
        @session = session
    end

    def call
        @response ||= @session.get("user")["data"]
        throw "Wrong details! Did you get your password wrong?" if @response.nil?
    end

    def id
        call["studentId"]
    end

end