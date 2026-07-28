# Setup
1. Initialize the module from ReplicatedStorage Packages via Wally.
- Must be initialized from both Client and Server

2. Ensure models are properly tagged using CollectionService with configuration tag name. Default is "LODAsset".
3. Ensure all tagged models have a Folder named "LODs" inside.
4. Each version of LOD must be named 0,1,2,3,4,... up to 63.
5. Use the configuration to set up a Persistent LOD (this always shows when the asset is streamed out). Default is quality version 0.

# Configuration

| Method | Description |
| --- | --- |
| `GetPlayerAssetQualityCallback(callback)` | Returns the quality version the player should load. Client only. |
| `MaxStreamWaitTime(seconds)` | How long the client waits for the requested version to replicate. |
| `PersistantQualityVersion(qualityVersion)` | Version that stays loaded while the asset is streamed out. |
| `LODAssetCollectionServiceTag(tag)` | Tag used to find LOD assets. |

# Quality versions

The callback decides which version a player loads, so any grouping of players is expressed by
returning a different number. An alternate take on an existing LOD is just another version: add a
model for it under `LODs` and return that number for the players who should see it.

```lua
local configuration = LODSystem.Modules.Configuration.new()
:GetPlayerAssetQualityCallback(function(player)
	if not UserInputService.TouchEnabled then
		return 2
	end

	-- Some mobile players load version 3 instead of version 1
	if isInTestGroup(player) then
		return 3
	end

	return 1
end)
```

Every tagged asset needs a model for the version the callback returns. If an asset is missing it, the
client waits `MaxStreamWaitTime` and then warns and shows only the persistent version, so keep the
returned versions in step with what the assets provide.

The callback runs on each stream in, so returning a value that changes between calls will load
different versions for different assets. Derive the result from something stable, such as the user id.
