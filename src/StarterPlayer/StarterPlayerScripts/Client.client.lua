local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LODSystem = require(ReplicatedStorage:WaitForChild("LODSystem"))

local configuration = LODSystem.Modules.Configuration.new()
:GetPlayerAssetQualityCallback(function()
    if UserInputService.TouchEnabled then
        return 1
    end

    return 2
end)
:MaxStreamWaitTime(30)
:PersistantQualityVersion(0)
:LODAssetCollectionServiceTag("LODAsset")

LODSystem.Initialize(configuration)
