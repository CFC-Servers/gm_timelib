local transformations
with transformations = {}
    -- TODO: Make these faster by getting rid of the cascading function calls

    -- "Five Minutes" represented in seconds
    with transformations.StepUp = {}
        .Seconds = (t) -> t
        .Minutes = (t) -> t * 60
        .Hours = (t) -> .Minutes(t) * 60
        .Days = (t) -> .Hours(t) * 24
        .Weeks = (t) -> .Days(t) * 7
        .Months = (t) -> .Weeks(t) * 30
        .Years = (t) -> .Months(t) * 12

    -- "300 Seconds" represented as X
    with transformations.StepDown = {}
        .Seconds = (t) -> t
        .Minutes = (t) -> t / 60
        .Hours = (t) -> .Minutes(t) / 60
        .Days = (t) -> .Hours(t) / 24
        .Weeks = (t) -> .Days(t) / 7
        .Months = (t) -> .Weeks(t) / 30
        .Years = (t) -> .Months(t) / 12
        .Timestamp = .Seconds

-- "TimeRange" object
timeRangeMeta = {
    __index: (idx) =>
        if idx == "As"
            return setmetatable {}, {
                __index: (_, idx) ->
                    transformer = transformations.StepDown[idx]
                    return unless transformer

                    return transformer @endSeconds - @startSeconds
            }

        local min, max

        if idx.__class == "TimeInstance"
            seconds = idx.seconds
            min, max = seconds, seconds

        if idx.__class == "TimeRange"
            min = idx.startSeconds
            max = idx.endSeconds

        if isnumber idx
            min, max = idx, idx

        min >= @startSeconds and max <= @endSeconds

    __name: "TimeRange"
    __tostring: () => "#{@__class} [#{@startSeconds} - #{@endSeconds}]"
}
timeRange = (startSeconds, endSeconds) -> setmetatable {:startSeconds, :endSeconds, __class: "TimeRange"}, timeRangeMeta

-- Final "TimeInstance" object
local timeAmount
timeAmountMeta = {
    __index: (idx) =>
        if idx == "As"
            setmetatable {}, {
                __index: (_, idx) ->
                    transformer = transformations.StepDown[idx]
                    return unless transformer

                    return transformer @seconds
            }
        elseif idx == "Ago"
            return timeAmount(os.time!) - self
        else
            return rawget(self, idx)

    __eq: (b) => @seconds == b.seconds
    __lt: (b) => @seconds < b.seconds
    __le: (b) => @seconds <= b.seconds
    __gt: (b) => @seconds > b.seconds
    __ge: (b) => @seconds >= b.seconds
    __add: (b) =>
        if b.__class == @__class
            timeAmount @seconds + b.seconds
        else
            timeAmount @seconds + b
    __sub: (b) =>
        if b.__class == @__class
            timeAmount @seconds - b.seconds
        else
            timeAmount @seconds - b
    __mul: (b) => timeAmount @seconds * b
    __div: (b) =>
        if b.__class == @__class
            @seconds / b.seconds
        else
            timeAmount @seconds / b

    __name: "TimeInstance"
    __tostring: () => "#{@__class} [#{@seconds} seconds]"
    __concat: (b) => timeRange @seconds, b.seconds
}

timeAmount = (amount) -> setmetatable {seconds: amount, __class: "TimeInstance"}, timeAmountMeta

export Time = {}

timeMeta = {
    __index: (idx) =>
        return timeAmount os.time! if idx == "Now"

        if idx == "Since"
            return (t) -> timeAmount os.time! - t.seconds

        if idx == "Until"
            return (t) -> timeAmount t.seconds - os.time!

        transformer = transformations.StepUp[idx]
        return rawget self, idx unless transformer

        return (n) -> timeAmount transformer n

    __call: (seconds) =>
        return timeAmount seconds
}
setmetatable Time, timeMeta

-- Impose Time's metatable on _G
Time.globalize = ->
    mt = getmetatable _G
    return if mt.__timeSetup

    indexFunc = mt.__index

    mt.__index = (idx) =>
        og = timeMeta\__index idx
        return og if og
        return unless indexFunc

        indexFunc self, idx
    mt.__timeSetup = true

-- Extend the number metatable to allow (2).Minutes
debug.setmetatable 0, {
    __index: (idx) =>
        transformer = transformations.StepUp[idx]
        return unless transformer
        timeAmount transformer self
}

