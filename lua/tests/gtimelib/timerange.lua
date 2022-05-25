return {
    groupName = "TimeRange",
    cases = {
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
}
