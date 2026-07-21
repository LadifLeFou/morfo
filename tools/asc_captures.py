"""Téléverse les captures App Store via l'API.

Apple impose un protocole en quatre temps par image : réserver l'emplacement,
suivre les instructions de téléversement renvoyées, confirmer, puis attendre la
validation côté Apple. Une image « uploadée » n'est pas encore acceptée.

Lancer : .venv-asc/bin/python tools/asc_captures.py <id-localisation-version>
"""

import hashlib
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import requests  # noqa: E402

from asc import appel, get  # noqa: E402

RACINE = Path(__file__).resolve().parent.parent
CAPTURES = RACINE / "build" / "screenshots"

# iPhone 6,9" (1320×2868) — le format exigé pour toute nouvelle soumission.
TYPE_AFFICHAGE = "APP_IPHONE_67"


def _creer_jeu(loc_id: str) -> str:
    existants = get(f"/appStoreVersionLocalizations/{loc_id}/appScreenshotSets")
    for jeu in existants.get("data", []):
        if jeu["attributes"].get("screenshotDisplayType") == TYPE_AFFICHAGE:
            # Repartir d'un jeu propre : sinon les relances empilent les images.
            for ancienne in get(f"/appScreenshotSets/{jeu['id']}/appScreenshots").get("data", []):
                appel("DELETE", f"/appScreenshots/{ancienne['id']}")
            return jeu["id"]

    r = appel("POST", "/appScreenshotSets",
              json={"data": {
                  "type": "appScreenshotSets",
                  "attributes": {"screenshotDisplayType": TYPE_AFFICHAGE},
                  "relationships": {"appStoreVersionLocalization": {
                      "data": {"type": "appStoreVersionLocalizations",
                               "id": loc_id}}}}},
              headers={"Content-Type": "application/json"})
    if r.status_code >= 300:
        sys.exit(f"création du jeu : HTTP {r.status_code}\n{r.text[:500]}")
    return r.json()["data"]["id"]


def _televerser(set_id: str, image: Path) -> str:
    octets = image.read_bytes()

    # 1. Réserver : Apple renvoie où et comment envoyer les octets.
    r = appel("POST", "/appScreenshots",
              json={"data": {
                  "type": "appScreenshots",
                  "attributes": {"fileName": image.name,
                                 "fileSize": len(octets)},
                  "relationships": {"appScreenshotSet": {
                      "data": {"type": "appScreenshotSets", "id": set_id}}}}},
              headers={"Content-Type": "application/json"})
    if r.status_code >= 300:
        sys.exit(f"réservation {image.name} : HTTP {r.status_code}\n{r.text[:400]}")

    data = r.json()["data"]
    shot_id = data["id"]

    # 2. Suivre les instructions : l'image peut être découpée en morceaux.
    for op in data["attributes"]["uploadOperations"]:
        morceau = octets[op["offset"]:op["offset"] + op["length"]]
        entetes = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        rep = requests.request(op["method"], op["url"], data=morceau,
                               headers=entetes, timeout=120)
        if rep.status_code >= 300:
            sys.exit(f"envoi {image.name} : HTTP {rep.status_code}\n"
                     f"{rep.text[:300]}")

    # 3. Confirmer avec l'empreinte, qui prouve l'intégrité du transfert.
    r = appel("PATCH", f"/appScreenshots/{shot_id}",
              json={"data": {"type": "appScreenshots", "id": shot_id,
                             "attributes": {
                                 "uploaded": True,
                                 "sourceFileChecksum":
                                     hashlib.md5(octets).hexdigest()}}},
              headers={"Content-Type": "application/json"})
    if r.status_code >= 300:
        sys.exit(f"confirmation {image.name} : HTTP {r.status_code}\n{r.text[:400]}")

    return shot_id


def _etat(shot_id: str) -> tuple:
    at = get(f"/appScreenshots/{shot_id}")["data"]["attributes"]
    etat = (at.get("assetDeliveryState") or {})
    return etat.get("state"), etat.get("errors")


def main(loc_id: str) -> None:
    images = sorted(CAPTURES.glob("*.png"))
    if not images:
        sys.exit(f"aucune capture dans {CAPTURES}")

    set_id = _creer_jeu(loc_id)
    print(f"jeu {TYPE_AFFICHAGE} créé ({set_id})\n")

    ids = []
    for image in images:
        shot_id = _televerser(set_id, image)
        ids.append((image.name, shot_id))
        print(f"  envoyé  {image.name}")

    # Apple valide les dimensions de façon asynchrone : un envoi réussi ne
    # garantit pas l'acceptation. On attend le verdict réel.
    print("\nvalidation par Apple…")
    for _ in range(20):
        etats = [(nom, *_etat(sid)) for nom, sid in ids]
        if all(e[1] == "COMPLETE" for e in etats):
            print("\ntoutes les captures sont acceptées")
            return
        if any(e[2] for e in etats):
            print("\nREFUS :")
            for nom, etat, err in etats:
                if err:
                    print(f"  {nom} → {err}")
            sys.exit(1)
        time.sleep(5)

    print("\ntoujours en cours de validation, relance la vérification plus tard")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("usage : asc_captures.py <id-localisation-version>")
    main(sys.argv[1])
