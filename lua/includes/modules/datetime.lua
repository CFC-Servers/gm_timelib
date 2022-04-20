local transformations = {
    StepUp = {},
    StepDown = {}
}

do
    local up = transformations.StepUp
    function up:Seconds( t ) return t end
    function up:Minutes( t ) return t * 60 end
    function up:Hours( t ) return self:Minutes( t ) * 60 end
    function up:Days( t ) return self:Hours( t ) * 24 end
    function up:Weeks( t ) return self:Days( t ) * 7 end
    function up:Months( t ) return self:Weeks( t ) * 30 end
    function up:Years( t ) return self:Months( t ) * 12 end

    local down = transformations.StepDown
    function down:Seconds( t ) return t end
    function down:Minutes( t ) return t / 60 end
    function down:Hours( t ) return self:Minutes( t ) / 60 end
    function down:Days( t ) return self:Hours( t ) / 24 end
    function down:Weeks( t ) return self:Days( t ) / 7 end
    function down:Months( t ) return self:Weeks( t ) / 30 end
    function down:Years( t ) return self:Months( t ) / 12 end
    down.Timestamp = down.Seconds

end

-- == TimeRange == --
local rangeMeta = {
    __index = function( self, idx )
        if idx == "As" then
            return setmetatable({}, {
                __index = function( _, asIdx )
                    local StepDown = transformations.StepDown

                    local transformer = StepDown[asIdx]
                    if not transformer then return end
                    return transformer( StepDown, self.endSeconds - self.startSeconds )
                end
            })
        end

        local min, max

        if idx.__class == "TimeInstance" then
            local seconds = idx.seconds
            min, max = seconds, seconds
        elseif idx.__class == "TimeRange" then
            min, max = idx.startSeconds, idx.endSeconds
        elseif isnumber( idx ) then
            min, max = idx, idx
        end

        return min >= self.startSeconds and max <= self.endSeconds
    end,

    __name = "TimeRange",
    __tostring = function( self )
        return string.format( "%s [%d - %d]", self.__class, self.startSeconds, self.endSeconds )
    end
}

local TimeRange = function( startSeconds, endSeconds )
    return setmetatable({
        startSeconds = startSeconds,
        endSeconds = endSeconds,
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
                    local StepDown = transformations.StepDown

                    local transformer = StepDown[asIdx]
                    if not transformer then return end
                    return transformer( StepDown, self.seconds )
                end
            } )
        elseif idx == "Ago" then
            return TimeInstance( os.time() ) - self
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

        return TimeInstance( newAmount )
    end,
    __sub = function( a, b )
        local newAmount = 0

        if b.__class == a.__class then
            newAmount = a.seconds - b.seconds
        else
            newAmount = a.seconds - b
        end

        return TimeInstance( newAmount )
    end,
    __mul = function( a, b ) return TimeInstance( a.seconds * b ) end,
    __div = function( a, b )
        if b.__class == a.__class then
            return a.seconds / b.seconds
        else
            return TimeInstance( a.seconds / b )
        end
    end,

    __name = "TimeInstance",
    __tostring = function( self )
        return string.format( "%s [%d seconds]", self.__class, self.seconds )
    end,
    __concat = function( a, b )
        return TimeRange( a.seconds, b.seconds )
    end
}

TimeInstance = function( amount )
    return setmetatable(
        {
            seconds = amount,
            __class = "TimeInstance"
        },
        timeInstanceMeta
    )
end

-- == Time Table == --
local timeMeta = {
    __index = function( self, idx )
        if idx == "Now" then return TimeInstance( os.time() ) end
        if idx == "Since" then
            return function(t) return TimeInstance( os.time() - t.seconds ) end
        end
        if idx == "Until" then
            return function(t) return TimeInstance( t.seconds - os.time() ) end
        end

        local StepUp = transformations.StepUp
        local transformer = StepUp[idx]
        if not transformer then return rawget( self, idx ) end

        return function(n) return TimeInstance( transformer( StepUp, n ) ) end
    end,
    __call = function( seconds ) return TimeInstance( seconds ) end
}

Time = setmetatable( {}, timeMeta )

-- Imposes Time's metatable on _G
Time.globalize = function()
    local mt = getmetatable( _G )

    -- Prevents accidentally wrapping twice
    if mt.__timeGlobalized then return end

    -- Store the existing __index function
    local indexFunc = mt.__index
    mt.__index = function( self, idx )
        -- See if the given index exists on the Time metatable
        local timeValue = timeMeta:__index( idx )
        if timeValue then return timeValue end
        if not indexFunc then return end

        -- Fallback to the existing __index function
        return indexFunc( self, idx )
    end

    mt.__timeGlobalized = true
end

-- Extend the number metatable to allow for (2).Minutes and such
debug.setmetatable( 0, {
    __index = function( self, idx )
        local StepUp = transformations.StepUp

        local transformer = StepUp[idx]
        if not transformer then return end
        return TimeInstance( transformer( StepUp, self ) )
    end
})
