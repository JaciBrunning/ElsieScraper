class ElsieTimetable
  
  def initialize session
    @session = session
  end

  def call
    url = "students/#{@session.user}/study-activities"
    @response ||= @session.get(url)
    throw "Error: #{@response[:errors].join(' ')}" unless @response[:errors].nil?
  end

  def to_calendar
    cal = Icalendar::Calendar.new
    @response['data'].each do |activity|
      cal.event do |event|
        event.dtstart = DateTime.parse(activity["startDateTime"]).new_offset(0).strftime("%Y%m%dT%H%M%SZ")
        event.dtend = DateTime.parse(activity["endDateTime"]).new_offset(0).strftime("%Y%m%dT%H%M%SZ")
        event.summary = "#{activity["unit"]["unitCode"]} #{activity["unit"]["abbreviatedTitle"]} #{activity["activityType"]}"
        event.location = "#{activity["location"]["buildingNumber"]}.#{activity["location"]["roomNumber"]} (#{activity["location"]["name"]})"
      end
    end
    cal
  end
end