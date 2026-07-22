"""Attache la capture de review exigée sur chaque achat intégré.

Sans elle, Apple laisse le produit en `MISSING_METADATA` — et un produit dans
cet état **n'est pas renvoyé par StoreKit**, même en sandbox. Le paywall
apparaît alors vide sans qu'aucune erreur ne l'explique.

Lancer : .venv-asc/bin/python tools/asc_review_shots.py
"""

import hashlib
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import requests  # noqa: E402

from asc import appel  # noqa: E402

RACINE = Path(__file__).resolve().parent.parent
CAPTURES = RACINE / "build" / "screenshots" / "ordonnees"

V2 = "https://api.appstoreconnect.apple.com/v2/inAppPurchases"

# Chaque produit reçoit la capture de l'écran où il s'achète réellement.
ABONNEMENTS = {
    "6793321113": "5_essai_gratuit.png",
    "6793321196": "5_essai_gratuit.png",
}
PACKS = {
    "6793321378": "5_essai_gratuit.png",
    "6793321246": "5_essai_gratuit.png",
    "6793321415": "5_essai_gratuit.png",
}


def _televerser(endpoint: str, type_: str, relation: str, type_relation: str,
                cible_id: str, image: Path) -> bool:
    octets = image.read_bytes()

    r = appel("POST", endpoint,
              json={"data": {
                  "type": type_,
                  "attributes": {"fileName": image.name,
                                 "fileSize": len(octets)},
                  "relationships": {relation: {
                      "data": {"type": type_relation, "id": cible_id}}}}},
              headers={"Content-Type": "application/json"})
    if r.status_code >= 300:
        print(f"    réservation : HTTP {r.status_code} {r.text[:160]}")
        return False

    data = r.json()["data"]
    shot_id = data["id"]

    # L'URL de téléversement est pré-signée : y ajouter le jeton la ferait
    # rejeter.
    for op in data["attributes"]["uploadOperations"]:
        entetes = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        rep = requests.request(op["method"], op["url"],
                               data=octets[op["offset"]:op["offset"] + op["length"]],
                               headers=entetes, timeout=120)
        if rep.status_code >= 300:
            print(f"    envoi : HTTP {rep.status_code}")
            return False

    base = endpoint.rsplit("?", 1)[0]
    r = appel("PATCH", f"{base}/{shot_id}",
              json={"data": {"type": type_, "id": shot_id,
                             "attributes": {
                                 "uploaded": True,
                                 "sourceFileChecksum":
                                     hashlib.md5(octets).hexdigest()}}},
              headers={"Content-Type": "application/json"})
    if r.status_code >= 300:
        print(f"    confirmation : HTTP {r.status_code} {r.text[:160]}")
        return False
    return True


def main() -> None:
    for sid, fichier in ABONNEMENTS.items():
        ok = _televerser(
            "https://api.appstoreconnect.apple.com/v1/subscriptionAppStoreReviewScreenshots",
            "subscriptionAppStoreReviewScreenshots", "subscription",
            "subscriptions", sid, CAPTURES / fichier)
        print(f"  abonnement {sid} : {'OK' if ok else 'ECHEC'}")

    for pid, fichier in PACKS.items():
        ok = _televerser(
            "https://api.appstoreconnect.apple.com/v1/inAppPurchaseAppStoreReviewScreenshots",
            "inAppPurchaseAppStoreReviewScreenshots", "inAppPurchaseV2",
            "inAppPurchases", pid, CAPTURES / fichier)
        print(f"  pack {pid} : {'OK' if ok else 'ECHEC'}")


if __name__ == "__main__":
    main()
