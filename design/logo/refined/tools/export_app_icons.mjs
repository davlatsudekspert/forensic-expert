// R2 «Integrated Peak» — ilova ikonkalarini eksport qilish (Android + iOS).
//
// Diqqat: R2 egasi tanlagan YO‘NALISH; trademark tekshiruvi tugamaguncha
// brend yuridik jihatdan tasdiqlangan EMAS (RG-06).
//
// Ishga tushirish (repo ildizidan):
//   NODE_PATH=$(npm root -g) node design/logo/refined/tools/export_app_icons.mjs
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../../..');
const svgDir = path.join(repo, 'design/logo/refined/svg');
const res = path.join(repo, 'apps/mobile/android/app/src/main/res');
const ios = path.join(repo, 'apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset');

const read = (f) => fs.readFileSync(path.join(svgDir, f), 'utf8');
const icon = read('R2-integrated-peak-icon.svg');
const iconSmall = read('R2-integrated-peak-icon-small.svg');
// Adaptive foreground: fon olib tashlangan (shaffof), glif safe zone ichida.
const foreground = icon.replace(/<rect width="100" height="100" fill="#0F1E3D"\/>/, '');
if (foreground === icon) throw new Error('background rect not found');

const browser = await chromium.launch();
const page = await browser.newPage({ deviceScaleFactor: 1 });
async function raster(svg, size, out, { transparent = false } = {}) {
  const s = svg.replace(/width="\d+" height="\d+"/, `width="${size}" height="${size}"`);
  await page.setViewportSize({ width: size, height: size });
  await page.setContent(`<html><body style="margin:0;background:transparent">${s}</body><style>svg{display:block}</style></html>`);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  await page.locator('svg').screenshot({ path: out, omitBackground: transparent });
}

// Android legacy (to‘liq kvadrat, launcher o‘zi maskalaydi).
const legacy = { mdpi: 48, hdpi: 72, xhdpi: 96, xxhdpi: 144, xxxhdpi: 192 };
for (const [d, px] of Object.entries(legacy)) {
  await raster(px <= 72 ? iconSmall : icon, px, path.join(res, `mipmap-${d}/ic_launcher.png`));
}
// Android adaptive foreground (108 dp).
const adaptive = { mdpi: 108, hdpi: 162, xhdpi: 216, xxhdpi: 324, xxxhdpi: 432 };
for (const [d, px] of Object.entries(adaptive)) {
  await raster(foreground, px, path.join(res, `mipmap-${d}/ic_launcher_foreground.png`), { transparent: true });
}
fs.mkdirSync(path.join(res, 'mipmap-anydpi-v26'), { recursive: true });
fs.writeFileSync(path.join(res, 'mipmap-anydpi-v26/ic_launcher.xml'),
`<?xml version="1.0" encoding="utf-8"?>
<!-- R2 «Integrated Peak» (trademark tekshiruvi kutilmoqda, RG-06). -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
`);
fs.writeFileSync(path.join(res, 'values/ic_launcher_background.xml'),
`<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0F1E3D</color>
</resources>
`);

// iOS (shaffofliksiz; ≤ 64 px da small varianti).
const contents = JSON.parse(fs.readFileSync(path.join(ios, 'Contents.json'), 'utf8'));
for (const img of contents.images) {
  const base = parseFloat(img.size.split('x')[0]);
  const scale = parseInt(img.scale, 10);
  const px = Math.round(base * scale);
  await raster(px <= 64 ? iconSmall : icon, px, path.join(ios, img.filename));
}
await browser.close();
console.log('App icons exported (R2).');
