-- Utils

--- Internal method to downloads an image from the given URL and saves it to a specific resource folder in the FiveM server.
---
--- This function uses `PerformHttpRequest` to perform a GET request, then stores the image using `SaveResourceFile`.
--- If the download is successful, the file is saved at the specified path within the given resource folder.
--- @param url string Direct URL to the image file to be downloaded.
--- @param headers table A table of optional request headers.
--- @param path? string Relative folder path inside the resource (should end with `/`). Use `nil`, to save on root of resource folder.
--- @param filename string Desired file name (with extension) for the saved image (e.g., `'result.jpg'`).
--- @param resourceName string Name of the target resource where the image should be saved.
local function _downloadImage(url, headers, path, filename, resourceName)
    -- TODO: Sanitize params.
    PerformHttpRequest(url, function(status, data, resHeaders)
        local fullPath = nil
        if status ~= 200 then
            LogError(('Failed to download processed image (HTTP code: %s)'):format(status))
            return
        end

        if path then
            fullPath = path .. filename
        else
            fullPath = filename
        end

        local success = SaveResourceFile(resourceName, fullPath, data, #data)
        if success then
            LogDebug(('Downloaded processed image to: %s'):format(fullPath))
        else
            LogError(('Failed to download processed image: %s'):format(fullPath))
        end
    end, "GET", "", headers)
end

-- Cores

--- Executes a complete image cropping flow using ILoveApi:
--- 1. Starts a `cropimage` task,
--- 2. Uploads the image from the provided URL,
--- 3. Processes it with the specified crop dimensions,
--- 4. Downloads the processed image to the specified `resourceName` folder and `path` **if no callback is provided**.
---
--- If a `cb` (callback function) is provided, the download step will be skipped and the callback will receive the result data
--- so you can handle it on your way.
---
--- @param imageUrl string URL of the image to be processed.
--- @param path? string Folder path to store the processed image (should end with `/`, e.g., `'results/'`).
--- @param filename string Name of the output file including its extension (e.g., `'result.jpg'`).
--- @param resourceName? string Name of the resource folder to save the file in (e.g., `'my-resource'`).
--- @param width integer Crop width in pixels.
--- @param height integer Crop height in pixels.
--- @param x? integer X-coordinate of the crop origin (default: `0`).
--- @param y? integer Y-coordinate of the crop origin (default: `0`).
--- @param cb? function Callback to handle the result manually instead of triggering the download.
function CropImageSync(imageUrl, path, filename, resourceName, width, height, x, y, cb)
    -- TODO: Sanitize params.
    resourceName = resourceName or GetCurrentResourceName()
    local server = nil
    local task = nil
    local serverFilename = nil
    local downloadFilename = nil
    local remainingFiles = nil
    local remainingCredits = nil
    local filesize = nil
    local outputFilesize = nil
    local timer = nil
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. GetAuth().token
    }

    -- Start the task.
    local start = MajestaHttpRequest(BuildStartReq('cropimage').url, 'GET', nil, headers)

    if not start.ok then
        LogError(('Failed to crop image when starting task (HTTP code: %s)'):format(start.code))
        return
    end

    LogDebug('Successfully initating crop image task')
    LogDebug(json.encode(start.data, { indent = true }))
    server = start.data.server
    task = start.data.task
    remainingFiles = start.data.remaining_files
    remainingCredits = start.data.remaining_credits

    -- Upload the image.
    local uploadSetup = BuildUploadReq(server, task, imageUrl)
    local upload = MajestaHttpRequest(uploadSetup.url, 'POST', json.encode(uploadSetup.payload), headers)

    if not upload.ok then
        LogError(('Failed to crop image when uploading image (HTTP code: %s)'):format(upload.code))
        return
    end

    LogDebug('Successfully uploading image for crop image task')
    LogDebug(json.encode(upload.data, { indent = true }))
    serverFilename = upload.data.server_filename

    -- Start the task.
    local toolOpt = { width = width, height = height, x = x or 0, y = y or 0 }
    local processSetup = BuildProcessReq(server, task, 'cropimage', filename, serverFilename, false, toolOpt)
    local process = MajestaHttpRequest(processSetup.url, 'POST', json.encode(processSetup.payload), headers)

    if not process.ok then
        LogError(('Failed to crop image when processing task (HTTP code: %s)'):format(upload.code))
        return
    end

    LogDebug('Successfully processing image for crop image task')
    LogDebug(json.encode(process.data, { indent = true }))
    downloadFilename = process.data.download_filename or filename
    filesize = process.data.filesize
    outputFilesize = process.data.output_filesize
    timer = process.data.timer

    local downloadSetup = BuildDownloadReq(server, task)

    if type(cb) == 'function' then
        cb(downloadSetup.url, {
            token = GetAuth().token, -- Ensure its valid token by re-calling getter.
            server = server,
            task = task,
            remainingFiles = remainingFiles,
            remainingCredits = remainingCredits,
            serverFilename = serverFilename,
            downloadFilename = downloadFilename,
            filesize = filesize,
            outputFilesize = outputFilesize,
            timer = timer
        })
    else
        _downloadImage(downloadSetup.url, headers, path, downloadFilename, resourceName)
    end
end

exports('CropImageSync', function(imageUrl, path, filename, resourceName, width, height, x, y, cb)
    CropImageSync(imageUrl, path, filename, resourceName, width, height, x, y, cb)
end)

--- Executes a complete image background removal flow using ILoveApi:
--- 1. Starts a `removebackgroundimage` task,
--- 2. Uploads the image from the provided URL,
--- 3. Processes it with removing background image,
--- 4. Downloads the processed image to the specified `resourceName` folder and `path` **if no callback is provided**.
---
--- If a `cb` (callback function) is provided, the download step will be skipped and the callback will receive the result data
--- so you can handle it on your way.
---
--- @param imageUrl string URL of the image to be processed.
--- @param path? string Folder path to store the processed image (should end with `/`, e.g., `'results/'`).
--- @param filename string Name of the output file including its extension (e.g., `'result.jpg'`).
--- @param resourceName? string Name of the resource folder to save the file in (e.g., `'my-resource'`).
--- @param cb? function Callback to handle the result manually instead of triggering the download.
function RemoveBackgroundImageSync(imageUrl, path, filename, resourceName, cb)
    -- TODO: Sanitize params.
    resourceName = resourceName or GetCurrentResourceName()
    local server = nil
    local task = nil
    local serverFilename = nil
    local downloadFilename = nil
    local remainingFiles = nil
    local remainingCredits = nil
    local filesize = nil
    local outputFilesize = nil
    local timer = nil
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. GetAuth().token
    }

    -- Start the task.
    local start = MajestaHttpRequest(BuildStartReq('removebackgroundimage').url, 'GET', nil, headers)

    if not start.ok then
        LogError(('Failed to remove background image when starting task (HTTP code: %s)'):format(start.code))
        return
    end

    LogDebug('Successfully initating remove background image task')
    LogDebug(json.encode(start.data, { indent = true }))
    server = start.data.server
    task = start.data.task
    remainingFiles = start.data.remaining_files
    remainingCredits = start.data.remaining_credits

    -- Upload the image.
    local uploadSetup = BuildUploadReq(server, task, imageUrl)
    local upload = MajestaHttpRequest(uploadSetup.url, 'POST', json.encode(uploadSetup.payload), headers)

    if not upload.ok then
        LogError(('Failed to remove background image when uploading image (HTTP code: %s)'):format(upload.code))
        return
    end

    LogDebug('Successfully uploading image for remove background image task')
    LogDebug(json.encode(upload.data, { indent = true }))
    serverFilename = upload.data.server_filename

    -- Start the task.
    local processSetup = BuildProcessReq(server, task, 'removebackgroundimage', filename, serverFilename, false)
    local process = MajestaHttpRequest(processSetup.url, 'POST', json.encode(processSetup.payload), headers)

    if not process.ok then
        LogError(('Failed to remove background image when processing task (HTTP code: %s)'):format(upload.code))
        return
    end

    LogDebug('Successfully processing image for remove background image task')
    LogDebug(json.encode(process.data, { indent = true }))
    downloadFilename = process.data.download_filename or filename
    filesize = process.data.filesize
    outputFilesize = process.data.output_filesize
    timer = process.data.timer

    local downloadSetup = BuildDownloadReq(server, task)

    if type(cb) == 'function' then
        cb(downloadSetup.url, {
            token = GetAuth().token, -- Ensure its valid token by re-calling getter.
            server = server,
            task = task,
            remainingFiles = remainingFiles,
            remainingCredits = remainingCredits,
            serverFilename = serverFilename,
            downloadFilename = downloadFilename,
            filesize = filesize,
            outputFilesize = outputFilesize,
            timer = timer
        })
    else
        _downloadImage(downloadSetup.url, headers, path, downloadFilename, resourceName)
    end
end

exports('RemoveBackgroundImageSync', function(imageUrl, path, filename, resourceName, cb)
    RemoveBackgroundImageSync(imageUrl, path, filename, resourceName, cb)
end)
