Config = {}

-- Enable debug mode (set to `false` to disable debug logs).
-- This will log all debug messages, note that warning and error message will still be logged even if debug mode is disabled.
Config.Debug = true

-- Enable logging to file (set to `false` to disable).
-- This will logs every process and transactions (including the failed) you made to ILoveApi servers,
-- allowing you to track your transactions and debug your script.
Config.Log = true

-- Your ILoveApi public key.
-- You must set this in your `server.cfg` using: set iloveapi_public_key "your_public_key"
Config.PublicKey = GetConvar("iloveapi_public_key", "")

-- URL template to request an authentication token from ILoveApi
Config.AuthUrl = 'https://api.iloveimg.com/v1/auth'

-- URL template to start a new task. Replace `%s` with the tool type (e.g., "cropimage", "removebackgroundimage").
Config.StartUrl = 'https://api.iloveimg.com/v1/start/%s'

-- URL template to upload a file. Replace `%s` with the subdomain received from the start task (e.g., "api14g.iloveimg.com").
Config.UploadUrl = 'https://%s/v1/upload'

-- URL template to process the task. Replace `%s` with the ILoveApi subdomain.
Config.ProcessUrl = 'https://%s/v1/process'

-- URL template to download the processed result.
-- First `%s` is the ILoveApi subdomain, second `%s` is the task ID.
Config.DownloadUrl = 'https://%s/v1/download/%s'

-- Webhook endpoint path that handles incoming requests from ILoveApi.
-- Set this in your `server.cfg` using: set iloveapi_webhook_path "/your_path"
Config.WebhookPath = GetConvar("iloveapi_webhook_path", "/webhook")
