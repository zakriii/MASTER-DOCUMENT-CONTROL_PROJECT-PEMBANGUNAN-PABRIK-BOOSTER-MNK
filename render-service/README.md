# MASTER DOKUMEN CONTROL - Render Service

Service ini mengubah file Excel (`.xlsx`, `.xlsm`, `.xls`, `.ods`) menjadi PDF menggunakan LibreOffice Headless.

## Endpoint

```text
GET  /
GET  /health
POST /render/xlsx-to-pdf
```

`POST /render/xlsx-to-pdf` memakai `multipart/form-data` dengan field file bernama:

```text
file
```

Response berhasil: `application/pdf`.

## Struktur Folder

```text
render-service/
├── server.js
├── package.json
├── Dockerfile
├── .dockerignore
└── README.md
```

## Deploy ke Cloud Run dari GitHub

Upload folder ini ke root repository GitHub, sejajar dengan `index.html`:

```text
repository/
├── index.html
└── render-service/
    ├── server.js
    ├── package.json
    └── Dockerfile
```

Di Google Cloud Run:

```text
Cloud Run → Create Service / Connect Repo
Repository: repository GitHub kamu
Branch: main
Source directory: /render-service
Build type: Dockerfile
Dockerfile location: /render-service/Dockerfile
Service name: mdc-render-service
Region: asia-southeast2 atau asia-southeast1
Authentication: Allow unauthenticated invocations
Memory: 1 GiB
CPU: 1
Timeout: 300 seconds
Port: 8080
```

Setelah deploy, URL endpoint yang dipakai di MASTER DOKUMEN CONTROL:

```text
https://SERVICE_URL/render/xlsx-to-pdf
```

Masukkan URL tersebut ke field `Endpoint Render XLSX to PDF`.

## Environment Variables

| Variable | Default | Fungsi |
|---|---:|---|
| `PORT` | `8080` | Port Cloud Run |
| `MAX_FILE_SIZE_MB` | `35` | Batas file upload |
| `RENDER_TIMEOUT_MS` | `180000` | Timeout convert |
| `ALLOWED_ORIGINS` | `https://zakriii.github.io` | CORS origin frontend |

Jika memakai domain lain, isi `ALLOWED_ORIGINS` dengan domain frontend, misalnya:

```text
https://zakriii.github.io,https://domain-kamu.com
```

## Test Local

```bash
npm install
npm start
```

Test render:

```bash
curl -X POST http://localhost:8080/render/xlsx-to-pdf \
  -F "file=@contoh.xlsx" \
  --output hasil.pdf
```

## Catatan Template

Agar hasil PDF sama dengan Excel:

1. Pastikan print area template sudah benar.
2. Pastikan page orientation dan page scale sudah diatur di template Excel.
3. Pastikan font yang dipakai tersedia di container.
4. Jangan ubah layout template dari aplikasi; aplikasi hanya mengisi cell input.
