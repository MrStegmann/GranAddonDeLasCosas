# LibStub

The universal library version manager for World of Warcraft addons. It ensures that only the newest version of a library is loaded into memory, even if multiple addons bundle different versions of the same library.

## Usage

### Getting a library
```lua
local lib = LibStub("LibraryName-1.0")
```

### Getting a library silently (no error if missing)
```lua
local lib = LibStub("LibraryName-1.0", true)
```

### Registering a library (for library authors)
```lua
local MAJOR, MINOR = "MyLibrary-1.0", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- already loaded a newer or equal version

-- define library API
lib.DoSomething = function(self) print("Hello!") end
```
