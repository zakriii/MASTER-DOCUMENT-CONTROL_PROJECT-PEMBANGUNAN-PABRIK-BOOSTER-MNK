# MASTER DOKUMEN CONTROL

Repository backup untuk aplikasi **MASTER DOKUMEN CONTROL**: document control project untuk Material Approval, Material Request, Izin Pelaksanaan Pekerjaan, Gambar Kerja, Dokumen Surat, Berita Acara, MoM, Transmittal, File Storage, Signature Tools, dan Export Paket PDF IPP + Shop Drawing.

## Status paket
- Dibuat: 2026-07-05 11:24:39
- Update MR Rupiah: 2026-07-05 11:54:25
- Entry point lokal/GitHub Pages: `index.html`
- Release HTML: `release/MASTER_DOKUMEN_CONTROL_FINAL_MR_RUPIAH_READY_ONLINE.html`
- Template resmi tersimpan di folder `templates/`
- Konfigurasi template dan mapping ada di `config/template-registry.json`

## Prinsip utama sistem
1. Template Excel resmi tidak boleh diubah formatnya.
2. Sistem hanya mengisi cell yang terdaftar di mapping.
3. Area catatan Manajemen Konstruksi pada Material Approval tidak diisi oleh sistem.
4. Dokumen full signed harus disimpan sebagai arsip/scan, bukan ditimpa oleh generated file.
5. Untuk online production, pisahkan database metadata dan object storage file.

## Deploy ringkas
1. Upload seluruh isi folder ini ke repository GitHub.
2. Pastikan `index.html` berada di root repository.
3. Aktifkan GitHub Pages dari branch utama.
4. Untuk file besar dan database online, sambungkan Supabase + object storage sesuai `docs/ONLINE_ARCHITECTURE.md`.

## Folder penting
- `templates/` — template Excel resmi yang dikunci.
- `config/` — registry template, modul, dan mapping.
- `database/` — skema SQL Supabase/Postgres.
- `docs/` — SOP update template, prompt backup, deployment guide, QA checklist.
- `render-service/` — rancangan service XLSX-to-PDF untuk hasil PDF presisi.
- `backups/` — sample backup data.


## Update MR Rupiah
- Field Estimate Price pada Material Request menerima input harga satuan dalam format Rupiah/angka Indonesia, contoh `200.000`.
- Total Price per item otomatis menghitung `Qty × Estimate Price`.
- Total Summary MR otomatis menjumlahkan seluruh Total Price item MR.
- Export Excel MR menulis Estimate Price, Total Price, dan Total Summary sebagai angka ke cell template yang memiliki number format Rupiah.

## Update - PDF Output Center

Versi ini menambahkan PDF Output Center untuk Export PDF Presisi dari template Excel terkunci dan Smart PDF Package untuk menggabungkan:

- Material Approval + katalog/brosur/dokumen pendukung
- IPP + Shop Drawing
- Material Request + lampiran procurement

Untuk PDF yang benar-benar sama dengan output Excel, konfigurasi render service XLSX-to-PDF diperlukan pada tahap online. Detail endpoint ada di `docs/PDF_OUTPUT_SERVICE.md`.
