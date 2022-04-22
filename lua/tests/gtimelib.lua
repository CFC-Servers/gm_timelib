return {
    {
        name = "Basic time objects should create without error",
        func = function()
            local function isTimeInstance( thing )
                return thing.__class == "TimeInstance"
            end

            assert( isTimeInstance( Time.Seconds( 5 ) ) )
            assert( isTimeInstance( Time.Minutes( 5 ) ) )
            assert( isTimeInstance( Time.Hours( 5 ) ) )
            assert( isTimeInstance( Time.Days( 5 ) ) )
            assert( isTimeInstance( Time.Weeks( 5 ) ) )
            assert( isTimeInstance( Time.Months( 5 ) ) )
            assert( isTimeInstance( Time.Years( 5 ) ) )

            assert( isTimeInstance( (5).Seconds ) )
            assert( isTimeInstance( (5).Minutes ) )
            assert( isTimeInstance( (5).Hours ) )
            assert( isTimeInstance( (5).Days ) )
            assert( isTimeInstance( (5).Weeks ) )
            assert( isTimeInstance( (5).Months ) )
            assert( isTimeInstance( (5).Years ) )
        end
    },
    {
        name = "TimeInstances should handle all step-up conversions",
        func = function()
            assert( Time.Minutes( 1 ).As.Seconds == 60 )
            assert( Time.Hours( 1 ).As.Minutes == 60 )
            assert( Time.Days( 1 ).As.Hours == 24 )
            assert( Time.Weeks( 1 ).As.Days == 7 )
            assert( Time.Months( 1 ).As.Weeks == 4 )
            assert( Time.Years( 1 ).As.Months == 12 )
        end
    },
    {
        name = "TimeInstances should handle all step-down conversions",
        func = function()
            assert( Time.Seconds( 60 ).As.Minutes == 1 )
            assert( Time.Minutes( 60 ).As.Hours == 1 )
            assert( Time.Hours( 24 ).As.Days == 1 )
            assert( Time.Days( 7 ).As.Weeks == 1 )
            assert( Time.Weeks( 4 ).As.Months == 1)
            assert( Time.Months( 12 ).As.Years == 1 )
        end
    },
    {
        name = "TimeInstances should convert to timestamps",
        func = function()
            assert( Time.Seconds( os.time() ).As.Timestamp == os.time() )
        end
    },
    {
        name = "TimeInstances should respond correctly to comparison operators",
        func = function()
            local a, b

            a = Time.Minutes( 5 )
            b = Time.Minutes( 6 )
            assert( a < b )
            assert( a <= b )
            assert( b > a )
            assert( b >= a )
        end
    },
    {
        name = "TimeInstances should respond correctly to equality operators",
        func = function()
            local a, b

            a = Time.Minutes( 5 )
            b = Time.Minutes( 5 )
            assert( a == b )

            a = Time.Minutes( 1 )
            b = Time.Minutes( 2 )
            assert( a ~= b )
        end
    },
    {
        name = "TimeInstances should be addable by ints",
        func = function()
            local a = Time.Seconds( 5 )

            assert( ( a + 10 ).As.Seconds == 15 )
        end
    },
    {
        name = "TimeInstances should be addable by other TimeInstances",
        func = function()
            local a = Time.Minutes( 5 )
            local b = Time.Minutes( 10 )

            assert( ( a + b ).As.Minutes == 15 )
        end
    },
    {
        name = "TimeInstances should be subtractable by ints",
        func = function()
            local a = Time.Seconds( 11 )
            assert( ( a - 5 ).As.Seconds == 6 )
        end
    },
    {
        name = "TimeInstances should be subtractable by other TimeInstances",
        func = function()
            local a = Time.Minutes( 11 )
            local b = Time.Minutes( 5 )

            assert( ( a - b ).As.Minutes == 6 )
        end
    },
    {
        name = "TimeInstances should be divisible by ints",
        func = function()
            local a = Time.Minutes( 10 )
            assert( ( a / 2 ).As.Minutes == 5 )
        end
    },
    {
        name = "TimeInstances should be divisible by other TimeInstances",
        func = function()
            local a = Time.Hours( 10 )
            local b = Time.Minutes( 60 )
            assert( a / b == 10 )
        end
    },
    {
        name = "TimeInstances should be multiplicable by ints",
        func = function()
            local a = Time.Minutes( 10 )
            assert( (a * 2).As.Minutes == 20 )
        end
    },
    {
        name = "TimeInstances should respond to tostring",
        func = function()
            local a = Time.Seconds( 15 )
            assert( tostring( a ) == "TimeInstance [15 seconds]")
        end
    },
    {
        name = "Time.Now should return the current os time",
        func = function()
            assert( Time.Now == Time.Seconds( os.time() ) )
        end
    },
    {
        name = "Time.Since should return a correct TimeInstance",
        func = function()
            local timeBasis = function() return 10 end
            local basedTime = Time.Basis( timeBasis )

            local a = Time.Seconds( 4 )

            assert( basedTime.Since( a ).As.Seconds == 6 )
        end
    },
    {
        name = "Time.Until should return a correct TimeInstance",
        func = function()
            local timeBasis = function() return 10 end
            local basedTime = Time.Basis( timeBasis )

            local a = Time.Seconds( 14 )

            assert( basedTime.Until( a ).As.Seconds == 4 )
        end
    },
    {
        name = "TimeInstance.Ago should return a correct TimeInstance",
        func = function()
            local expected = os.time() - 25
            local actual = Time.Seconds( 25 ).Ago

            assert( actual.As.Timestamp == expected )
        end
    },
    {
        name = "TimeInstance.Hence should return a correct TimeInstance",
        func = function()
            local expected = os.time() + 25
            local actual = Time.Seconds( 25 ).Hence

            assert( actual.As.Timestamp == expected )
        end
    },
    {
        name = "Time.Basis should return a new Time object with the given basis function",
        func = function()
            local NewBasis = function() return 1 end
            assert( Time.Basis( NewBasis )._basis == NewBasis )
            assert( Time.Basis( NewBasis ).Now.As.Seconds == 1 )
        end
    },
    {
        name = "TimeInstances should inherit a Time's Basis",
        func = function()
            local NewBasis = function() return 50 end
            local timeObject = Time.Basis( NewBasis )

            local a = timeObject.Seconds( 10 )
            assert( a.time == timeObject )
            assert( a.Ago.As.Seconds == 40 )
        end
    },
    {
        name = "TimeInstances should concat into ranges",
        func = function()
            local a = (5).Hours.Ago
            local b = (2).Hours.Ago
            local range = a .. b

            assert( range.__class == "TimeRange" )
        end
    },
    {
        name = "TimeRanges should handle range inclusion of TimeInstances",
        func = function()
            local a = (1).Hours.Ago
            local b = Time.Now
            local range = a .. b

            assert( range[(5).Minutes.Ago] == true )
            assert( range[(61).Minutes.Ago] == false )
            assert( range[(1).Hours.Ago] == true )
            assert( range[(1).Hours.Hence] == false )
        end
    },
    {
        name = "TimeRanges should handle range inclusions of ints",
        func = function()
            local a = Time.Seconds( 1 )
            local b = Time.Seconds( 100 )
            local range = a .. b

            assert( range[50] == true )

            assert( range[0] == false )
            assert( range[1] == true)

            assert( range[101] == false )
            assert( range[100] == true )
        end
    },
    {
        name = "TimeRanges should handle range inclusion of other TimeRanges",
        func = function()
            local a = Time.Seconds( 1 )
            local b = Time.Seconds( 100 )
            local range = a .. b

            local c = Time.Seconds( 25 )
            local d = Time.Seconds( 75 )
            local range2 = c .. d

            assert( range[range2] == true )
            assert( range2[range] == false )
            assert( range[range] == true )
        end
    }
}
