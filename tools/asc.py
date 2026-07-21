"""Client minimal de l'API App Store Connect.

Sert à remplir la fiche et téléverser les captures sans passer par l'interface
web. Les identifiants sont lus depuis `tools/asc_config.json`, qui contient une
clé privée et n'est donc **jamais versionné**.

Lancer :  .venv-asc/bin/python tools/asc.py <commande>
"""

import json
import sys
import time
from pathlib import Path

import jwt
import requests

RACINE = Path(__file__).resolve().parent.parent
CONFIG = RACINE / "tools" / "asc_config.json"
API = "https://api.appstoreconnect.apple.com/v1"


def _config() -> dict:
    if not CONFIG.exists():
        sys.exit(f"Configuration absente : {CONFIG}")
    return json.loads(CONFIG.read_text())


def jeton() -> str:
    """JWT signé ES256, valable 19 minutes (Apple plafonne à 20)."""
    c = _config()
    cle = (RACINE / c["key_file"]).read_text()
    maintenant = int(time.time())
    return jwt.encode(
        {
            "iss": c["issuer_id"],
            "iat": maintenant,
            "exp": maintenant + 19 * 60,
            "aud": "appstoreconnect-v1",
        },
        cle,
        algorithm="ES256",
        headers={"kid": c["key_id"], "typ": "JWT"},
    )


def appel(methode: str, chemin: str, **kwargs) -> requests.Response:
    entetes = {"Authorization": f"Bearer {jeton()}"}
    entetes.update(kwargs.pop("headers", {}))
    url = chemin if chemin.startswith("http") else f"{API}{chemin}"
    return requests.request(methode, url, headers=entetes, timeout=60, **kwargs)


def get(chemin: str, **params) -> dict:
    r = appel("GET", chemin, params=params or None)
    if r.status_code >= 300:
        sys.exit(f"HTTP {r.status_code} sur {chemin}\n{r.text[:500]}")
    return r.json()


def lister_apps() -> None:
    data = get("/apps").get("data", [])
    if not data:
        print("Aucune app. Crée-la d'abord dans App Store Connect.")
        return
    print(f"{len(data)} app(s) :\n")
    for a in data:
        at = a["attributes"]
        print(f"  {at.get('name')}")
        print(f"    id        : {a['id']}")
        print(f"    bundle    : {at.get('bundleId')}")
        print(f"    langue    : {at.get('primaryLocale')}")
        print()


def detail_app(app_id: str) -> None:
    versions = get(f"/apps/{app_id}/appStoreVersions").get("data", [])
    print(f"{len(versions)} version(s) :\n")
    for v in versions:
        at = v["attributes"]
        print(f"  version {at.get('versionString')} — {at.get('appStoreState')}")
        print(f"    id     : {v['id']}")
        print(f"    plateforme : {at.get('platform')}")
        print()


def _patch(chemin: str, type_: str, id_: str, attributs: dict) -> None:
    corps = {"data": {"type": type_, "id": id_, "attributes": attributs}}
    r = appel("PATCH", chemin, json=corps,
              headers={"Content-Type": "application/json"})
    if r.status_code >= 300:
        sys.exit(f"HTTP {r.status_code} sur {chemin}\n{r.text[:600]}")


def etat_fiche(version_id: str, app_id: str) -> None:
    """Affiche ce qui est deja rempli, avant toute modification."""
    print("— Fiche de version (description, mots-cles, URLs) —\n")
    for loc in get(f"/appStoreVersions/{version_id}/appStoreVersionLocalizations")["data"]:
        at = loc["attributes"]
        print(f"  [{at['locale']}]  id={loc['id']}")
        for champ in ("description", "keywords", "promotionalText",
                      "supportUrl", "marketingUrl"):
            v = at.get(champ)
            apercu = "(vide)" if not v else (v[:70] + "…" if len(v) > 70 else v)
            print(f"    {champ:16} {apercu}")
        print()

    print("— Fiche d'app (nom, sous-titre, confidentialite) —\n")
    infos = get(f"/apps/{app_id}/appInfos")["data"]
    for info in infos:
        for loc in get(f"/appInfos/{info['id']}/appInfoLocalizations")["data"]:
            at = loc["attributes"]
            print(f"  [{at['locale']}]  id={loc['id']}")
            for champ in ("name", "subtitle", "privacyPolicyUrl"):
                v = at.get(champ)
                print(f"    {champ:16} {v or '(vide)'}")
            print()



# — Contenu de la fiche US. Source de vérité : store/ASO.md —

SOUS_TITRE = "AI headshots & photo styles"

MOTS_CLES = ("yearbook,filter,face,editor,generator,makeover,glow up,art,"
             "retro,aesthetic,prom,luxury,transform")

PROMO = ("New styles every week. Turn your selfie into a 90s yearbook photo, "
         "a movie poster or a luxury lifestyle shot. Results in seconds.")

BASE_URL = "https://ladiflefou.github.io/morfo"

DESCRIPTION = """Turn your photos into real transformations with AI.

Upload a selfie, pick a style, and let Morfo do the rest. In seconds your \
portrait becomes epic, cinematic, retro or glamorous — then turns into a \
unique holographic card you'll actually want to share.

14 STYLES, MORE EVERY WEEK
90s yearbook photo, Renaissance oil painting, blockbuster movie poster, \
golden hour light, quiet luxury, flash party shot, prom night, luxury \
lifestyle, blocky cube world, open-world game art and more.

WRITE YOUR OWN STYLE
Free prompt mode understands what you ask and fills in the rest: "as a \
medieval king on his throne" is enough to get the crown, the fur, the \
heraldic banners.

STUNNING BEFORE / AFTER
Slide to compare your original photo with the result. The wow moment, \
every time.

A HOLOGRAPHIC CARD TO COLLECT
Every result becomes a spectral foil card that reacts as you tilt your \
phone. Made for your story.

YOUR PHOTOS STAY YOURS
They are used only to produce your result. Never stored, never sold, never \
used for advertising.

SUBSCRIPTION
The subscription unlocks every style watermark-free, high-resolution \
renders, and tops up 650 credits every week — around fifteen images. It \
renews automatically and can be cancelled anytime in your App Store account \
settings."""


def remplir_fiche(version_loc_id: str, info_loc_id: str) -> None:
    """Ecrit la fiche US. Idempotent : relancer ecrase avec les memes valeurs."""
    _patch(f"/appStoreVersionLocalizations/{version_loc_id}",
           "appStoreVersionLocalizations", version_loc_id, {
               "description": DESCRIPTION,
               "keywords": MOTS_CLES,
               "promotionalText": PROMO,
               "supportUrl": f"{BASE_URL}/",
               "marketingUrl": f"{BASE_URL}/",
           })
    print("description, mots-cles, texte promo et URLs : ecrits")

    _patch(f"/appInfoLocalizations/{info_loc_id}",
           "appInfoLocalizations", info_loc_id, {
               "subtitle": SOUS_TITRE,
               "privacyPolicyUrl": f"{BASE_URL}/privacy.html",
           })
    print("sous-titre et URL de confidentialite : ecrits")


COMMANDES = {"apps": lister_apps}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(f"Commandes : {', '.join(COMMANDES)} | app <id>")
    if sys.argv[1] == "remplir" and len(sys.argv) > 3:
        remplir_fiche(sys.argv[2], sys.argv[3])
    elif sys.argv[1] == "fiche" and len(sys.argv) > 3:
        etat_fiche(sys.argv[2], sys.argv[3])
    elif sys.argv[1] == "app" and len(sys.argv) > 2:
        detail_app(sys.argv[2])
    elif sys.argv[1] in COMMANDES:
        COMMANDES[sys.argv[1]]()
    else:
        sys.exit(f"Commande inconnue : {sys.argv[1]}")
