# Misnamed public dump — not Carsemble web

> **Warning:** This GitHub repository is named `carsemble` but it is **not** the Carsemble product.
> Contents are an older **FKM LMS (Fit Karnataka Mission)** Flutter / webinar client dump (`pubspec` name: `webinar`).

## Canonical repositories

| Product | Repo | Notes |
|---------|------|--------|
| **Carsemble** (web) | [`vanshjhamb9/carsemble2.o`](https://github.com/vanshjhamb9/carsemble2.o) (private) | Live site: https://carsemble.vercel.app |
| **FKM** (mobile) | [`vanshjhamb9/FKM-App`](https://github.com/vanshjhamb9/FKM-App) (private) | Source of truth for the student app |
| **This repo** | `vanshjhamb9/carsemble` (public) | Stale FKM dump — candidate to **archive** (CTO decision D3) |

Also related: public empty [`carsemble1`](https://github.com/vanshjhamb9/carsemble1) — delete candidate.

## Why this banner exists

Public search for “carsemble” currently lands on FKM Flutter code. That confuses brand identity. Prefer the private `carsemble2.o` / `FKM-App` repos above until this dump is archived or renamed.

## Original dump note

FKM LMS (Fit Karnataka Mission) Flutter project snapshot. Do not treat as production Carsemble or as the current FKM-App tip.

## Hygiene

Removed root/`tool` `login_debug.dart` scripts that embedded sample login credentials (`apiKey`/`password`) from this public dump.

Also cleared default `apiKey=1234` / LAN HTTP host in `lib/common/utils/constants.dart` and removed `print(token)` from `http_handler.dart`.

Also removed auth/cart/assignment `print(body|res.body)` debug lines and scrubbed the integration guide’s hard-coded `x-api-key: 1234` example.
