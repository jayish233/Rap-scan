#!/usr/bin/env python3
"""Generate the RAPscanz launcher-icon masters from the brand mark
(design handoff mockups: rounded square, green->teal gradient, white
scanner-reticle corners, leaf with vein). Renders at 4x and downsamples.

Outputs:
  assets/icon/app_icon.png             1024x1024 full-bleed (iOS + legacy Android)
  assets/icon/app_icon_foreground.png  1024x1024 mark on transparency (Android adaptive)
"""
import math
import os
from PIL import Image, ImageDraw

SS = 4          # supersample factor
SIZE = 1024     # output size
GREEN = (0x3F, 0xD6, 0x8A)   # #3FD68A gradient start (top-left)
TEAL = (0x19, 0xC8, 0xC0)    # #19C8C0 gradient end (bottom-right)
WHITE = (255, 255, 255)
VEIN = (0x19, 0xA9, 0x7A)    # #19A97A

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'icon')


def diagonal_gradient(size, c0, c1):
    """Linear gradient along the (0,0)->(size,size) diagonal."""
    img = Image.new('RGB', (size, size))
    px = img.load()
    for y in range(size):
        for x in range(0, size, 4):
            t = (x + y) / (2 * (size - 1))
            r = round(c0[0] + (c1[0] - c0[0]) * t)
            g = round(c0[1] + (c1[1] - c0[1]) * t)
            b = round(c0[2] + (c1[2] - c0[2]) * t)
            for dx in range(4):
                if x + dx < size:
                    px[x + dx, y] = (r, g, b)
    return img


def cubic(p0, p1, p2, p3, n=64):
    pts = []
    for i in range(n + 1):
        t = i / n
        mt = 1 - t
        x = mt**3 * p0[0] + 3 * mt**2 * t * p1[0] + 3 * mt * t**2 * p2[0] + t**3 * p3[0]
        y = mt**3 * p0[1] + 3 * mt**2 * t * p1[1] + 3 * mt * t**2 * p2[1] + t**3 * p3[1]
        pts.append((x, y))
    return pts


def rounded_mask(size, radius):
    mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask


def draw_mark(size, rounded_radius):
    """The full brand mark at `size` px (supersampled coordinates)."""
    grad = diagonal_gradient(size, GREEN, TEAL)
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    img.paste(grad, (0, 0), rounded_mask(size, rounded_radius))
    d = ImageDraw.Draw(img)

    u = size / 64.0  # mockup viewBox is 64x64

    # Scanner-reticle corners: M14 22V16H20 etc., white, stroke 3, round caps.
    w = 3 * u
    arm = 6 * u
    for cx, cy, dx, dy in [(14, 16, 1, 1), (50, 16, -1, 1), (14, 48, 1, -1), (50, 48, -1, -1)]:
        d.line([(cx * u, (cy + arm * dy) * u), (cx * u, cy * u), ((cx + arm * dx) * u, cy * u)],
               fill=WHITE + (255,), width=round(w), joint='curve')
        for ex, ey in [(cx * u, (cy + arm * dy) * u), ((cx + arm * dx) * u, cy * u)]:
            d.ellipse([ex - w / 2, ey - w / 2, ex + w / 2, ey + w / 2], fill=WHITE + (255,))

    # Leaf: M22 40 C22 29 29 23 43 22 C43 36 35 42 24 41 Z, white fill.
    leaf = cubic((22, 40), (22, 29), (29, 23), (43, 22)) + cubic((43, 22), (43, 36), (35, 42), (24, 41))
    d.polygon([(x * u, y * u) for x, y in leaf], fill=WHITE + (255,))

    # Vein: M22 42 L31 33, stroke #19A97A width 2.4, round cap.
    vw = 2.4 * u
    d.line([(22 * u, 42 * u), (31 * u, 33 * u)], fill=VEIN + (255,), width=round(vw))
    for ex, ey in [(22 * u, 42 * u), (31 * u, 33 * u)]:
        d.ellipse([ex - vw / 2, ey - vw / 2, ex + vw / 2, ey + vw / 2], fill=VEIN + (255,))
    return img


def main():
    os.makedirs(OUT, exist_ok=True)
    big = SIZE * SS

    # 1. Full-bleed icon (iOS applies its own mask; Android legacy uses it as-is).
    mark = draw_mark(big, int(big * 0.24))
    # iOS icons must be opaque squares: the gradient covers the whole canvas
    # edge to edge, so composite onto itself — no transparency left.
    full = Image.new('RGBA', (big, big), (0, 0, 0, 255))
    full.alpha_composite(mark)
    full.convert('RGB').resize((SIZE, SIZE), Image.LANCZOS).save(
        os.path.join(OUT, 'app_icon.png'))

    # 2. Adaptive foreground: mark at ~90% on transparency. flutter_launcher_icons
    # insets it a further 16%, landing the mark at ~61% of the layer — inside
    # the 66% adaptive safe zone without looking shrunk.
    fg = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    inner = draw_mark(int(big * 0.90), int(big * 0.90 * 0.24))
    off = (big - inner.width) // 2
    fg.alpha_composite(inner, (off, off))
    fg.resize((SIZE, SIZE), Image.LANCZOS).save(
        os.path.join(OUT, 'app_icon_foreground.png'))

    print('wrote assets/icon/app_icon.png and app_icon_foreground.png')


if __name__ == '__main__':
    main()
