local HttpService = game:GetService("HttpService")

local LODVersion = {}
LODVersion.__index = LODVersion

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
        replicationFocusPart = asset.PrimaryPart or asset:FindFirstChildWhichIsA("BasePart")
    }, LODVersion)

    self.asset:SetAttribute("LODVersionID", self.guid)
    self.asset:SetAttribute("OriginalCFrame", self.asset:GetPivot())

    return self
end

return LODVersion