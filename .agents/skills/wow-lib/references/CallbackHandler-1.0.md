# CallbackHandler-1.0

A backend library that provides event/callback registry capabilities for other libraries or addons. It allows you to easily add `RegisterCallback` and `UnregisterCallback` methods to your own objects.

## Usage

```lua
-- Usually embedded into an addon or library
local MyAddon = {}
MyAddon.callbacks = LibStub("CallbackHandler-1.0"):New(MyAddon, "RegisterCallback", "UnregisterCallback", "UnregisterAllCallbacks")

-- Triggering a callback
function MyAddon:DoSomething()
    -- Fire the "OnSomethingHappened" event with arguments
    self.callbacks:Fire("OnSomethingHappened", "arg1", 123)
end

-- Listening to a callback (consumer)
local consumer = {}
function consumer:OnEvent(event, arg1, arg2)
    print(event, arg1, arg2)
end

MyAddon.RegisterCallback(consumer, "OnSomethingHappened", "OnEvent")
```
