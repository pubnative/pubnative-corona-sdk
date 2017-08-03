local Library = require "CoronaLibrary"

-- Create library
local lib = Library:new{ name='plugin.pubnative', publisherId='net.pubnative' }

-------------------------------------------------------------------------------
-- BEGIN (Insert your implementation starting here)
-------------------------------------------------------------------------------

lib.init = function()
	native.showAlert( 'Success!', 'pubnativeSdk.init() invoked', { 'OK' } )
	print( 'Success!' )
end

lib.show = function()
	native.showAlert( 'Success!', 'pubnativeSdk.show() invoked', { 'OK' } )
	print( 'Success!' )
end

lib.hide = function()
	native.showAlert( 'Success!', 'pubnativeSdk.hide() invoked', { 'OK' } )
	print( 'Success!' )
end

-------------------------------------------------------------------------------
-- END
-------------------------------------------------------------------------------

-- Return an instance
return lib
