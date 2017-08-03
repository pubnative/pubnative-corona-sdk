local metadata =
{
	plugin =
	{
		format = 'staticLibrary',

		-- This is the name without the 'lib' prefix.
		-- In this case, the static library is called: libPubnative.a
		staticLibs = { 'pubnative', },

		frameworks = {},
		frameworksOptional = {},
	},
	coronaManifest = {
		dependencies = {
			-- Example dependencies:
			--["plugin.memoryBitmap"] = "com.coronalabs",
		},
	},
}

return metadata
