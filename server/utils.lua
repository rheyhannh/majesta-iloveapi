-- #region Type Definitions

---@class MajestaHttpRequestReturnType
---@field code integer HTTP status codes.
---@field ok boolean Whether the request was successful.
---@field data any JSON-decoded response body if applicable, or raw string.
---@field headers table Table of response headers.

-- #endregion

--- Log debug message with formatted string and color.
--- @param msg string Message to be logged.
function LogDebug(msg)
    if Config.Debug then
        print("\27[34m[Debug]\27[0m " .. msg)
    end
end

--- Log warning message with formatted string and color.
--- @param msg string Message to be logged.
function LogWarn(msg)
    print("\27[33m[Warning]\27[0m " .. msg)
end

--- Log error message with formatted string and color.
--- @param msg string Message to be logged.
function LogError(msg)
    print("\27[31m[Error]\27[0m " .. msg)
end

--- Builds the request data to start a new ILoveApi task using the specified tool.
--- It returns a table containing the formatted `url` to start the task.
--- @param tool '"cropimage"' | '"upscaleimage"' | '"removebackgroundimage"' Tool to be used for the task.
function BuildStartReq(tool)
    local url = Config.StartUrl:format(tool)
    return { url = url }
end

--- Builds the request data to upload a file using the given task ID and cloud file reference.
--- It returns a table containing the `url` and `payload` to be used in the upload request.
--- @param server string The ILoveApi server subdomain (e.g., `api14g.iloveimg.com`).
--- @param task string The task ID received from the start request.
--- @param cloudFile string The cloud file path or URL to be uploaded.
function BuildUploadReq(server, task, cloudFile)
    local url = Config.UploadUrl:format(server)
    local payload = { task = task, cloud_file = cloudFile }
    return { url = url, payload = payload }
end

--- Builds the request data to process a task with optional tool parameters.
--- It returns a table containing the `url` and complete `payload` for the process request.
--- @param server string The ILoveApi server subdomain.
--- @param task string The task ID to be processed.
--- @param tool '"cropimage"' | '"upscaleimage"' | '"removebackgroundimage"' The tool type used to process the task.
--- @param filename string The original filename of the file being processed (for display or reference).
--- @param serverFilename string The internal server filename from the upload response.
--- @param useWebhook boolean Whether to include a webhook callback URL in the payload.
--- @param toolOpt table|nil Optional table of additional tool-specific parameters to merge into the payload.
function BuildProcessReq(server, task, tool, filename, serverFilename, useWebhook, toolOpt)
    local url = Config.ProcessUrl:format(server)
    local payload = {
        task = task,
        tool = tool,
        files = {
            {
                server_filename = serverFilename,
                filename = filename
            }
        }
    }

    if useWebhook then
        payload.webhook = ''
    end

    if toolOpt then
        for k, v in pairs(toolOpt) do
            if k ~= 'task' and k ~= 'tool' and k ~= 'files' then
                payload[k] = v
            end
        end
    end

    return { url = url, payload = payload }
end

--- Builds the request data to download the final processed result from ILoveApi.
--- It returns a table containing the `url` to fetch the processed file.
--- @param server string The ILoveApi server subdomain used throughout the process.
--- @param task string The task ID whose result should be downloaded.
function BuildDownloadReq(server, task)
    local url = Config.DownloadUrl:format(server, task)
    return { url = url }
end

--- Sends an HTTP request and returns a structured response object using `PerformHttpRequest`.
--- Automatically handles:
---  - HTTP method, body, and headers
---  - Promise-based async flow with `Citizen.Await`
---  - JSON decoding if the response content type is `application/json`
---  - `ok` flag set to `true` only for 2xx status codes
--- @param url string URL to send the request to.
--- @param method? string HTTP method, defaults to `"GET"`.
--- @param body? string Request body, defaults to an empty string.
--- @param headers? table Table of request headers, defaults to an empty table.
--- @return MajestaHttpRequestReturnType R Table containing response.
function MajestaHttpRequest(url, method, body, headers)
    local p = promise.new()

    PerformHttpRequest(url, function(code, data, responseHeaders)
        local success = code >= 200 and code < 300

        local contentType = ""
        for k, v in pairs(responseHeaders or {}) do
            if string.lower(k) == "content-type" then
                contentType = v
                break
            end
        end

        local decodedData = data
        if contentType:find("application/json") then
            local ok, result = pcall(json.decode, data)
            if ok then
                decodedData = result
            else
                success = false
            end
        end

        p:resolve({
            code = code,
            ok = success,
            data = decodedData,
            headers = responseHeaders
        })
    end, method or "GET", body or "", headers or {})

    return Citizen.Await(p)
end
