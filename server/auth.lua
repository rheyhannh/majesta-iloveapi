local token = nil         --- @type nil|string Cached JWT token.
local iat = nil           --- @type nil|string Cached JWT token issued time (e.g. `'Fri Aug 01, 18:20:53'`).
local exp = nil           --- @type nil|string Cached JWT token expiration time (e.g. `'Fri Aug 01, 18:20:53'`).
local initialized = false --- @type boolean Flag indicating whether the JWT token has been initialized.

--- Internal method to fetch new JWT token from `ILoveApi` server.
local function _fetchToken()
    local payload = json.encode({
        public_key = Config.PublicKey,
    })

    PerformHttpRequest(Config.AuthUrl, function(statusCode, responseText, headers)
        if statusCode == 200 then
            local success, data = pcall(json.decode, responseText)
            if success and data.token then
                token = data.token
                iat = os.date("!%a %b %d, %H:%M:%S", os.time() + 7 * 60 * 60)
                exp = os.date("!%a %b %d, %H:%M:%S", os.time() + 8 * 60 * 60)
                LogDebug("Auth: Token refreshed successfully")

                if not initialized then
                    initialized = true
                end
            else
                LogError("Auth: Failed to parse token response")
            end
        else
            LogError(("Auth: Token request failed with status code %s"):format(statusCode))
        end
    end, 'POST', payload, {
        ["Content-Type"] = "application/json"
    })
end

-- Coroutine to handle token refresh.
CreateThread(function()
    _fetchToken()
    while true do
        -- Actually token expired after 1 hour, but we'll fetch new one every 55 minutes.
        -- This ensure every request you made will use valid token.
        Wait(60 * 55 * 1000)
        _fetchToken()
    end
end)

--- Get cached `IloveApi` JWT token including its issued and expiration time.
--- It returns a table containing the `iat` as token issued time, `exp` as token expiration time and `token` as the token itself.
function GetAuth()
    return { iat = iat, exp = exp, token = token }
end
