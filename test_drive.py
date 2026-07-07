import requests

access_token = "ya29.fake_token"
headers = {"Authorization": f"Bearer {access_token}"}
folder_id = "1ph8autUGVIHckRccBvpsHLDfGeObGCC0HuuPogtFLk6V_JgT6JFE4CAwcY0G_0Oe2XgHJ4zc"
url = "https://www.googleapis.com/drive/v3/files"
params = {
    "q": f"'{folder_id}' in parents and mimeType='application/pdf' and trashed=false",
    "fields": "files(id, name, webViewLink)",
    "pageSize": 10
}
resp = requests.get(url, headers=headers, params=params)
print(resp.status_code, resp.text)
