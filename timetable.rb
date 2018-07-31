class ElsieTimetable

    def initialize session, startDate, endDate
        @session = session
        @start = startDate
        @end = endDate
    end

    def call
        url = "timelines/study/entries?startDateTime=#{@start.to_date.to_s}&endDateTime=#{@end.to_date.to_s}&modifiedAfter=1970-01-01"
        @response ||= @session.get(url)["collection"].select { |x| !x["isDeleted"] }
    end

    def entries
        call.map { |x| Entry.new(x) }
    end

    def to_calendar
        cal = Icalendar::Calendar.new
        entries.each do |entry|
            cal.event do |event|
                event.dtstart = entry.startTime.new_offset(0).strftime("%Y%m%dT%H%M%SZ")
                event.dtend = entry.endTime.new_offset(0).strftime("%Y%m%dT%H%M%SZ")
                event.summary = "#{entry.unitcode} #{entry.unitabbrev} #{entry.type}"
                event.location = "#{entry.building}.#{entry.room} (#{entry.roomname})"
            end
        end
        cal
    end

    class Entry
        [:unit, :unitname, :unitabbrev, :unitcode, :type, :startTime, 
        :endTime, :building, :room, :buildingname, :roomname].each do |field|
            attr_reader field
        end

        def initialize hash
            @unit = hash["unit"]["availabilityId"]
            @unitname = hash["unit"]["unitTitle"]
            @unitabbrev = @unitname.split(/\s+/).map { |x| x[0] }.select { |x| x == x.upcase }.join
            @unitcode = hash["unit"]["unitCode"]

            @type = hash["activityType"]

            @startTime = DateTime.parse(hash["dateTimeStart"])
            @endTime = DateTime.parse(hash["dateTimeEnd"])

            @building = hash["location"]["buildingNumber"]
            @room = hash["location"]["roomNumber"]
            @buildingname = hash["location"]["buildingName"]
            @roomname = hash["location"]["name"]
        end
    end

end