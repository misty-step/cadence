#!/usr/bin/env python3
"""Generate Cadence.icns without an Xcode asset catalog."""

from __future__ import annotations

import os
import struct
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path


def chunk(kind: bytes, data: bytes) -> bytes:
    payload = kind + data
    return struct.pack(">I", len(data)) + payload + struct.pack(">I", zlib.crc32(payload) & 0xFFFFFFFF)


def write_png(path: Path, size: int) -> None:
    rows = []
    radius = size * 0.22
    border = max(1, round(size * 0.035))
    ring_width = max(2, round(size * 0.085))
    cx = cy = (size - 1) / 2
    outer_r = size * 0.34
    inner_r = outer_r - ring_width

    for y in range(size):
        row = bytearray()
        for x in range(size):
            edge_distance = min(x, y, size - 1 - x, size - 1 - y)
            corner_x = min(x, size - 1 - x)
            corner_y = min(y, size - 1 - y)
            corner_distance = ((corner_x - radius) ** 2 + (corner_y - radius) ** 2) ** 0.5

            if corner_x < radius and corner_y < radius and corner_distance > radius:
                row.extend((0, 0, 0, 0))
                continue

            if edge_distance < border:
                row.extend((255, 255, 255, 255))
                continue

            d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
            if inner_r <= d <= outer_r:
                row.extend((255, 255, 255, 255))
            elif abs(x - cx) <= ring_width * 0.38 and cy - outer_r * 0.5 <= y <= cy + outer_r * 0.55:
                row.extend((255, 255, 255, 255))
            else:
                row.extend((34, 40, 49, 255))
        rows.append(b"\x00" + bytes(row))

    raw = b"".join(rows)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )
    path.write_bytes(png)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: generate-icon.py OUTPUT.icns", file=sys.stderr)
        return 2

    output = Path(sys.argv[1]).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmp:
        iconset = Path(tmp) / "Cadence.iconset"
        iconset.mkdir()
        for points in (16, 32, 128, 256, 512):
            write_png(iconset / f"icon_{points}x{points}.png", points)
            write_png(iconset / f"icon_{points}x{points}@2x.png", points * 2)

        subprocess.run(["iconutil", "-c", "icns", str(iconset), "-o", str(output)], check=True)

    os.chmod(output, 0o644)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
