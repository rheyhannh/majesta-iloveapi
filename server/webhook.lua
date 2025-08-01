local function getDetails()
    local auth = GetAuth()
    return {
        auth = auth
    }
end

SetHttpHandler(function(req, res)
    if req.path == Config.WebhookPath .. '/details' and req.method == "GET" then
        LogDebug(("Webhook: Received %s %s request from %s"):format(req.method, req.path, req.address))

        res.writeHead(200, { ["Content-Type"] = "application/json" })
        res.send(json.encode({ ok = true, data = getDetails() }, { indent = false, sort_keys = false }))
    elseif req.path == Config.WebhookPath .. '/cropimage' and req.method == 'POST' then
        local body = ""
        req.setDataHandler(function(chunk) body = body .. chunk end)
        local success, data = pcall(json.decode, body)
        if not success then
            res.send("Invalid JSON")
            return
        end

        if not data.imageUrl then
            res.writeHead(400, { ["Content-Type"] = "application/json" })
            res.send(json.encode({ ok = false, msg = "Missing required field: 'imageUrl'" },
                { indent = false, sort_keys = false }))
            return
        end

        local imageUrl = data.imageUrl

        LogDebug(("Webhook: Received %s %s request from %s"):format(req.method, req.path, req.address))
        LogDebug(json.encode(data, { indent = true }))

        CropImageSync(imageUrl, 'images/', 'test_crop.jpg', 'es-idcard', 237, 299, 785, 255)

        res.writeHead(200, { ["Content-Type"] = "application/json" })
        res.send(json.encode({ ok = true }, { indent = false, sort_keys = false }))
    elseif req.path == Config.WebhookPath .. '/removebackgroundimage' and req.method == 'POST' then
        local body = ""
        req.setDataHandler(function(chunk) body = body .. chunk end)
        local success, data = pcall(json.decode, body)
        if not success then
            res.send("Invalid JSON")
            return
        end

        if not data.imageUrl then
            res.writeHead(400, { ["Content-Type"] = "application/json" })
            res.send(json.encode({ ok = false, msg = "Missing required field: 'imageUrl'" },
                { indent = false, sort_keys = false }))
            return
        end

        local imageUrl = data.imageUrl

        LogDebug(("Webhook: Received %s %s request from %s"):format(req.method, req.path, req.address))
        LogDebug(json.encode(data, { indent = true }))

        RemoveBackgroundImageSync(imageUrl, 'images/', 'test_removebg.png', 'es-idcard')

        res.writeHead(200, { ["Content-Type"] = "application/json" })
        res.send(json.encode({ ok = true }, { indent = false, sort_keys = false }))
    else
        LogWarn(("Webhook: Received %s %s request from %s"):format(req.method, req.path, req.address))

        res.writeHead(404, { ["Content-Type"] = "application/json" })
        res.send(json.encode({ ok = false, msg = 'Route not found' }, { indent = false, sort_keys = false }))
    end
end)
