## 📝 Description

`majesta-iloveapi` is a **FiveM (GTA V)** server-side resource that lets you process images automatically using [ILoveApi](https://www.iloveapi.com/). With it, you can easily do tasks like:
- ✂️ Cropping images to a fixed size
- 🖼️ Removing image backgrounds (e.g. player mugshots)

> ⚠️ This is **not** a plug-and-play resource. It’s a development utility — meant to be integrated into your server scripts. You'll need some basic Lua and FiveM scripting knowledge to make it work in your setup.

## 🙋🏻‍♂️ Who Is This For?

This resource is best suited for:
- Developers creating character ID cards, mugshot systems, or other image-related features.
- Server owners or developers who want to automate image processing inside FiveM.

> If you're **not familiar with Lua scripting**, you might need a developer to help integrate it.

## 🔥 Features

| Feature                | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| **Crop**         | Automatically crop images to a specific width, height, and position (X, Y) |
| **Remove Background**  | Automatically remove the background of an image while keeping the subject (like player mugshots) |

## 🌟 Example Results

<p align="center">
  <img src="https://github.com/rheyhannh/majesta-iloveapi/blob/master/assets/images/example_plain.jpg" alt="Example Plain" width="350"/>
  <br/>
  <em>Plain Image</em>
</p>

<p align="center">
  <img src="https://github.com/rheyhannh/majesta-iloveapi/blob/master/assets/images/example_result_crop.jpg" alt="Example Result Crop" width="150"/>
  <br/>
  <em>Cropped Image</em>
</p>

<p align="center">
  <img src="https://github.com/rheyhannh/majesta-iloveapi/blob/master/assets/images/example_result_removebg.png" alt="Example Result Remove Background" width="150"/>
  <br/>
  <em>Removed Background Image</em>
</p>

## 🚀 How It Works

This resource acts as a **bridge between your server and [ILoveApi](https://www.iloveapi.com/docs/api-reference#introduction)**.

Here’s what it handles:
1. 🔐 [**Authentication**](https://www.iloveapi.com/docs/api-reference#authentication) to ILoveApi using JWT (no manual setup needed).
2. 📤 [**Upload**](https://www.iloveapi.com/docs/api-reference#upload) your image to ILoveApi servers.
3. ⚙️ [**Process**](https://www.iloveapi.com/docs/api-reference#process) the task based on your usage (crop, remove background, etc).
4. 📥 [**Download**](https://www.iloveapi.com/docs/api-reference#download) the result image back into your server under a specified folder and filename.

### What You Need to Provide:
- **URL of the image** you want to process.
- **Action** (crop, remove background).
- Required and optional settings like:
  - Crop dimensions (width, height, X, Y)
  - Where to save the final image (resource name, folder, and filename)

## 💡 How to Use

Before using this resource, you need to sign up on the [ILoveApi](https://www.iloveapi.com/signup) developer site to get your project’s public key (**Note**: ILoveApi has usage [plans](https://www.iloveapi.com/pricing) with limitations on the number of files and credits available).
After registering, log in and go to the [Projects](https://www.iloveapi.com/user/projects) page. You’ll see your project along with its **public key** and **secret key**. Copy the public key, then follow the steps below:

1. Open your `server.cfg` and add:
   ```cfg
   set iloveapi_public_key "your_public_key"
   ```
2. (_Optional_) You can also set a custom webhook path:
   ```cfg
   set iloveapi_webhook_path "/your_path"
   ```
3. Go to the [GitHub Releases](https://github.com/rheyhannh/majesta-iloveapi/releases), download the **latest version** of the code.
5. Add the **majesta-iloveapi** folder to your server’s `resources` directory. Make sure to `ensure` this resource **before** any other resource that uses its exports.
6. (_Optional_) Adjust any [**Configurations**](https://github.com/rheyhannh/majesta-iloveapi?tab=readme-ov-file#%EF%B8%8F-configurations--sv_configlua) you want to change on `sv_config.lua`
7. To test its functionality:
   - Refer to the [**Webhook API**](https://github.com/rheyhannh/majesta-iloveapi?tab=readme-ov-file#-webhook-api--webhooklua) section for instructions on testing with tools like [Postman](https://www.postman.com/).  
   - Or directly use the [**Exports API**](https://github.com/rheyhannh/majesta-iloveapi?tab=readme-ov-file#-exports-api---serverlua) by calling the provided Lua functions.

## ⚙️ Configurations — [`sv_config.lua`](https://github.com/rheyhannh/majesta-iloveapi/blob/master/shared/sv_config.lua)

| **Name**        | **Configurable** | **Type**    | **Description** |
|-----------------|------------------|-------------|-----------------|
| `Debug`         | ✅ Yes            | `boolean`   | Enables or disables debug messages. When enabled, all debug logs will be printed with formatting and colors. Warnings and errors are **always shown**, regardless of this setting. |
| `Log`           | ✅ Yes            | `boolean`   | Enables or disables logging to a JSON file. This logs all processes and transactions (including failures), which is useful for debugging and tracking activities. |
| `PublicKey`     | ❌ No             | `string`    | Your ILoveApi project public key. **Do not hardcode this.** Set it via `server.cfg` using: `set iloveapi_public_key "your_public_key"`. |
| `AuthUrl`       | ❌ No             | `string`    | Internal formated URL used to request a JWT token from ILoveApi servers. Leave unchanged unless you're forking the resource and implementing a custom flow. |
| `StartUrl`      | ❌ No             | `string`    | Internal formated URL used to initiate a task with ILoveApi servers. Leave unchanged unless you're forking the resource and implementing a custom flow. |
| `UploadUrl`     | ❌ No             | `string`    | Internal formated URL used to upload files to ILoveApi servers. Leave unchanged unless you're forking the resource and implementing a custom flow. |
| `ProcessUrl`    | ❌ No             | `string`    | Internal formated URL used to process tasks and uploaded files on ILoveApi servers. Leave unchanged unless you're forking the resource and implementing a custom flow. |
| `DownloadUrl`   | ❌ No             | `string`    | Internal formated URL used to download processed files from ILoveApi servers. Leave unchanged unless you're forking the resource and implementing a custom flow. |
| `UseWebhook`    | ✅ Yes            | `boolean`   | Enables or disables webhook support. When enabled, you can test image processing, retrieve JWT info, and list all tasks via your server. See the [**Webhook API**](https://github.com/rheyhannh/majesta-iloveapi?tab=readme-ov-file#-webhook-api--webhooklua) section below for details. |
| `WebhookPath`   | ❌ No            | `string`    | Custom path for the webhook endpoint. Default is `/webhook`. **For security, set this in `server.cfg`** using: `set iloveapi_webhook_path "/your_path"`. |

## ⚡ Exports API - [`server.lua`](https://github.com/rheyhannh/majesta-iloveapi/blob/master/server/server.lua)

This resource exposes the following exports to use in your **server** scripts.

### 1. `CropImageSync(imageUrl, path, filename, resourceName, width, height, x, y, cb, dwcb)`

- **Description**: Process an image by cropping it to a specific width, height, and position (X, Y), then save the result to the root folder of the specified resource using the provided path and filename.
- **Note**: You can manually handle the result by providing a callback function via the `cb` parameter. If you do this, the internal image downloader will be skipped, and the `dwcb` (download callback) will not be triggered.
 
| Parameters         | Type     | Required | Description                                   |
|--------------|----------|----------|-----------------------------------------------|
| `imageUrl`     | `string` | ✅ Yes   | URL of the image to process          |
| `path`   | `string` | ❌ No   | Path to save the file (e.g. `"images/"`), If not provided equal to root resource folders. Ensure path are exist, otherwise it will fails                  |
| `filename`       | `string` | ✅ Yes    | Filename to save the file (e.g. `"result_crop"`) |
| `resourceName`     | `string` | ❌ No    | Resource name as root folder to save the file (default: `majesta-iloveapi`). Ensure resource are exist, otherwise it will fails |
| `width`     | `number` | ✅ Yes | Width of the cropped image                           |
| `height` | `number` | ✅ Yes | Height of the cropped image                    |
| `x`     | `number` | ❌ No | X coordinate of crop (default: `0`)                   |
| `y`     | `number` | ❌ No   | Y coordinate of crop (default: `0`)                     |
| `cb`     | `function(downloadUrl, data)` | ❌ No   | Callback function to handle the result manually instead of triggering the download.                     |
| `dwcb`     | `function()` | ❌ No   | Callback function to executed after the download is complete.                     |

### 2. `RemoveBackgroundImageSync(imageUrl, path, filename, resourceName, cb, dwcb)`

- **Description**: Process an image background removal while keeping the foreground, then save the result to the root folder of the specified resource using the provided path and filename.
- **Note**: You can manually handle the result by providing a callback function via the `cb` parameter. If you do this, the internal image downloader will be skipped, and the `dwcb` (download callback) will not be triggered. 

| Parameters         | Type     | Required | Description                                   |
|--------------|----------|----------|-----------------------------------------------|
| `imageUrl`     | `string` | ✅ Yes   | URL of the image to process          |
| `path`   | `string` | ❌ No   | Path to save the file (e.g. `"images/"`), If not provided equal to root resource folders. Ensure path are exist, otherwise it will fails                  |
| `filename`       | `string` | ✅ Yes    | Filename to save the file (e.g. `"result_crop"`) |
| `resourceName`     | `string` | ❌ No    | Resource name as root folder to save the file (default: `majesta-iloveapi`). Ensure resource are exist, otherwise it will fails |
| `cb`     | `function(downloadUrl, data)` | ❌ No   | Callback function to handle the result manually instead of triggering the download.                     |
| `dwcb`     | `function()` | ❌ No   | Callback function to executed after the download is complete.                     |

## 🌌 Webhook API — [`webhook.lua`](https://github.com/rheyhannh/majesta-iloveapi/blob/master/server/webhook.lua)

Testing image processing from outside the game (e.g., using Postman or cURL) can be challenging. To make this easier, this resource provides a webhook endpoint using [`SetHttpHandler`](https://docs.fivem.net/natives/?_0xF5C6330C), allowing you to interact with it externally via HTTP requests.

Before you begin, make sure:

- `Config.UseWebhook` is set to `true` in your config.

  > ⚠️ It is strongly recommended to disable webhook on production servers.

- You’ve configured your webhook path via `server.cfg` using:

  ```set iloveapi_webhook_path "/your_path"```
  
Once enabled, you can test various tasks (such as cropping or removing backgrounds) by sending HTTP requests directly to your server. See the available routes below, along with their descriptions, request bodies, and examples.

### 1. `POST` `/your_path/cropimage`

- **Method**: `POST`
- **URL**: `http://{{server_ip}}:{{server_port}}/majesta-iloveapi/your_path/cropimage`
- **Description**: Process an image by cropping it to a specific width, height, and position (X, Y), then save the result to the root folder of the specified resource using the provided path and filename.

#### 🔽 Request Body

| Field         | Type     | Required | Description                                   |
|--------------|----------|----------|-----------------------------------------------|
| `image_url`     | `string` | ✅ Yes   | URL of the image to process          |
| `path`   | `string` | ❌ No   | Path to save the file (e.g. `"images/"`), If not provided equal to root resource folders. Ensure path are exist, otherwise it will fails                  |
| `filename`       | `string` | ✅ Yes    | Filename to save the file (e.g. `"result_crop"`) |
| `resource_name`     | `string` | ❌ No    | Resource name as root folder to save the file (default: `majesta-iloveapi`). Ensure resource are exist, otherwise it will fails |
| `width`     | `number` | ✅ Yes | Width of the cropped image                           |
| `height` | `number` | ✅ Yes | Height of the cropped image                    |
| `x`     | `number` | ❌ No | X coordinate of crop (default: `0`)                   |
| `y`     | `number` | ❌ No   | Y coordinate of crop (default: `0`)                     |

#### 🔼 Example Request Body

```json
{
    "image_url": "https://i.imgur.com/UsPc60v.jpeg",
    "path": "images/",
    "filename": "result_crop",
    "resource_name": "my-resource",
    "width": 237,
    "height": 299,
    "x": 785,
    "y": 255
}
```

### 2. `POST` `/your_path/removebackgroundimage`

- **Method**: `POST`
- **URL**: `http://{{server_ip}}:{{server_port}}/majesta-iloveapi/your_path/removebackgroundimage`
- **Description**: Process an image background removal while keeping the foreground, then save the result to the root folder of the specified resource using the provided path and filename.

#### 🔽 Request Body

| Field         | Type     | Required | Description                                   |
|--------------|----------|----------|-----------------------------------------------|
| `image_url`     | `string` | ✅ Yes   | URL of the image to process          |
| `path`   | `string` | ❌ No   | Path to save the file (e.g. `"images/"`), If not provided equal to root resource folders. Ensure path are exist, otherwise it will fails                 |
| `filename`       | `string` | ✅ Yes    | Filename to save the file (e.g. `"result_removebg"`) |
| `resource_name`     | `string` | ❌ No    | Resource name as root folder to save the file (default: `majesta-iloveapi`). Ensure resource are exist, otherwise it will fails  |

#### 🔼 Example Request Body

```json
{
    "image_url": "https://i.imgur.com/UsPc60v.jpeg",
    "path": "images/",
    "filename": "result_removebg",
    "resource_name": "my-resource",
}
```

### 3. `GET` `/your_path/details`

- **Method**: `GET`
- **URL**: `http://{{server_ip}}:{{server_port}}/majesta-iloveapi/your_path/details`
- **Description**: Retrieve authentication details (JWT token, issued and expiration time)

#### 🔼 Example Response Body

```json
{
    "ok": true,
    "code" : 200,
    "data": {
        "auth": {
            "token": "xyz",
            "iat": "Sun Aug 03, 16:04:38",
            "exp": "Sun Aug 03, 17:04:38"
        }
    }
}
```

## 🤝 Customization and Contributions

You are free to:
- ✨Fork the project
- 🛠️ Modify it for your server 
- 🔥 Add more ILoveApi features
- 🎉 Make a pull request if you'd like to contribute!
