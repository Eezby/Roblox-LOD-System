local HttpService = game:GetService("HttpService")

local LODVersion = require(script.Parent.LODVersion)

local LODAsset = {}
LODAsset.__index = LODAsset

local function createDetectorPart(asset: Model)
    local customStreamInDistance = asset:GetAttribute("StreamInDistance")

    local detectorPart = Instance.new("Part")
    detectorPart.Name = `{asset.Name}_StreamDetector`
    detectorPart.CanCollide = false
    detectorPart.CanTouch = false
    detectorPart.Transparency = 1
    detectorPart.Anchored = true
    detectorPart:PivotTo(asset:GetPivot())
    detectorPart:AddTag("LODSystemStreamDetector")
    detectorPart:SetAttribute("LODAssetID", asset:GetAttribute("LODAssetID"))

    if customStreamInDistance then
        local proximityPrompt = Instance.new("ProximityPrompt")
        proximityPrompt.Name = `CustomProximity`
        proximityPrompt.ActionText = ""
        proximityPrompt.ObjectText = ""
        proximityPrompt.RequiresLineOfSight = false
        proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
        proximityPrompt.ClickablePrompt = false
        proximityPrompt.Parent = detectorPart
    end

    detectorPart.Parent = workspace

    return detectorPart
end

function LODAsset.new(asset: Model)
    if not asset:IsA("Model") then
        error(`Asset is not a model: {asset:GetFullName()}`)
    end

    if not asset:FindFirstChild("LODs") then
        error(`Asset does not have a "LODs" folder: {asset:GetFullName()}`)
    end

    local self = setmetatable({
        asset = asset,
        guid = HttpService:GenerateGUID(false),
        detectorAsset = nil,
        lodVersions = {}
    }, LODAsset)

    self.asset:SetAttribute("LODAssetID", self.guid)
    self.detectorAsset = createDetectorPart(asset)

for _,lod in self.asset.LODs:GetChildren() do
        local lodVersion = LODVersion.new(lod)
        self.lodVersions[lodVersion.qualityVersion] = lodVersion
    end

    return self
end

function LODAsset:GetLod(qualityVersion: number)
    return self.lodVersions[qualityVersion]
end

function LODAsset:GetLods()
    return self.lodVersions
end

return LODAsset