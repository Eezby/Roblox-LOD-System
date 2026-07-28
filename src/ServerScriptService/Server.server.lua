local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LODSystem = require(ReplicatedStorage.LODSystem)

local configuration = LODSystem.Modules.Configuration.new()
:MaxStreamWaitTime(30)
:PersistantQualityVersion(0)
:LODAssetCollectionServiceTag("LODAsset")

LODSystem.Initialize(configuration)
