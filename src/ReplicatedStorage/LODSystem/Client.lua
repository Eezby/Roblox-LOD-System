local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(script.Parent.Constants)
local Configuration = require(script.Parent.Configuration)

local LODSystemClient = {}
LODSystemClient.Remote = nil
LODSystemClient.Ran = false
LODSystemClient.Debug = false
LODSystemClient.Configuration = nil

local function debugPrint(...)
    if not LODSystemClient.Debug then return end
    print("🔵[LODSystemClient] ", ...)
end

function LODSystemClient.Initialize(configuration: Configuration.LODSystemConfiguration?)
    if not RunService:IsClient() then
        if true then return end
        error("LODSystem.Client can only be called on the client")
    end

    if workspace.ModelStreamingBehavior == Enum.ModelStreamingBehavior.Improved then
        error("LODSystem.Client.FrameworkStart can only be called if the ModelStreamingBehavior is on Default or Legacy")
    end

    if LODSystemClient.Ran then return end
    LODSystemClient.Ran = true

    if not configuration then
        configuration = Configuration.new()
    end

    LODSystemClient.Configuration = configuration

    Constants.MAX_STREAM_WAIT_TIME = configuration.maxStreamWaitTime
    Constants.PERSISTANT_QUALITY_VERSION = configuration.persistantQualityVersion
    Constants.LOD_ASSET_COLLECTION_SERVICE_TAG = configuration.lodAssetCollectionServiceTag
    Constants.MAX_STREAM_WAIT_TIME = configuration.maxStreamWaitTime

    LODSystemClient.Remote = ReplicatedStorage:WaitForChild("LODSystemRemote")
    LODSystemClient.Setup()
end

-- Called by client to setup the LODSystem, loads the initial asset versions and sets up listeners for stream detectors
function LODSystemClient.Setup()
    CollectionService:GetInstanceAddedSignal("LODSystemStreamDetector"):Connect(function(detector: Part)
        LODSystemClient.LoadLODAssetVersion(detector:GetAttribute("LODAssetID"), LODSystemClient.GetQualityVersion())
    end)

    CollectionService:GetInstanceRemovedSignal("LODSystemStreamDetector"):Connect(function(detector: Part)
        LODSystemClient.UnloadLODAssetVersion(detector:GetAttribute("LODAssetID"))
    end)

    for _,detector in CollectionService:GetTagged("LODSystemStreamDetector") do
        task.spawn(LODSystemClient.LoadLODAssetVersion, detector:GetAttribute("LODAssetID"), LODSystemClient.GetQualityVersion())
    end

    debugPrint("LODSystemClient.Setup()")
end

-- Called by client to load the asset version, fires a remote event to the server
-- Client waits for the asset to appear before confirming that the asset has been streamed in
function LODSystemClient.LoadLODAssetVersion(id: string, qualityVersion: number)
    debugPrint(`Loading asset {id} [{qualityVersion}]`)

    LODSystemClient.Remote:FireServer("RequestStreamIn", id, qualityVersion)

    local asset = LODSystemClient.GetLODAsset(id)
    local existingLODVersion = asset.LODs:FindFirstChild(qualityVersion)
    if not existingLODVersion then
        existingLODVersion = asset.LODs:WaitForChild(qualityVersion, Constants.MAX_STREAM_WAIT_TIME)

        if not existingLODVersion then
            warn(`Asset {id} [{qualityVersion}] did not appear after {Constants.MAX_STREAM_WAIT_TIME} seconds`)
            return
        end
    end

    LODSystemClient.HidePersistentLODAsset(id)
    existingLODVersion:PivotTo(existingLODVersion:GetAttribute("OriginalCFrame"))

    LODSystemClient.Remote:FireServer("ConfirmStreamIn", id, qualityVersion)
end

-- Called by client when the stream detector streams out
-- Replaces the existing asset with the persistent version
function LODSystemClient.UnloadLODAssetVersion(id: string)
    local persistentLODVersion = LODSystemClient.GetLODVersion(id, Constants.PERSISTANT_QUALITY_VERSION)
    if not persistentLODVersion then
        LODSystemClient.LoadLODAssetVersion(id, Constants.PERSISTANT_QUALITY_VERSION)
    end

    LODSystemClient.ShowPersistentLODAsset(id)
    debugPrint(`Unloaded asset {id}, replaced with persistent version`)
end

-- When non-persistent asset is loaded, hides the persistent version
-- Hides the persistent asset
function LODSystemClient.HidePersistentLODAsset(id: string)
    local lodVersion = LODSystemClient.GetLODVersion(id, Constants.PERSISTANT_QUALITY_VERSION)
    if not lodVersion then return end

    lodVersion:PivotTo(CFrame.new(0, 1000000, 0))
    debugPrint(`Hidden persistent asset {id}`)
end

-- When non-persistent asset is un-loaded, shows the persistent version
-- Shows the persistent asset
function LODSystemClient.ShowPersistentLODAsset(id: string)
    local lodVersion = LODSystemClient.GetLODVersion(id, Constants.PERSISTANT_QUALITY_VERSION)
    if not lodVersion then return end

    lodVersion:PivotTo(lodVersion:GetAttribute("OriginalCFrame"))
    debugPrint(`Shown persistent asset {id}`)
end

function LODSystemClient.GetLODAsset(id: string)
    local lodAssets = CollectionService:GetTagged(Constants.LOD_ASSET_COLLECTION_SERVICE_TAG)
    for _,asset in lodAssets do
        if asset:GetAttribute("LODAssetID") == id then
            return asset
        end
    end

    return nil
end

function LODSystemClient.GetLODVersion(id: string, qualityVersion: number)
    local asset = LODSystemClient.GetLODAsset(id)
    return asset.LODs:FindFirstChild(qualityVersion)
end

function LODSystemClient.GetQualityVersion()
    return LODSystemClient.Configuration.getPlayerAssetQualityCallback(Players.LocalPlayer)
end

return LODSystemClient