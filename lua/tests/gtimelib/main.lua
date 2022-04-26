return {
    {
        name = "Basic time objects should create without error",
        func = function()
            expect( Time.Seconds( 5 ) ).to.beA( "TimeInstance" )
            expect( Time.Minutes( 5 ) ).to.beA( "TimeInstance" )
            expect( Time.Hours( 5 ) ).to.beA( "TimeInstance" )
            expect( Time.Days( 5 ) ).to.beA( "TimeInstance" )
            expect( Time.Weeks( 5 ) ).to.beA( "TimeInstance" )
            expect( Time.Months( 5 ) ).to.beA( "TimeInstance" )
            expect( Time.Years( 5 ) ).to.beA( "TimeInstance" )

            expect( (5).Seconds ).to.beA( "TimeInstance" )
            expect( (5).Minutes ).to.beA( "TimeInstance" )
            expect( (5).Hours ).to.beA( "TimeInstance" )
            expect( (5).Days ).to.beA( "TimeInstance" )
            expect( (5).Weeks ).to.beA( "TimeInstance" )
            expect( (5).Months ).to.beA( "TimeInstance" )
            expect( (5).Years ).to.beA( "TimeInstance" )
        end
    },
    {
        name = "TimeInstances should handle all step-up conversions",
        func = function()
            expect( Time.Minutes( 1 ).As.Seconds ).to.eq( 60 )
            expect( Time.Hours( 1 ).As.Minutes ).to.eq( 60 )
            expect( Time.Days( 1 ).As.Hours ).to.eq( 24 )
            expect( Time.Weeks( 1 ).As.Days ).to.eq( 7 )
            expect( Time.Months( 1 ).As.Weeks ).to.eq( 4 )
            expect( Time.Years( 1 ).As.Months ).to.eq( 12 )
            local a = true
            local b = false
            expect( a ).to.eq( b )
        end
    },
    {
        name = "TimeInstances should handle all step-down conversions",
        func = function()
            expect( Time.Seconds( 60 ).As.Minutes ).to.eq( 1 )
            expect( Time.Minutes( 60 ).As.Hours ).to.eq( 1 )
            expect( Time.Hours( 24 ).As.Days ).to.eq( 1 )
            expect( Time.Days( 7 ).As.Weeks ).to.eq( 1 )
            expect( Time.Weeks( 4 ).As.Months ).to.eq( 1)
            expect( Time.Months( 12 ).As.Years ).to.eq( 1 )
            undefined( "blah" )
        end
    },
    {
        name = "TimeInstances should convert to timestamps",
        func = function()
            expect( Time.Seconds( os.time() ).As.Timestamp ).to.eq( os.time() )
            local a = {} .. Color(1,1,1) .. Color() .. Color() .. Color() .. Color() .. Color()
        end
    },
    {
        name = "TimeInstances should respond correctly to comparison operators",
        func = function()
            local a, b

            a = Time.Minutes( 5 )
            b = Time.Minutes( 6 )
            expect( a < b ).to.beTrue()
            expect( a <= b ).to.beTrue()
            expect( b > a ).to.beTrue()
            expect( b >= a ).to.beTrue()
        end
    },
    {
        name = "TimeInstances should respond correctly to equality operators",
        func = function()
            local a, b

            a = Time.Minutes( 5 )
            b = Time.Minutes( 5 )
            expect( a ).to.eq( b )

            a = Time.Minutes( 1 )
            b = Time.Minutes( 2 )
            expect( a ~= b ).to.beTrue()
        end
    },
    {
        name = "TimeInstances should be addable by ints",
        func = function()
            local a = Time.Seconds( 5 )

            expect( ( a + 10 ).As.Seconds ).to.eq( 15 )
        end
    },
    {
        name = "TimeInstances should be addable by other TimeInstances",
        func = function()
            local a = Time.Minutes( 5 )
            local b = Time.Minutes( 10 )

            expect( ( a + b ).As.Minutes ).to.eq( 15 )
        end
    },
    {
        name = "TimeInstances should be subtractable by ints",
        func = function()
            local a = Time.Seconds( 11 )
            expect( ( a - 5 ).As.Seconds ).to.eq( 6 )
        end
    },
    {
        name = "TimeInstances should be subtractable by other TimeInstances",
        func = function()
            local a = Time.Minutes( 11 )
            local b = Time.Minutes( 5 )

            expect( ( a - b ).As.Minutes ).to.eq( 6 )
        end
    },
    {
        name = "TimeInstances should be divisible by ints",
        func = function()
            local a = Time.Minutes( 10 )
            expect( ( a / 2 ).As.Minutes ).to.eq( 5 )
        end
    },
    {
        name = "TimeInstances should be divisible by other TimeInstances",
        func = function()
            local a = Time.Hours( 10 )
            local b = Time.Minutes( 60 )
            expect( a / b ).to.eq( 10 )
        end
    },
    {
        name = "TimeInstances should be multiplicable by ints",
        func = function()
            local a = Time.Minutes( 10 )
            expect( (a * 2).As.Minutes ).to.eq( 20 )
        end
    },
    {
        name = "TimeInstances should respond to tostring",
        func = function()
            local a = Time.Seconds( 15 )
            expect( tostring( a ) ).to.eq( "TimeInstance [15 seconds]")
        end
    },
    {
        name = "Time.Now should return the current os time",
        func = function()
            expect( Time.Now ).to.eq( Time.Seconds( os.time() ) )
        end
    },
    {
        name = "Time.Since should return a correct TimeInstance",
        func = function()
            local timeBasis = function() return 10 end
            local basedTime = Time.Basis( timeBasis )

            local a = Time.Seconds( 4 )

            expect( basedTime.Since( a ).As.Seconds ).to.eq( 6 )
        end
    },
    {
        name = "Time.Until should return a correct TimeInstance",
        func = function()
            local timeBasis = function() return 10 end
            local basedTime = Time.Basis( timeBasis )

            local a = Time.Seconds( 14 )

            expect( basedTime.Until( a ).As.Seconds ).to.eq( 4 )
        end
    },
    {
        name = "TimeInstance.Ago should return a correct TimeInstance",
        func = function()
            local expected = os.time() - 25
            local actual = Time.Seconds( 25 ).Ago

            expect( actual.As.Timestamp ).to.eq( expected )
        end
    },
    {
        name = "TimeInstance.Hence should return a correct TimeInstance",
        func = function()
            local expected = os.time() + 25
            local actual = Time.Seconds( 25 ).Hence

            expect( actual.As.Timestamp ).to.eq( expected )
        end
    },
    {
        name = "Time.Basis should return a new Time object with the given basis function",
        func = function()
            local NewBasis = function() return 1 end
            expect( Time.Basis( NewBasis )._basis ).to.eq( NewBasis )
            expect( Time.Basis( NewBasis ).Now.As.Seconds ).to.eq( 1 )
        end
    },
    {
        name = "TimeInstances should inherit a Time's Basis",
        func = function()
            local NewBasis = function() return 50 end
            local timeObject = Time.Basis( NewBasis )

            local a = timeObject.Seconds( 10 )
            expect( a.time ).to.eq( timeObject )
            expect( a.Ago.As.Seconds ).to.eq( 40 )
        end
    },
    {
        name = "TimeInstances should concat into ranges",
        func = function()
            local a = (5).Hours.Ago
            local b = (2).Hours.Ago
            local range = a .. b

            expect( range ).to.beA( "TimeRange" )
        end
    },
    {
        name = "TimeRanges should handle range inclusion of TimeInstances",
        func = function()
            local a = (1).Hours.Ago
            local b = Time.Now
            local range = a .. b

            expect( range[(5).Minutes.Ago] ).to.eq( true )
            expect( range[(61).Minutes.Ago] ).to.eq( false )
            expect( range[(1).Hours.Ago] ).to.eq( true )
            expect( range[(1).Hours.Hence] ).to.eq( false )
        end
    },
    {
        name = "TimeRanges should handle range inclusions of ints",
        func = function()
            local a = Time.Seconds( 1 )
            local b = Time.Seconds( 100 )
            local range = a .. b

            expect( range[50] ).to.beTrue()

            expect( range[0] ).to.beFalse()
            expect( range[1] ).to.beTrue()

            expect( range[101] ).to.beFalse()
            expect( range[100] ).to.beTrue()
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

            expect( range[range2] ).to.beTrue()
            expect( range2[range] ).to.beFalse()
            expect( range[range] ).to.beTrue()
        end
    }
}
