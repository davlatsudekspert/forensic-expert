#!/usr/bin/env python3
"""FORENSIC EXPERT — Play Console INTERNAL testing: qoralama relizni chiqarish.

`release-build.yml` AAB ni internal trekka DRAFT sifatida yuklaydi. Bu skript
shu trekdagi eng yangi qoralama relizni «completed» (testerlarga ochiq) qiladi.
Faqat `internal` trek; production/closed/open trek va ilova holati o‘zgarmaydi.
Kalit faqat CI muhitidan (`PLAY_SERVICE_ACCOUNT_JSON`) o‘qiladi, chop etilmaydi.
"""
from __future__ import annotations

import json
import os
import sys

import google.auth.transport.requests
from google.oauth2 import service_account

API = "https://androidpublisher.googleapis.com/androidpublisher/v3"
SCOPE = "https://www.googleapis.com/auth/androidpublisher"
PACKAGE = os.environ.get("FE_ANDROID_PACKAGE", "uz.forensicexpert.forensic_expert")
TRACK = "internal"


def main() -> None:
    raw = os.environ.get("PLAY_SERVICE_ACCOUNT_JSON", "").strip()
    if not raw:
        sys.exit("PLAY_SERVICE_ACCOUNT_JSON is not set")
    creds = service_account.Credentials.from_service_account_info(
        json.loads(raw), scopes=[SCOPE]
    )
    s = google.auth.transport.requests.AuthorizedSession(creds)
    base = f"{API}/applications/{PACKAGE}"

    r = s.post(f"{base}/edits", json={})
    r.raise_for_status()
    edit = r.json()["id"]

    r = s.get(f"{base}/edits/{edit}/tracks/{TRACK}")
    r.raise_for_status()
    track = r.json()
    releases = track.get("releases", [])
    for rel in releases:
        print("release:", rel.get("name"), rel.get("status"), rel.get("versionCodes"))

    def newest(rel: dict) -> int:
        return max((int(v) for v in rel.get("versionCodes", [])), default=0)

    drafts = [x for x in releases if x.get("status") == "draft" and x.get("versionCodes")]
    if not drafts:
        sys.exit("No draft release with an uploaded build on the internal track")
    target = max(drafts, key=newest)
    target["status"] = "completed"
    # Chiqarilayotgan reliz bilan birga boshqa qoralamalar saqlanib qoladi.
    track["releases"] = releases
    r = s.put(f"{base}/edits/{edit}/tracks/{TRACK}", json=track)
    if not r.ok:
        sys.exit(f"Track update refused: {r.status_code} {r.text[:400]}")
    r = s.post(f"{base}/edits/{edit}:commit")
    if not r.ok:
        sys.exit(f"Commit refused: {r.status_code} {r.text[:400]}")
    print(f"ROLLED OUT to internal testing: versionCodes={target.get('versionCodes')}")


if __name__ == "__main__":
    main()
