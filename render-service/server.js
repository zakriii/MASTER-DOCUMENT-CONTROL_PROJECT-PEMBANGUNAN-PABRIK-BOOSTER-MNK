import express from "express";
import multer from "multer";
import cors from "cors";
import { execFile } from "child_process";
import fs from "fs";
import path from "path";
import os from "os";

const app = express();

const allowedOrigins = (process.env.ALLOWED_ORIGINS || "https://zakriii.github.io")
  .split(",")
  .map(origin => origin.trim())
  .filter(Boolean);

app.use(cors({
  origin(origin, callback) {
    if (!origin || allowedOrigins.includes("*") || allowedOrigins.includes(origin)) {
      callback(null, true);
      return;
    }
    callback(new Error(`Origin not allowed: ${origin}`));
  },
  methods: ["GET", "POST", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json({ limit: "1mb" }));

const upload = multer({
  dest: os.tmpdir(),
  limits: {
    fileSize: Number(process.env.MAX_FILE_SIZE_MB || 35) * 1024 * 1024
  },
  fileFilter(req, file, callback) {
    const ext = path.extname(file.originalname || "").toLowerCase();
    const allowed = [".xlsx", ".xlsm", ".xls", ".ods"];
    if (!allowed.includes(ext)) {
      callback(new Error("File harus berupa XLSX/XLSM/XLS/ODS."));
      return;
    }
    callback(null, true);
  }
});

function cleanFileName(name) {
  return (name || "document.xlsx")
    .replace(/\.[^.]+$/, "")
    .replace(/[^\w.-]+/g, "_")
    .replace(/^_+|_+$/g, "") || "document";
}

function runLibreOffice(inputPath, outputDir) {
  return new Promise((resolve, reject) => {
    execFile(
      "libreoffice",
      [
        "--headless",
        "--nologo",
        "--nofirststartwizard",
        "--nodefault",
        "--nolockcheck",
        "--convert-to",
        "pdf",
        "--outdir",
        outputDir,
        inputPath
      ],
      { timeout: Number(process.env.RENDER_TIMEOUT_MS || 180000) },
      (error, stdout, stderr) => {
        if (error) {
          reject(new Error(stderr || stdout || error.message));
          return;
        }
        resolve({ stdout, stderr });
      }
    );
  });
}

app.get("/", (req, res) => {
  res.json({
    ok: true,
    service: "MASTER DOKUMEN CONTROL - XLSX to PDF Render Service",
    status: "running",
    endpoint: "/render/xlsx-to-pdf",
    allowedOrigins
  });
});

app.get("/health", (req, res) => {
  res.json({ ok: true, timestamp: new Date().toISOString() });
});

app.post("/render/xlsx-to-pdf", upload.single("file"), async (req, res) => {
  if (!req.file) {
    res.status(400).json({ ok: false, error: "File XLSX tidak ditemukan. Gunakan form field bernama 'file'." });
    return;
  }

  const inputPath = req.file.path;
  const originalName = req.file.originalname || "document.xlsx";
  const safeBaseName = cleanFileName(originalName);
  const outputDir = fs.mkdtempSync(path.join(os.tmpdir(), "mdc-pdf-render-"));

  try {
    await runLibreOffice(inputPath, outputDir);

    const pdfFiles = fs.readdirSync(outputDir).filter(file => file.toLowerCase().endsWith(".pdf"));
    if (!pdfFiles.length) {
      throw new Error("PDF hasil render tidak ditemukan. Periksa template Excel dan print area.");
    }

    const pdfPath = path.join(outputDir, pdfFiles[0]);
    const pdfBuffer = fs.readFileSync(pdfPath);

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `attachment; filename="${safeBaseName}.pdf"`);
    res.setHeader("X-Render-Engine", "LibreOffice Headless");
    res.send(pdfBuffer);
  } catch (error) {
    res.status(500).json({
      ok: false,
      error: error.message
    });
  } finally {
    try { fs.unlinkSync(inputPath); } catch {}
    try { fs.rmSync(outputDir, { recursive: true, force: true }); } catch {}
  }
});

app.use((error, req, res, next) => {
  res.status(400).json({ ok: false, error: error.message || "Request tidak valid." });
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`MASTER DOKUMEN CONTROL render service running on port ${port}`);
});
