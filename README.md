## gm_timelib
### ⌛ A convenience library for working with Time in Garry's Mod

<br>

## Intro
Working with time [can be very tricky](https://www.youtube.com/watch?v=-5wpm-gesOY) in any language or environment.

Luckily a lot of the complicated stuff is handled (or irrelevant) for us  in Garry's Mod.
Still, timing is an important aspect of Garry's Mod. It's a hard subject to avoid.


Timeouts, cooldowns, timing calculations, time comparisons, etc. Eventually you'll find yourself calculating stuff with time.

`gm_timelib` aims to make this inevitable and relatively annoying task **easy**, **readable**, and **simple**.

`gm_timelib` offers structures and tools for handling:
 - **Time Instances** (a single moment in, or amount of time)
 - **Time Ranges** (a range of duration/times)

<details>
<summary><strong>🏫 Here are some examples:</strong></summary>
<br>

```lua
local extraTime = Time.Hours( 3 )

-- Extend a given ban's unban time by 3 hours
local function extendBan( ban )
    ban.unban = (ban.unban + extraTime).As.Timestamp
end
```

```lua
-- Throttle a function to once per second
local lastRun = Time.Now
local delay = (1).Second

local function _doStuff()
    -- Run expensive stuff
end

local function doStuff()
    if Time.Since( lastRun ) < delay then return end

    lastRun = Time.Now + delay
    return _doStuff()
end
```

```lua
-- Reward people who joined during an event

-- Create a TimeRange between two timestamps
local eventRange = event.Start .. event.End

local function checkPly( ply )
    local joinedAt = ply:TimeConnected().Seconds.Ago
    
    -- Check if joinedAt is inside the eventRange
    if eventRange[joinedAt] then
        ply:GiveMoney( 5000 )
        ply:ChatPrint( "Thanks for playing our event!" )
    end
end
```
</details>

## Installation
<details>
<summary>Basic Installation instructions</summary>
<br>

Simply [download](https://github.com/CFC-Servers/gm_time/archive/refs/heads/main.zip) or clone the repositry into your addons directory - all done!

You may also repackage this addon within your addon if you prefer, though I highly discourage this.

<details>
<summary>Click here to read my rant about re-packaging dependencies inside addons</summary>
<br>

Dependency management in Garry's Mod is garbage. If we had a proper system for dependency management, it would be a lot easier to share projects like this.

Popular libraries like [NetStream](https://github.com/alexgrist/NetStream) have been reasonably successful with their use in [Starfall](https://github.com/thegrb93/StarfallEx/blob/master/lua/autorun/netstream.lua) and others, but they hit an issue too: **How do you update it?**

They released netstream2 but not all of the developers who used the tool realized or bothered to update it.

So now what do you do when two addons use two different versions of netstream? It kind of sucks.

As-is, the best way to use lua libraries is to make them a dependency on your workshop page, and to print a good error if the dependency doesn't exist on the server.
</details>
</details>


## Usage

_[A full set of GLuaTest specs](https://github.com/CFC-Servers/gm_timelib/tree/main/lua/tests/gtimelib) have been included with this project. If you learn better by reading the code, I suggest you check them out_

### `TimeInstance`

#### A `TimeInstance` can be a certain _amount_ of time

Amounts of time can be created as follows:
```lua
Time.Seconds( 5 )
Time.Minutes( 10 )
Time.Hours( 15 )
Time.Days( 20 )
Time.Weeks( 25 )
Time.Months( 30 )
Time.Years( 35 )
```

You can also use the ~~cursed~~ other syntax:
```lua
(5).Seconds
(10).Minutes

local extraTime = 5
extraTime.Hours
```

#### They can also refer to a specific _moment_ in time

##### Until / Since
```lua
-- Until
local nextEvent = Time.Now + Time.Hours( 5 )
local timeRemaining = Time.Until( nextEvent )

-- Since
local lastEvent = Time.Now - Time.Hours( 3 )
local timeSince = Time.Since( lastEvent )
```

##### Ago / Hence
```lua
-- Ago
local fiveHoursAgo = os.time() - ( 5 * 60 * 60 )
-- These two line do the same thing
local timeInstance = (5).Hours.Ago

-- Hence
-- (The opposite of "ago")
local fiveHoursHence = os.time() + ( 5 * 60 * 60 )
-- Again, these two lines are effectively the same
local timeInstance = (5).Hours.Hence
```

#### A `TimeInstance` supports time-conversions too!
```lua
-- Supports "step-down" conversions
local a = Time.Minutes( 5 ).As.Seconds
assert( a == ( 5 * 60 ) )
```

```lua
-- Also supports "step-up" conversions
local a = Time.Minutes( 5 ).As.Hours
assert( a == ( 5 / 60 ) )
```

---
<br>

### Time Maths
#### A `TimeInstance` supports all basic mathematic operators

##### Addition / Subtraction
```lua
local a = Time.Hours( 2 ) + Time.Minutes( 5 )
assert( a.As.Seconds == (60 * 2) + 5 )

local a = Time.Minutes( 5 ) - Time.Minutes( 1 )
assert( a.As.Minutes == 4 )

-- Adding/subtracting normal integers works fine,
-- but the integers are treated as Seconds
local a = Time.Seconds( 10 ) + 10
assert( a.As.Seconds == 20 )
```

##### Multiplication / Division
```lua
local a = Time.Minutes( 5 ) * 2
assert( a.As.Minutes == 10 )

local a = Time.Hours( 5 ) / Time.Minutes( 60 )
assert( a == 5 )
```

#### You can also compare a `TimeInstance` against another
```lua
local a = Time.Minute( 5 )
local b = Time.Minute( 10 )
assert( a < b )

local a = Time.Minutes( 3 )
local b = Time.Minutes( 3 )
assert( a == b )
```

---
<br>


### `TimeRange`
A `TimeRange` describes a _duration_, or a range between two `TimeInstances`
```lua
local a = (5).Hours.Ago
local b = Time.Now
local range = a .. b -- You now have a TimeRange object!
```

#### TimeRange inclusion
You can check if a `TimeInstance` is contained within a `TimeRange`:
```lua
local range = (5).Hours.Ago .. Time.Now
local timeInstance = (10).Minutes.Ago

assert( range[timeInstance] == true )
```

You can also check if a `TimeRange` is entirely contained within another `TimeRange`:
```lua
local rangeA = (5).Hours.Ago .. Time.Now
local rangeB = (20).Minutes.Ago .. (5).Minutes.Ago

assert( rangeA[rangeB] == true )
```

---
<br>

### Advanced Tools

#### `Time.Basis`
When working with timestamps, sometimes you don't want to have everything be relative to `os.time()`.

There are some circumstances where something like `CurTime()` is more applicable to your situation.

You can actually create an entirely new `Time` object relative to your preferred time function. Take a look:
```lua
local MyTime = Time.Basis( CurTime )
assert( MyTime.Now == CurTime() )
```

This is a very flexible way to use a `Time` object. You can pass any function you want into `Time.Basis`:
```lua
local myTimeFunc = function() return 5 end
local MyTime = Time.Basis( myTimeFunc )

assert( MyTime.Now == 5 )
```

You can use your generated `Time` object the exact same way you use the normal `Time` object:
```lua
local MyTime = Time.Basis( CurTime )
MyTime.Seconds( 5 ) -- Still just 5 seconds, the same as `Time.Seconds( 5 )`
```

The only difference is the [relative time functions](https://github.com/CFC-Servers/gm_timelib#they-can-also-refer-to-a-specific-moment-in-time) will be based on the function you passed into `Basis`.
