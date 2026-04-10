local HttpService = game:GetService("HttpService")

local LODVersion = {}
LODVersion.__index = LODVersion

local ORIGINAL_CFRAME_ATTRIBUTE_NAME = "OriginalCFrame"

local function setOriginalCFrameAttributes(asset: Model)
	for _, descendant in asset:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		descendant:SetAttribute(ORIGINAL_CFRAME_ATTRIBUTE_NAME, descendant.CFrame)
	end
end

function LODVersion.new(asset: Model)
    if not asset:IsA("Model") then
        error(`Asset is not a model: {asset:GetFullName()}`)
    end

    if tonumber(asset.Name) == nil then
        error(`Asset version is not a number: {asset:GetFullName()}`)
    end

    local self = setmetatable({
        asset = asset,
        qualityVersion = tonumber(asset.Name),
        guid = HttpService:GenerateGUID(false),
        replicationFocusPart = asset.PrimaryPart or asset:FindFirstChildWhichIsA("BasePart", true)
    }, LODVersion)

    self.asset:SetAttribute("LODVersionID", self.guid)
    setOriginalCFrameAttributes(self.asset)

    return self
end

return LODVersion