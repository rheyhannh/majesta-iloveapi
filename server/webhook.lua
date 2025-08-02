-- Utils

local function getDetails()
    -- TODO: Also retrieve tasks list.
    local auth = GetAuth()
    return {
        auth = auth
    }
end

--- Internal method to validates if all required properties exist in the given request body table.
--- Returns a string message listing missing properties, or `false` if all required fields are present.
--- @param requiredProps table<number, string> List of required property names.
--- @param body table Request body to validate.
local function _isRequestBodyInvalid(requiredProps, body)
    local missing = {}

    for _, prop in ipairs(requiredProps) do
        if body[prop] == nil then
            table.insert(missing, prop)
        end
    end

    local count = #missing
    if count == 0 then
        return false
    elseif count == 1 then
        return ("Missing required field: '%s'"):format(missing[1])
    else
        return ("Missing required field: ['%s']"):format(table.concat(missing, "', '"))
    end
end

-- Webhook Handler

if Config.UseWebhook then
    SetHttpHandler(function(req, res)
        if req.path == Config.WebhookPath .. '/details' and req.method == "GET" then
            LogDebug(("Webhook: Received %s %s request from %s"):format(req.method, req.path, req.address))

            res.writeHead(200, { ["Content-Type"] = "application/json" })
            res.send(json.encode({ ok = true, code = 200, data = getDetails() }, { indent = false, sort_keys = false }))
        elseif req.path == Config.WebhookPath .. '/cropimage' and req.method == 'POST' then
            local body = ""
            req.setDataHandler(function(chunk) body = body .. chunk end)
            local success, data = pcall(json.decode, body)
            if not success then
                res.writeHead(400, { ["Content-Type"] = "application/json" })
                res.send(json.encode({ ok = false, code = 400, msg = "Invalid JSON" },
                    { indent = false, sort_keys = false }))
                return
            end

            LogDebug(("Webhook: Received %s %s request from [%s]"):format(req.method, req.path, req.address))
            LogDebug(json.encode(data, { indent = true }))

            local invalidData = _isRequestBodyInvalid({ 'image_url', 'filename', 'width', 'height' }, data)

            if invalidData then
                res.writeHead(400, { ["Content-Type"] = "application/json" })
                res.send(json.encode({ ok = false, code = 400, msg = invalidData },
                    { indent = false, sort_keys = false }))
                return
            end

            CropImageSync(
                data.image_url,
                data.path or nil,
                data.filename,
                data.resource_name or nil,
                data.width,
                data.height,
                data.x or 0,
                data.y or 0,
                nil
            )

            res.writeHead(200, { ["Content-Type"] = "application/json" })
            res.send(json.encode({ ok = true, code = 200 }, { indent = false, sort_keys = false }))
        elseif req.path == Config.WebhookPath .. '/removebackgroundimage' and req.method == 'POST' then
            local body = ""
            req.setDataHandler(function(chunk) body = body .. chunk end)
            local success, data = pcall(json.decode, body)
            if not success then
                res.writeHead(400, { ["Content-Type"] = "application/json" })
                res.send(json.encode({ ok = false, code = 400, msg = "Invalid JSON" },
                    { indent = false, sort_keys = false }))
                return
            end

            LogDebug(("Webhook: Received %s %s request from [%s]"):format(req.method, req.path, req.address))
            LogDebug(json.encode(data, { indent = true }))

            local invalidData = _isRequestBodyInvalid({ 'image_url', 'filename' }, data)

            if invalidData then
                res.writeHead(400, { ["Content-Type"] = "application/json" })
                res.send(json.encode({ ok = false, code = 400, msg = invalidData },
                    { indent = false, sort_keys = false }))
                return
            end

            RemoveBackgroundImageSync(
                data.image_url,
                data.path or nil,
                data.filename,
                data.resource_name or nil,
                nil
            )

            res.writeHead(200, { ["Content-Type"] = "application/json" })
            res.send(json.encode({ ok = true, code = 200 }, { indent = false, sort_keys = false }))
        else
            LogWarn(("Webhook: Received %s %s request from [%s]"):format(req.method, req.path, req.address))

            res.writeHead(404, { ["Content-Type"] = "application/json" })
            res.send(json.encode({ ok = false, code = 404, msg = 'Route not found' },
                { indent = false, sort_keys = false }))
        end
    end)
end
