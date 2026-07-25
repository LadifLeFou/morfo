"""Genere le logo Morfo epure et TOUS les assets iOS derives.

Rendu en supersampling 4x puis reduit pour un anti-aliasing propre.
Produit deux fichiers : l'icone (fond opaque) et la mascotte (fond transparent).
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

SS = 4                      # supersampling
S = 1024
N = S * SS
CX = N // 2

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "build" / "logo"
OUT.mkdir(parents=True, exist_ok=True)

# — Marque —
VOID = (7, 6, 13)
CYAN = (110, 231, 249)
VIOLET = (167, 139, 250)
PINK = (240, 171, 252)
WARM = (253, 186, 116)
STOPS = [(0.0, CYAN), (0.38, VIOLET), (0.68, PINK), (1.0, WARM)]


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def grad_color(t):
    t = max(0.0, min(1.0, t))
    for i in range(len(STOPS) - 1):
        t0, c0 = STOPS[i]
        t1, c1 = STOPS[i + 1]
        if t <= t1:
            return lerp(c0, c1, (t - t0) / (t1 - t0))
    return STOPS[-1][1]


def bezier(p0, p1, p2, p3, steps=80):
    pts = []
    for s in range(steps + 1):
        t = s / steps
        u = 1 - t
        x = u*u*u*p0[0] + 3*u*u*t*p1[0] + 3*u*t*t*p2[0] + t*t*t*p3[0]
        y = u*u*u*p0[1] + 3*u*u*t*p1[1] + 3*u*t*t*p2[1] + t*t*t*p3[1]
        pts.append((x, y))
    return pts


def path(segs):
    """segs : liste de (p0,p1,p2,p3) beziers ; renvoie le polygone ferme."""
    poly = []
    for seg in segs:
        poly += bezier(*seg)
    return poly


def mirror(poly):
    return [(2 * CX - x, y) for (x, y) in poly]


# — Geometrie du papillon (moitie droite, en unites 1024 * SS) —
def u(x, y):
    return (x * SS, y * SS)

# Aile superieure droite : part du corps en haut, s'ouvre vers le haut-exterieur,
# redescend en pointe douce, revient au corps.
upper = path([
    (u(512, 355), u(600, 250), u(770, 250), u(880, 330)),   # bord interne -> haut-ext
    (u(880, 330), u(940, 380), u(900, 470), u(830, 520)),   # arrondi exterieur
    (u(830, 520), u(760, 560), u(640, 540), u(560, 500)),   # bord inferieur
    (u(560, 500), u(525, 480), u(515, 430), u(512, 355)),   # retour au corps
])

# Aile inferieure droite : plus petite, arrondie, pointe vers le bas.
lower = path([
    (u(535, 520), u(660, 545), u(760, 640), u(720, 740)),   # ouverture bas-ext
    (u(720, 740), u(695, 800), u(620, 760), u(560, 690)),   # arrondi bas
    (u(560, 690), u(535, 660), u(528, 590), u(535, 520)),   # retour au corps
])

wings_right = [upper, lower]
wings_left = [mirror(upper), mirror(lower)]


def build(bg_opaque: bool):
    base = Image.new("RGBA", (N, N), (*VOID, 255) if bg_opaque else (0, 0, 0, 0))

    # Halo tres discret derriere le papillon (profondeur sans effet neon).
    if bg_opaque:
        glow = Image.new("RGBA", (N, N), (0, 0, 0, 0))
        gd = ImageDraw.Draw(glow)
        r = int(N * 0.42)
        gd.ellipse([CX - r, CX - r, CX + r, CX + r], fill=(*VIOLET, 22))
        glow = glow.filter(ImageFilter.GaussianBlur(N // 12))
        base = Image.alpha_composite(base, glow)

    # Silhouette du papillon en masque.
    mask = Image.new("L", (N, N), 0)
    md = ImageDraw.Draw(mask)
    for poly in wings_right + wings_left:
        md.polygon(poly, fill=255)
    # Corps fin + tete.
    md.rounded_rectangle([CX - 16*SS, 330*SS, CX + 16*SS, 695*SS],
                         radius=16*SS, fill=255)
    md.ellipse([CX - 22*SS, 300*SS, CX + 22*SS, 344*SS], fill=255)

    # Degrade diagonal cyan -> warm applique dans le masque.
    grad = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    gpx = grad.load()
    # Le degrade s'etale sur la bbox du papillon, pas sur toute la toile :
    # cyan sur l'aile haut-gauche, warm sur l'aile bas-droite.
    x0, y0, x1, y1 = 140*SS, 280*SS, 884*SS, 780*SS
    for y in range(N):
        ty = (y - y0) / (y1 - y0)
        for x in range(0, N, SS):
            tx = (x - x0) / (x1 - x0)
            c = grad_color(0.5 * tx + 0.5 * ty)
            for dx in range(SS):
                if x + dx < N:
                    gpx[x + dx, y] = (*c, 255)
    grad.putalpha(mask)

    out = Image.alpha_composite(base, grad)
    return out.resize((S, S), Image.LANCZOS)


icon = build(bg_opaque=True).convert("RGB")
icon.save(OUT / "logo_icon.png")
mascot = build(bg_opaque=False)
mascot.save(OUT / "logo_mascot.png")
print("logo_icon.png (opaque) + logo_mascot.png (transparent) generes")


# — Installation dans le projet —
import json
import subprocess

ICON_SET = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
LAUNCH = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
MASCOT = ROOT / "assets/images/mascot.png"

subprocess.run(["cp", str(OUT / "logo_mascot.png"), str(MASCOT)], check=True)

conf = json.load(open(ICON_SET / "Contents.json"))
for i in conf["images"]:
    px = int(round(float(i["size"].split("x")[0]) * int(i["scale"].rstrip("x"))))
    subprocess.run(["sips", "-s", "format", "png", "-z", str(px), str(px),
                    str(OUT / "logo_icon.png"), "--out", str(ICON_SET / i["filename"])],
                   check=True, capture_output=True)

for nom, px in [("LaunchImage.png", 180), ("LaunchImage@2x.png", 360),
                ("LaunchImage@3x.png", 540)]:
    subprocess.run(["sips", "-s", "format", "png", "-z", str(px), str(px),
                    str(OUT / "logo_mascot.png"), "--out", str(LAUNCH / nom)],
                   check=True, capture_output=True)

print("assets installes : mascot.png, 15 icones, 3 LaunchImage")
