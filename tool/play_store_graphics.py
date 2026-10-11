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


def session() -> google.auth.transport.requests.AuthorizedSession:
    raw = os.environ.get("PLAY_SERVICE_ACCOUNT_JSON", "").strip()
    if not raw:
        sys.exit("PLAY_SERVICE_ACCOUNT_JSON is not set")
    info = json.loads(raw)
    creds = service_account.Credentials.from_service_account_info(
        info, scopes=[SCOPE]
    )
    return google.auth.transport.requests.AuthorizedSession(creds)


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


def main() -> None:
    pkg = os.environ.get("FE_ANDROID_PACKAGE", "").strip()
    if not pkg:
        sys.exit("FE_ANDROID_PACKAGE is not set")

    icon = GRAPHICS / "play-icon-512.png"
    feature = GRAPHICS / "play-feature-1024x500.png"
    shots = sorted((GRAPHICS / "screenshots").glob("*.png"))
    for p in (icon, feature):
        if not p.is_file():
            sys.exit(f"missing {p.relative_to(ROOT)}")
    if len(shots) < 2:
        sys.exit("Play needs at least two phone screenshots")
    # Play telefon skrinshotlari uchun 8 tadan ko‘pini qabul qilmaydi.
    shots = shots[:8]

    s = session()
    edit = check(
        s.post(f"{API}/applications/{pkg}/edits", json={}), "create edit"
    ).json()["id"]
    print(f"edit {edit} for {pkg}")

    listings = check(
        s.get(f"{API}/applications/{pkg}/edits/{edit}/listings"),
        "read listings",
    ).json().get("listings", [])
    languages = [x["language"] for x in listings]
    if not languages:
        sys.exit("no store listing exists yet — write the texts first")
    print("languages:", ", ".join(languages))

    for lang in languages:
        print(f"[{lang}]")
        upload_image(s, pkg, edit, lang, "icon", icon)
        upload_image(s, pkg, edit, lang, "featureGraphic", feature)
        check(
            s.delete(f"{API}/applications/{pkg}/edits/{edit}/listings/{lang}"
                     f"/phoneScreenshots"),
            f"clear phoneScreenshots ({lang})",
        )
        for shot in shots:
            check(
                s.post(
                    f"{UPLOAD}/applications/{pkg}/edits/{edit}/listings/{lang}"
                    f"/phoneScreenshots?uploadType=media",
                    data=shot.read_bytes(),
                    headers={"Content-Type": "image/png"},
                ),
                f"upload screenshot ({lang}) {shot.name}",
            )
            print(f"  phoneScreenshots: {shot.name}")

    check(
        s.post(f"{API}/applications/{pkg}/edits/{edit}:commit"), "commit edit"
    )
    print(f"committed: icon + feature + {len(shots)} screenshots "
          f"for {len(languages)} language(s)")


if __name__ == "__main__":
    main()
