return {
    groupName = "TimeInstance",
    cases = {
        {
            name = "Should create without error",
            func = function()
                expect( Time.Seconds( 5 ) ).to.beValid()
                expect( Time.Minutes( 5 ) ).to.beValid()
                expect( Time.Hours( 5 ) ).to.beValid()
                expect( Time.Days( 5 ) ).to.beValid()
                expect( Time.Weeks( 5 ) ).to.beValid()
                expect( Time.Months( 5 ) ).to.beValid()
                expect( Time.Years( 5 ) ).to.beValid()

                expect( (5).Seconds ).to.beValid()
                expect( (5).Minutes ).to.beValid()
                expect( (5).Hours ).to.beValid()
                expect( (5).Days ).to.beValid()
                expect( (5).Weeks ).to.beValid()
                expect( (5).Months ).to.beValid()
                expect( (5).Years ).to.beValid()
            end
        },
        {
            name = "Should handle all step-up conversions",
            func = function()
                expect( Time.Minutes( 1 ).As.Seconds ).to.eq( 60 )
                expect( Time.Hours( 1 ).As.Minutes ).to.eq( 60 )
                expect( Time.Days( 1 ).As.Hours ).to.eq( 24 )
                expect( Time.Weeks( 1 ).As.Days ).to.eq( 7 )
                expect( Time.Months( 1 ).As.Weeks ).to.eq( 4 )
                expect( Time.Years( 1 ).As.Months ).to.eq( 12 )
            end
        },
        {
            name = "Should handle all step-down conversions",
            func = function()
                expect( Time.Seconds( 60 ).As.Minutes ).to.eq( 1 )
                expect( Time.Minutes( 60 ).As.Hours ).to.eq( 1 )
                expect( Time.Hours( 24 ).As.Days ).to.eq( 1 )
                expect( Time.Days( 7 ).As.Weeks ).to.eq( 1 )
                expect( Time.Weeks( 4 ).As.Months ).to.eq( 1)
                expect( Time.Months( 12 ).As.Years ).to.eq( 1 )
            end
        },
        {
            name = "Should convert to timestamps",
            func = function()
                expect( Time.Seconds( os.time() ).As.Timestamp ).to.eq( os.time() )
            end
        },
        {
            name = "Should respond correctly to comparison operators",
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
            name = "Should respond correctly to equality operators",
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
            name = "Should be addable by ints",
            func = function()
                local a = Time.Seconds( 5 )

                expect( ( a + 10 ).As.Seconds ).to.eq( 15 )
            end
        },
        {
            name = "Should be addable by other TimeInstances",
            func = function()
                local a = Time.Minutes( 5 )
                local b = Time.Minutes( 10 )

                expect( ( a + b ).As.Minutes ).to.eq( 15 )
            end
        },
        {
            name = "Should be subtractable by ints",
            func = function()
                local a = Time.Seconds( 11 )
                expect( ( a - 5 ).As.Seconds ).to.eq( 6 )
            end
        },
        {
            name = "Should be subtractable by other TimeInstances",
            func = function()
                local a = Time.Minutes( 11 )
                local b = Time.Minutes( 5 )

                expect( ( a - b ).As.Minutes ).to.eq( 6 )
            end
        },
        {
            name = "Should be divisible by ints",
            func = function()
                local a = Time.Minutes( 10 )
                expect( ( a / 2 ).As.Minutes ).to.eq( 5 )
            end
        },
        {
            name = "Should be divisible by other TimeInstances",
            func = function()
                local a = Time.Hours( 10 )
                local b = Time.Minutes( 60 )
                expect( a / b ).to.eq( 10 )
            end
        },
        {
            name = "Should be multiplicable by ints",
            func = function()
                local a = Time.Minutes( 10 )
                expect( (a * 2).As.Minutes ).to.eq( 20 )
            end
        },
        {
            name = "Should respond to tostring",
            func = function()
                local a = Time.Seconds( 15 )
                expect( tostring( a ) ).to.eq( "TimeInstance [15 seconds]")
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

                expect( range ).to.beValid()
            end
        },
    }
}
