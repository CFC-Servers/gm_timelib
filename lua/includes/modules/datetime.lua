local rawget = rawget
local isnumber = isnumber
local string_format = string.format

local transformations = {
    StepUp = {},
    StepDown = {}
}

local StepUp, StepDown
do
    StepUp = {
        Seconds = function( t ) return t end,
        Minutes = function( t ) return t * 60 end,
        Hours   = function( t ) return t * 60 * 60 end,
        Days    = function( t ) return t * 60 * 60 * 24 end,
        Weeks   = function( t ) return t * 60 * 60 * 24 * 7 end,
        Months  = function( t ) return t * 60 * 60 * 24 * 7 * 4 end,
        Years   = function( t ) return t * 60 * 60 * 24 * 7 * 4 * 12 end
    }
    transformations.StepUp = StepUp

    StepDown = {
        Seconds = function( t ) return t end,
        Minutes = function( t ) return t / 60 end,
        Hours   = function( t ) return t / 60 / 60 end,
        Days    = function( t ) return t / 60 / 60 / 24 end,
        Weeks   = function( t ) return t / 60 / 60 / 24 / 7 end,
        Months  = function( t ) return t / 60 / 60 / 24 / 7 / 4 end,
        Years   = function( t ) return t / 60 / 60 / 24 / 7 / 4 / 12 end
    }
    StepDown.Timestamp = StepDown.Seconds
    transformations.StepDown = StepDown
end

-- == TimeRange == --
local rangeMeta = {
    __index = function( self, idx )
        if idx == nil then return end

        if idx == "As" then
            return setmetatable({}, {
                __index = function( _, asIdx )
                    local transformer = rawget( StepDown, asIdx )
                    if not transformer then return end
                    return transformer( self.endTime - self.startTime )
                end
            })
        end

        local min, max

        if idx.__class == "TimeInstance" then
            local seconds = idx.seconds
            min, max = seconds, seconds
        elseif idx.__class == "TimeRange" then
            min, max = idx.startTime.seconds, idx.endTime.seconds
        elseif isnumber( idx ) then
            min, max = idx, idx
        end

        return min >= self.startTime.seconds and max <= self.endTime.seconds
    end,

    __name = "TimeRange",
    __tostring = function( self )
        return string_format( "TimeRange [%d - %d]", self.startTime.seconds, self.endTime.seconds )
    end
}

local TimeRange = function( startTime, endTime )
    return setmetatable({
        startTime = startTime,
        endTime = endTime,
        __class = "TimeRange"
    }, rangeMeta )
end

-- == TimeInstance == --
local TimeInstance
local timeInstanceMeta = {
    __index = function( self, idx )
        if idx == "As" then
            return setmetatable( {}, {
                __index = function( _, asIdx )
                    local transformer = rawget( StepDown, asIdx )
                    if not transformer then return end
                    return transformer( self.seconds )
                end
            } )
        elseif idx == "Ago" then
            return self:TimeInstance( ( self.time.Now - self ).seconds )
        elseif idx == "Hence" then
            return self:TimeInstance( ( self.time.Now + self ).seconds )
        else
            return rawget( self, idx )
        end
    end,

    __eq = function( a, b ) return a.seconds == b.seconds end,
    __lt = function( a, b ) return a.seconds < b.seconds end,
    __le = function( a, b ) return a.seconds <= b.seconds end,
    __gt = function( a, b ) return a.seconds > b.seconds end,
    __ge = function( a, b ) return a.seconds >= b.seconds end,
    __add = function( a, b )
        local newAmount = 0

        if b.__class == a.__class then
            newAmount = a.seconds + b.seconds
        else
            newAmount = a.seconds + b
        end

        return a:TimeInstance( newAmount )
    end,
    __sub = function( a, b )
        local newAmount = 0

        if b.__class == a.__class then
            newAmount = a.seconds - b.seconds
        else
            newAmount = a.seconds - b
        end

        return a:TimeInstance( newAmount )
    end,
    __mul = function( a, b ) return a:TimeInstance( a.seconds * b ) end,
    __div = function( a, b )
        if b.__class == a.__class then
            return a.seconds / b.seconds
        else
            return a:TimeInstance( a.seconds / b )
        end
    end,

    __name = "TimeInstance",
    __tostring = function( self )
        return string_format( "TimeInstance [%d seconds]", self.seconds )
    end,
    __concat = function( a, b )
        return TimeRange( a, b )
    end
}

TimeInstance = function( amount, timeObject )
    return setmetatable(
    {
        seconds = amount,
        time = timeObject,
        __class = "TimeInstance",
        -- TODO: Come up with a better name for this
        TimeInstance = function( self, newAmount )
            return TimeInstance( newAmount, self.timeObject )
        end
    },
    timeInstanceMeta
    )
end

-- == Time Table == --
local timeMeta = {
    __index = function( self, idx )
        if idx == "Now" then
            return TimeInstance( self._basis(), self )
        end

        if idx == "Since" then
            return function(t) return TimeInstance( self._basis() - t.seconds, self ) end
        end

        if idx == "Until" then
            return function(t) return TimeInstance( t.seconds - self._basis(), self ) end
        end

        local transformer = rawget( StepUp, idx )
        if not transformer then return rawget( self, idx ) end

        return function(n) return TimeInstance( transformer( n ), self ) end
    end,
    __call = function( self, seconds ) return TimeInstance( seconds, self ) end
}

local function createTimeObject( timeBasis )
    local newTime = { _basis = timeBasis }
    newTime.Basis = function( newBasis )
        return createTimeObject( newBasis )
    end

    return setmetatable( newTime, table.Copy( timeMeta ) )
end

Time = createTimeObject( os.time )

-- Extend the number metatable to allow for (2).Minutes and such
debug.setmetatable( 0, {
    __index = function( self, idx )
        local transformer = rawget( StepUp, idx )
        if not transformer then return end
        return TimeInstance( transformer( self ), Time )
    end
})
