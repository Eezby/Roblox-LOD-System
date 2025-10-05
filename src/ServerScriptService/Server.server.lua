local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LODSystem = require(ReplicatedStorage.LODSystem)

local configuration = LODSystem.Modules.Configuration.new()
:GetPlayerAssetQualityCallback(function()
    return 2
end)
:MaxStreamWaitTime(30)
:PersistantQualityVersion(0)
:LODAssetCollectionServiceTag("LODAsset")

LODSystem.Initialize(configuration)