local metadata =
{
	plugin =
	{
		format = 'jar', -- Valid values are 'jar'
		manifest =
		{
			permissions = {},
			usesPermissions =
			{
				"android.permission.INTERNET",
				"android.permission.ACCESS_NETWORK_STATE",
			},
			usesFeatures = {},
			applicationChildElements =
			{
			},
		},
	},
}

return metadata
