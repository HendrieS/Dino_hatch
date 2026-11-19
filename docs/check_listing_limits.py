#!/usr/bin/env python3
"""Checks docs/AppStoreListing.md against App Store Connect's field limits.

Run from the repository root: python3 docs/check_listing_limits.py
"""
import pathlib
import re
import sys

LIMITS = {
    "Name": 30,
    "Subtitle": 30,
    "Promotional Text": 170,
    "Description": 4000,
    "Keywords": 100,
}

text = pathlib.Path(__file__).with_name("AppStoreListing.md").read_text(encoding="utf-8")
failed = False
for language_block in re.split(r"^## ", text, flags=re.M)[1:]:
    language, _, body = language_block.partition("\n")
    fields = re.split(r"^### ", body, flags=re.M)[1:]
    for field in fields:
        name, _, value = field.partition("\n")
        name = name.strip()
        if name not in LIMITS:
            continue
        value = value.split("\n---")[0].strip()
        length = len(value)
        status = "ok" if length <= LIMITS[name] else "TOO LONG"
        if name == "Keywords" and ", " in value:
            status += " (drop the spaces after commas)"
        failed |= length > LIMITS[name]
        print(f"{language:<16} {name:<17} {length:>4}/{LIMITS[name]:<4} {status}")
sys.exit(1 if failed else 0)
