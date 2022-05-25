return {
    groupName = "Relative time functions",
    cases = {
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
            name = "Time.Basis should return a new Time object with the given basis function",
            func = function()
                local NewBasis = function() return 1 end
                expect( Time.Basis( NewBasis )._basis ).to.eq( NewBasis )
                expect( Time.Basis( NewBasis ).Now.As.Seconds ).to.eq( 1 )
            end
        },
    }
}
