local Library = require "CoronaLibrary"

-- Create library
local lib = Library:new{ name='pubnativeSdk', publisherId='net.pubnative' }

-------------------------------------------------------------------------------
-- BEGIN (Insert your implementation starting here)
-------------------------------------------------------------------------------

-- This sample implements the following Lua:
--
--    local pubnativeSdk = require "plugin_pubnativeSdk"
--    pubnativeSdk.test()
--
lib.test = function()
	native.showAlert( 'Hello, World!', 'pubnativeSdk.test() invoked', { 'OK' } )
	print( 'Hello, World!' )
end

-------------------------------------------------------------------------------
-- END
-------------------------------------------------------------------------------

-- Return an instance
return lib
