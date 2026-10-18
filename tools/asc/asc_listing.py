#!/usr/bin/env python3
"""App Store Connect: versiya sahifasini to'ldirish (Submit QILMAYDI).

- 0.3.0 iOS versiyasini topadi (yo'q bo'lsa yaratadi), build'ni ulaydi;
- en-US / ru lokalizatsiyalarga skrinshotlar (iPhone 6.9", iPad 13") va
  What's New;
- App Review: demo akkaunt, Notes.

Muhit: ASC_KEY_ID, ASC_ISSUER_ID, ASC_PRIVATE_KEY, BUNDLE_ID, VERSION,
BUILD, SHOTS_DIR, DEMO_USER, DEMO_PASSWORD, NOTES_FILE, WHATSNEW_DIR.
"""
import hashlib
import json
import os
import sys
import time
from pathlib import Path

import jwt
import requests

API = "https://api.appstoreconnect.apple.com/v1"
env = os.environ


def token():
    now = int(time.time())
    return jwt.encode(
        {"iss": env["ASC_ISSUER_ID"], "iat": now, "exp": now + 1100,
         "aud": "appstoreconnect-v1"},
        env["ASC_PRIVATE_KEY"], algorithm="ES256",
        headers={"kid": env["ASC_KEY_ID"], "typ": "JWT"})


S = requests.Session()


def call(method, path, body=None, params=None, ok=(200, 201, 204)):
    url = path if path.startswith("http") else API + path
    r = S.request(method, url, json=body, params=params,
                  headers={"Authorization": f"Bearer {token()}"})
    if r.status_code not in ok:
        print(f"!! {method} {path} -> {r.status_code}: {r.text[:800]}")
        return None
    return r.json() if r.content else {}


def main():
    app = call("GET", "/apps", params={"filter[bundleId]": env["BUNDLE_ID"]})
    app_id = app["data"][0]["id"]
    print("app", app_id, app["data"][0]["attributes"]["name"])

    vs = call("GET", f"/apps/{app_id}/appStoreVersions",
              params={"filter[platform]": "IOS", "limit": 20})
    for v in vs["data"]:
        a = v["attributes"]
        print("  version", a["versionString"], a["appStoreState"])
    editable = {"PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED",
                "METADATA_REJECTED", "INVALID_BINARY"}
    ver = next((v for v in vs["data"]
                if v["attributes"]["versionString"] == env["VERSION"]
                and v["attributes"]["appStoreState"] in editable), None)
    if ver is None:
        ver = next((v for v in vs["data"]
                    if v["attributes"]["appStoreState"] in editable), None)
        if ver is not None:
            print("rename editable version ->", env["VERSION"])
            call("PATCH", f"/appStoreVersions/{ver['id']}", {"data": {
                "type": "appStoreVersions", "id": ver["id"],
                "attributes": {"versionString": env["VERSION"]}}})
    if ver is None:
        ver = call("POST", "/appStoreVersions", {"data": {
            "type": "appStoreVersions",
            "attributes": {"platform": "IOS",
                           "versionString": env["VERSION"]},
            "relationships": {"app": {"data": {"type": "apps",
                                               "id": app_id}}}}})["data"]
        print("created version", ver["id"])
    vid = ver["id"]
    released_before = any(v["attributes"]["appStoreState"] in
                          ("READY_FOR_SALE", "REMOVED_FROM_SALE",
                           "DEVELOPER_REMOVED_FROM_SALE")
                          for v in vs["data"])

    # Build
    bs = call("GET", "/builds", params={
        "filter[app]": app_id, "filter[version]": env["BUILD"],
        "filter[preReleaseVersion.version]": env["VERSION"], "limit": 5})
    if bs and bs["data"]:
        b = bs["data"][0]
        print("build", b["attributes"]["version"],
              b["attributes"].get("processingState"))
        call("PATCH", f"/appStoreVersions/{vid}/relationships/build",
             {"data": {"type": "builds", "id": b["id"]}})
        print("build attached")
    else:
        print("!! build not found")

    # Localizations
    locs = call("GET", f"/appStoreVersions/{vid}/appStoreVersionLocalizations")
    have = {l["attributes"]["locale"]: l for l in locs["data"]}
    print("locales", list(have))
    want = {"en": ["en-US", "en-GB"], "ru": ["ru"]}
    for lang, cands in want.items():
        loc = next((have[c] for c in cands if c in have), None)
        if loc is None:
            if lang == "en":
                print("!! no English localization")
                continue
            loc = call("POST", "/appStoreVersionLocalizations", {"data": {
                "type": "appStoreVersionLocalizations",
                "attributes": {"locale": cands[0]},
                "relationships": {"appStoreVersion": {"data": {
                    "type": "appStoreVersions", "id": vid}}}}})
            if loc is None:
                print(f"!! cannot add {cands[0]} (app-level locale missing?)")
                continue
            loc = loc["data"]
            print("created localization", cands[0])
        lid = loc["id"]
        wn = Path(env["WHATSNEW_DIR"], f"{lang}.txt")
        if released_before and wn.exists():
            call("PATCH", f"/appStoreVersionLocalizations/{lid}", {"data": {
                "type": "appStoreVersionLocalizations", "id": lid,
                "attributes": {"whatsNew": wn.read_text().strip()}}})
            print(lang, "whatsNew set")
        for device, dtype in (("iphone69", "APP_IPHONE_67"),
                              ("ipad13", "APP_IPAD_PRO_3GEN_129")):
            files = sorted(Path(env["SHOTS_DIR"], lang, device).glob("*.png"))
            if not files:
                continue
            upload_set(lid, dtype, files, f"{lang}/{device}")

    # App Review
    notes = Path(env["NOTES_FILE"]).read_text().strip()
    attrs = {"demoAccountRequired": True,
             "demoAccountName": env["DEMO_USER"],
             "demoAccountPassword": env["DEMO_PASSWORD"],
             "notes": notes}
    rd = call("GET", f"/appStoreVersions/{vid}/appStoreReviewDetail",
              ok=(200, 404))
    if rd and rd.get("data"):
        rid = rd["data"]["id"]
        call("PATCH", f"/appStoreReviewDetails/{rid}", {"data": {
            "type": "appStoreReviewDetails", "id": rid, "attributes": attrs}})
        c = rd["data"]["attributes"]
        print("review detail updated; contact:",
              bool(c.get("contactEmail")), bool(c.get("contactPhone")))
    else:
        r = call("POST", "/appStoreReviewDetails", {"data": {
            "type": "appStoreReviewDetails", "attributes": attrs,
            "relationships": {"appStoreVersion": {"data": {
                "type": "appStoreVersions", "id": vid}}}}})
        print("review detail created" if r else "!! review detail failed")
    print("DONE (not submitted)")


def upload_set(lid, dtype, files, label):
    sets = call("GET", f"/appStoreVersionLocalizations/{lid}/appScreenshotSets")
    st = next((s for s in sets["data"]
               if s["attributes"]["screenshotDisplayType"] == dtype), None)
    if st is None:
        st = call("POST", "/appScreenshotSets", {"data": {
            "type": "appScreenshotSets",
            "attributes": {"screenshotDisplayType": dtype},
            "relationships": {"appStoreVersionLocalization": {"data": {
                "type": "appStoreVersionLocalizations", "id": lid}}}}})
        if st is None:
            return
        st = st["data"]
    sid = st["id"]
    old = call("GET", f"/appScreenshotSets/{sid}/appScreenshots")
    for o in old["data"]:
        call("DELETE", f"/appScreenshots/{o['id']}")
    ids = []
    for f in files:
        data = f.read_bytes()
        res = call("POST", "/appScreenshots", {"data": {
            "type": "appScreenshots",
            "attributes": {"fileName": f.name, "fileSize": len(data)},
            "relationships": {"appScreenshotSet": {"data": {
                "type": "appScreenshotSets", "id": sid}}}}})
        if res is None:
            continue
        shot = res["data"]
        for op in shot["attributes"]["uploadOperations"]:
            part = data[op["offset"]:op["offset"] + op["length"]]
            hdr = {h["name"]: h["value"] for h in op["requestHeaders"]}
            r = requests.request(op["method"], op["url"], data=part,
                                 headers=hdr)
            r.raise_for_status()
        call("PATCH", f"/appScreenshots/{shot['id']}", {"data": {
            "type": "appScreenshots", "id": shot["id"],
            "attributes": {"uploaded": True,
                           "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
        ids.append(shot["id"])
    call("PATCH", f"/appScreenshotSets/{sid}/relationships/appScreenshots",
         {"data": [{"type": "appScreenshots", "id": i} for i in ids]})
    time.sleep(5)
    chk = call("GET", f"/appScreenshotSets/{sid}/appScreenshots")
    states = [s["attributes"].get("assetDeliveryState", {}).get("state")
              for s in chk["data"]]
    print(f"{label} {dtype}: {len(ids)}/{len(files)} uploaded; states={states}")


if __name__ == "__main__":
    sys.exit(main())
