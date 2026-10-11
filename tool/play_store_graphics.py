#!/usr/bin/env python3
"""FORENSIC EXPERT — Play Console do‘kon grafikasini yuklash.

Google Play Developer API v3. Xizmat hisobining kaliti faqat CI muhitidan
(`PLAY_SERVICE_ACCOUNT_JSON` siri) o‘qiladi; hech qachon chop etilmaydi va
repoga yozilmaydi.

Bu skript **faqat do‘kon sahifasi rasmlarini** o‘zgartiradi: ikonka, feature
grafika va telefon skrinshotlari. Hech qanday relizni track'ga chiqarmaydi,
APK/AAB yubormaydi va ilova holatini o‘zgartirmaydi.
"""
from __future__ import annotations

import json
import os
import pathlib
import sys

import google.auth.transport.requests
from google.oauth2 import service_account

API = "https://androidpublisher.googleapis.com/androidpublisher/v3"
UPLOAD = "https://androidpublisher.googleapis.com/upload/androidpublisher/v3"
SCOPE = "https://www.googleapis.com/auth/androidpublisher"
ROOT = pathlib.Path(__file__).resolve().parent.parent
GRAPHICS = ROOT / "docs/play_store/graphics"


def session() -> tuple[google.auth.transport.requests.AuthorizedSession, str]:
    raw = os.environ.get("PLAY_SERVICE_ACCOUNT_JSON", "").strip()
    if not raw:
        sys.exit("PLAY_SERVICE_ACCOUNT_JSON is not set")
    info = json.loads(raw)
    creds = service_account.Credentials.from_service_account_info(
        info, scopes=[SCOPE]
    )
    # client_email — bu identifikator, sir emas: u Play Console’dagi
    # «Пользователи и разрешения» ro‘yxatida ochiq turadi. Shuni chop etish
    # CI qaysi hisob nomidan ishlayotganini aniqlashga imkon beradi.
    # Kalitning o‘zi (private_key) hech qachon chop etilmaydi.
    return (
        google.auth.transport.requests.AuthorizedSession(creds),
        str(info.get("client_email", "?")),
    )


def probe_commit(s, pkg: str) -> None:
    """Bo‘sh edit yaratib, uni darhol commit qiladi.

    Hech narsani o‘zgartirmaydi. Agar shu ham 403 bersa — muammo rasmlarda
    emas, umuman commit huquqida; agar o‘tsa — muammo aynan do‘kon sahifasi
    o‘zgarishida.
    """
    r = s.post(f"{API}/applications/{pkg}/edits", json={})
    if not r.ok:
        sys.exit(f"probe: cannot even create an edit: HTTP {r.status_code} "
                 f"{r.text[:400]}")
    edit = r.json()["id"]
    r = s.post(f"{API}/applications/{pkg}/edits/{edit}:commit")
    if r.ok:
        print("probe: an empty edit commits fine — write access is there")
        return
    print(f"probe: empty commit refused: HTTP {r.status_code} {r.text[:600]}")
    sys.exit("probe failed — the account cannot commit any edit at all")


def check(response, what: str):
    if not response.ok:
        # Faqat status va API xabari; kalit hech qachon chiqmaydi.
        sys.exit(f"{what}: HTTP {response.status_code} {response.text[:400]}")
    return response


def upload_image(s, pkg: str, edit: str, lang: str, kind: str,
                 path: pathlib.Path) -> None:
    check(
        s.delete(f"{API}/applications/{pkg}/edits/{edit}/listings/{lang}"
                 f"/{kind}"),
        f"clear {kind} ({lang})",
    )
    check(
        s.post(
            f"{UPLOAD}/applications/{pkg}/edits/{edit}/listings/{lang}"
            f"/{kind}?uploadType=media",
            data=path.read_bytes(),
            headers={"Content-Type": "image/png"},
        ),
        f"upload {kind} ({lang}) {path.name}",
    )
    print(f"  {kind}: {path.name}")


def commit(s, pkg: str, edit: str, what: str) -> bool:
    """Edit’ni commit qiladi. 403 bo‘lsa, bir marta
    `changesNotSentForReview=true` bilan qayta uriniladi: nashr etilmagan
    ilovada Play ba’zi o‘zgarishlarni avtomatik ko‘rikka yubora olmaydi.
    Bu bayroq hech narsani ommaga chiqarmaydi.
    """
    url = f"{API}/applications/{pkg}/edits/{edit}:commit"
    r = s.post(url)
    if r.ok:
        print(f"  OK: {what}")
        return True
    first = f"HTTP {r.status_code} {r.text.strip()[:300]}"
    r2 = s.post(f"{url}?changesNotSentForReview=true")
    if r2.ok:
        print(f"  OK: {what} (changesNotSentForReview)")
        return True
    print(f"  REFUSED: {what}")
    print(f"    plain:  {first}")
    print(f"    noReview: HTTP {r2.status_code} {r2.text.strip()[:300]}")
    return False


def probe_listing_text(s, pkg: str, lang: str) -> None:
    """Mavjud matnni aynan o‘zini qayta yozib commit qiladi — hech narsa
    o‘zgarmaydi. Maqsad: rad etish «do‘kon sahifasining har qanday
    o‘zgarishi» uchunmi yoki aynan rasmlar uchunmi, shuni ajratish.
    """
    edit = check(
        s.post(f"{API}/applications/{pkg}/edits", json={}), "create edit"
    ).json()["id"]
    current = check(
        s.get(f"{API}/applications/{pkg}/edits/{edit}/listings/{lang}"),
        f"read listing ({lang})",
    ).json()
    body = {k: current.get(k) for k in
            ("language", "title", "shortDescription", "fullDescription",
             "video") if current.get(k) is not None}
    check(
        s.put(f"{API}/applications/{pkg}/edits/{edit}/listings/{lang}",
              json=body),
        f"write back the same listing text ({lang})",
    )
    commit(s, pkg, edit, f"unchanged listing text ({lang})")


def apply_one(s, pkg: str, lang: str, kind: str,
              files: list[pathlib.Path]) -> bool:
    """Bitta rasm turini o‘z edit’ida qo‘llaydi — qaysi biri rad etilishi
    shunda aniq ko‘rinadi."""
    edit = check(
        s.post(f"{API}/applications/{pkg}/edits", json={}), "create edit"
    ).json()["id"]
    check(
        s.delete(f"{API}/applications/{pkg}/edits/{edit}/listings/{lang}"
                 f"/{kind}"),
        f"clear {kind}",
    )
    for path in files:
        check(
            s.post(
                f"{UPLOAD}/applications/{pkg}/edits/{edit}/listings/{lang}"
                f"/{kind}?uploadType=media",
                data=path.read_bytes(),
                headers={"Content-Type": "image/png"},
            ),
            f"upload {kind} {path.name}",
        )
    return commit(s, pkg, edit, f"{kind} ({lang}, {len(files)} file(s))")


def main() -> None:
    pkg = os.environ.get("FE_ANDROID_PACKAGE", "").strip()
    if not pkg:
        sys.exit("FE_ANDROID_PACKAGE is not set")

    icon = GRAPHICS / "play-icon-512.png"
    feature = GRAPHICS / "play-feature-1024x500.png"
    shots = sorted((GRAPHICS / "screenshots").glob("*.png"))[:8]
    for p in (icon, feature):
        if not p.is_file():
            sys.exit(f"missing {p.relative_to(ROOT)}")
    if len(shots) < 2:
        sys.exit("Play needs at least two phone screenshots")

    s, who = session()
    print(f"acting as: {who}")
    probe_commit(s, pkg)

    read_edit = check(
        s.post(f"{API}/applications/{pkg}/edits", json={}), "create edit"
    ).json()["id"]
    listings = check(
        s.get(f"{API}/applications/{pkg}/edits/{read_edit}/listings"),
        "read listings",
    ).json().get("listings", [])
    languages = [x["language"] for x in listings]
    if not languages:
        sys.exit("no store listing exists yet — write the texts first")
    print("languages:", ", ".join(languages))

    # Matn o‘zgarishi ham rad etiladimi — shu savolga javob.
    probe_listing_text(s, pkg, languages[0])

    failed = []
    for lang in languages:
        print(f"[{lang}]")
        for kind, files in (
            ("icon", [icon]),
            ("featureGraphic", [feature]),
            ("phoneScreenshots", shots),
        ):
            if not apply_one(s, pkg, lang, kind, files):
                failed.append(f"{kind} ({lang})")

    if failed:
        sys.exit("refused by Play: " + ", ".join(failed))
    print("all listing graphics committed")


if __name__ == "__main__":
    main()
