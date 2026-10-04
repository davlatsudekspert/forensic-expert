// R1/R2/R3 (va solishtirish uchun A3) ni 1024 / 180 / 64 / 32 px ga rasterlab,
// silhouette, Android adaptive / iOS mask preview’lari va kontakt varag‘ini yaratadi.
// Ishga tushirish (repo ildizidan):
//   python3 design/logo/refined/tools/generate_refined.py
//   NODE_PATH=$(npm root -g) node design/logo/refined/tools/render_refined.mjs
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// Playwright global o‘rnatilgan (NODE_PATH orqali topiladi).
const require = createRequire(import.meta.url);
const { chromium } = require('playwright');

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const svgDir = path.join(root, 'svg');
const a3Dir = path.resolve(root, '..', 'prototypes'); // faqat o‘qish
const outDir = path.join(root, 'previews');
fs.mkdirSync(outDir, { recursive: true });

const variants = [
  { id: 'A3-nested-peaks', dir: a3Dir, label: 'A3 Nested Peaks (asos, solishtirish uchun)' },
  { id: 'R1-tailing-peak', dir: svgDir, label: 'R1 Tailing Peak' },
  { id: 'R2-integrated-peak', dir: svgDir, label: 'R2 Integrated Peak' },
  { id: 'R3-resolved-doublet', dir: svgDir, label: 'R3 Resolved Doublet' },
];
const sizes = [1024, 180, 64, 32];
// ≤64 px da optik soddalashtirilgan "small" versiya.
const fileFor = (v, kind, size) => path.join(v.dir, `${v.id}-${kind}${size <= 64 ? '-small' : ''}.svg`);

const browser = await chromium.launch();
const page = await browser.newPage({ deviceScaleFactor: 1 });

async function rasterize(svgPath, size, out) {
  const svg = fs.readFileSync(svgPath, 'utf8').replace(/width="\d+" height="\d+"/, `width="${size}" height="${size}"`);
  await page.setViewportSize({ width: size, height: size });
  await page.setContent(`<html><body style="margin:0;background:transparent">${svg}</body><style>svg{display:block}</style></html>`);
  await page.locator('svg').screenshot({ path: out, omitBackground: true });
}

for (const v of variants) {
  for (const s of sizes) {
    await rasterize(fileFor(v, 'icon', s), s, path.join(outDir, `${v.id}-icon-${s}.png`));
    await rasterize(fileFor(v, 'mono', s), s, path.join(outDir, `${v.id}-silhouette-${s}.png`));
  }
}

// --- Mask preview’lari ---------------------------------------------------------
// Android adaptive: icon.svg ning butun 100×100 maydoni = 108dp foreground qatlami.
// Ko‘rinadigan qism — markaziy 72dp; xavfsiz zona — markaziy 66dp doira.
const W = 150; // mask preview o‘lchami (px)
function squirclePath(w, n = 4, steps = 96) {
  const r = w / 2, pts = [];
  for (let i = 0; i < steps; i++) {
    const t = (i / steps) * 2 * Math.PI, c = Math.cos(t), s = Math.sin(t);
    pts.push(`${(r + r * Math.sign(c) * Math.abs(c) ** (2 / n)).toFixed(2)} ${(r + r * Math.sign(s) * Math.abs(s) ** (2 / n)).toFixed(2)}`);
  }
  return `M ${pts.join(' L ')} Z`;
}
const imgBig = W * 108 / 72, off = -W * 18 / 72;
const masked = (src, clip) => `<div class="mask" style="width:${W}px;height:${W}px;${clip}">
  <img src="${src}" style="position:absolute;width:${imgBig}px;height:${imgBig}px;left:${off}px;top:${off}px"></div>`;
const layer = (src) => {
  const L = 216, c = L / 2;
  return `<div style="position:relative;width:${L}px;height:${L}px">
    <img src="${src}" width="${L}" height="${L}" style="display:block">
    <svg width="${L}" height="${L}" style="position:absolute;left:0;top:0">
      <rect x="${L * 18 / 108}" y="${L * 18 / 108}" width="${L * 72 / 108}" height="${L * 72 / 108}" fill="none" stroke="#F5A524" stroke-width="1" stroke-dasharray="4 3"/>
      <circle cx="${c}" cy="${c}" r="${L * 33 / 108}" fill="none" stroke="#FF4D6D" stroke-width="1.5"/>
    </svg></div>`;
};
const masksRow = (v) => {
  const src = `${v.id}-icon-1024.png`;
  return `<div class="row masks" id="masks-${v.id}">
    <div class="col"><span>Android 108dp qatlam · qizil = 66dp safe · sariq = 72dp ko‘rinadigan</span>${layer(src)}</div>
    <div class="col"><span>Android: circle</span>${masked(src, 'clip-path:circle(50%)')}</div>
    <div class="col"><span>Android: squircle</span>${masked(src, `clip-path:path('${squirclePath(W)}')`)}</div>
    <div class="col"><span>Android: rounded square</span>${masked(src, `border-radius:${(W * 0.16).toFixed(1)}px`)}</div>
    <div class="col"><span>iOS (r = 22.37%)</span><img src="${src}" width="${W}" height="${W}" style="border-radius:${(W * 0.2237).toFixed(2)}px"></div>
    <div class="col"><span>iOS 32 px ×6</span><img src="${v.id}-icon-32.png" width="192" height="192" style="image-rendering:pixelated;border-radius:${(192 * 0.2237).toFixed(1)}px"></div>
  </div>`;
};

// --- Kontakt varag‘i -------------------------------------------------------------
const img = (f, w, extra = '') => `<img src="${f}" width="${w}" height="${w}" style="${extra}">`;
const rel = (v, kind) => path.relative(outDir, path.join(v.dir, `${v.id}-${kind}.svg`));
const rows = variants.map((v) => `
  <section>
    <h2>${v.label}</h2>
    <div class="row">
      <div class="col"><span>1024 → 220</span>${img(`${v.id}-icon-1024.png`, 220, 'border-radius:49px')}</div>
      <div class="col"><span>180 px (1:1)</span>${img(`${v.id}-icon-180.png`, 180, 'border-radius:40px')}</div>
      <div class="col"><span>64 px (1:1)</span>${img(`${v.id}-icon-64.png`, 64, 'border-radius:14px')}</div>
      <div class="col"><span>32 px (1:1)</span>${img(`${v.id}-icon-32.png`, 32, 'border-radius:7px')}</div>
      <div class="col"><span>32 px ×8</span>${img(`${v.id}-icon-32.png`, 256, 'image-rendering:pixelated;border-radius:57px')}</div>
      <div class="col"><span>silhouette 32 ×8</span>${img(`${v.id}-silhouette-32.png`, 256, 'image-rendering:pixelated;background:#fff;outline:1px solid #D9DFE7')}</div>
    </div>
    <div class="row">
      <div class="col"><span>light</span><img src="${rel(v, 'light')}" width="110"></div>
      <div class="col dark"><span>dark</span><img src="${rel(v, 'dark')}" width="110"></div>
      <div class="col"><span>mono</span><img src="${rel(v, 'mono')}" width="110"></div>
      <div class="col"><span>silhouette 64</span>${img(`${v.id}-silhouette-64.png`, 64)}</div>
      <div class="col"><span>silhouette 32</span>${img(`${v.id}-silhouette-32.png`, 32)}</div>
      <div class="col"><span>mono-small 16 px</span><img src="${rel(v, 'mono-small')}" width="16"></div>
    </div>
    ${masksRow(v)}
  </section>`).join('');
const html = `<!doctype html><meta charset="utf-8"><title>Refined peak variants</title>
<style>
 body{font:14px system-ui, sans-serif;margin:24px;background:#F4F6F9;color:#0B1220;width:1500px}
 h1{font-size:18px} h2{font-size:15px;margin:4px 0 10px}
 .row{display:flex;gap:22px;align-items:flex-end;flex-wrap:wrap;margin-bottom:14px}
 .col{display:flex;flex-direction:column;gap:6px;align-items:center}
 .col span{font-size:11px;color:#4A5568;max-width:220px;text-align:center}
 .dark{background:#0A101C;padding:8px;border-radius:8px} .dark span{color:#A3AEC0}
 .mask{position:relative;overflow:hidden}
 .masks{border-top:1px dashed #D9DFE7;padding-top:12px}
 section{background:#fff;border:1px solid #D9DFE7;border-radius:12px;padding:16px;margin-bottom:16px}
</style>
<h1>FORENSIC EXPERT — A3 asosidagi takomillashtirilgan variantlar R1 / R2 / R3 (PROTOTIP · qulflanmagan)</h1>${rows}`;
fs.writeFileSync(path.join(outDir, 'contact-sheet.html'), html);
await page.setViewportSize({ width: 1550, height: 900 });
await page.goto('file://' + path.join(outDir, 'contact-sheet.html'));
await page.screenshot({ path: path.join(outDir, 'contact-sheet.png'), fullPage: true });
for (const v of variants) {
  await page.locator(`#masks-${v.id}`).screenshot({ path: path.join(outDir, `${v.id}-masks.png`) });
}
await browser.close();
console.log('previews written to', outDir);
