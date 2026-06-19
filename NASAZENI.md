# Tatvy — nasazení na `tatvy.oaza-adamanthea.cz`

Kompletní postup. Počítej s cca 20–30 minutami. Pořadí dodrž.

---

## 0) Co je ve složce

```
index.html                 hlavní appka (PWA)
admin.html                 chráněná stránka se statistikami
manifest.webmanifest       definice instalovatelné appky
sw.js                      service worker (offline + cache)
vercel.json                hlavičky pro SW a manifest
nabidky.json               seznam "Tip z Oázy" (edituješ ty)
api/stats.js               serverless funkce čtoucí statistiky
sql/tatvy_analytika.sql    SQL pro Supabase (tabulka + funkce)
icons/                     ikony appky
qr-tatvy.png               QR kód na tiskoviny
```

---

## 1) Supabase (projekt `myybuesoourgpbouwwst`)

**1a. Spusť SQL**
- Supabase → **SQL Editor** → **New query**
- Vlož celý obsah `sql/tatvy_analytika.sql` → **Run**
- Vytvoří tabulku `tatvy_navstevy`, RLS „jen insert" a funkci `tatvy_stats()`.

**1b. Vezmi si klíče** (Supabase → **Settings → API**)
- **Project URL**: `https://myybuesoourgpbouwwst.supabase.co`
- **anon / publishable key** — půjde do `index.html` (krok 2)
- **service_role key** — půjde do Vercelu jako env proměnná (krok 3). Tenhle nikam nepiš do kódu appky!

---

## 2) Vlož anon klíč do appky

- Otevři `index.html`, na konci `<script>` najdi řádek:
  ```js
  var SUPA_ANON='VLOZ_ANON_KEY';
  ```
- Nahraď `VLOZ_ANON_KEY` svým **anon** klíčem (v uvozovkách). Příklad:
  ```js
  var SUPA_ANON='eyJhbGciOiJIUzI1NiIsInR5cCI6...';
  ```
- Ulož. (Dokud to neuděláš, appka funguje, ale neměří návštěvy.)

---

## 3) Vercel — nový projekt „tatvy"

Máš dvě možnosti, vyber jednu:

### A) Přes Vercel CLI (nejrychlejší, jako u `prihlaska-pyramidy`)
1. V terminálu ve složce `tatvy-pwa/`:
   ```bash
   vercel
   ```
   - Set up and deploy → **Y**
   - Project name → `tatvy`
   - Directory → `./` (jsi přímo ve složce)
   - Framework → **Other** (žádný build)
2. Nastav env proměnné:
   ```bash
   vercel env add SUPABASE_URL
   vercel env add SUPABASE_SERVICE_KEY
   vercel env add ADMIN_HESLO
   ```
   (u každé vyber **Production**, vlož hodnotu)
3. Nasaď naostro:
   ```bash
   vercel --prod
   ```

### B) Přes web Vercelu (drag & drop nebo GitHub)
1. Vercel → **Add New… → Project**
2. Buď napoj GitHub repo (např. `lukassirael-stack/tatvy`), nebo nahraj složku.
3. **Framework Preset: Other**, žádný build command, Output: ponech prázdné (statické + `/api`).
4. **Settings → Environment Variables** přidej (pro Production):
   | Name | Value |
   |---|---|
   | `SUPABASE_URL` | `https://myybuesoourgpbouwwst.supabase.co` |
   | `SUPABASE_SERVICE_KEY` | *(service_role klíč ze Supabase)* |
   | `ADMIN_HESLO` | *(tvoje heslo do admin stránky)* |
5. **Deploy.** Po změně env proměnných dej ještě jednou **Redeploy**, ať se načtou.

---

## 4) Doména `tatvy.oaza-adamanthea.cz`

1. Ve Vercel projektu → **Settings → Domains → Add**
2. Zadej `tatvy.oaza-adamanthea.cz`.
3. Vercel ti ukáže DNS záznam. U svého DNS poskytovatele (tam, kde máš `kviz` a `mapa-zivota`) přidej:
   - **CNAME**: `tatvy` → `cname.vercel-dns.com` (přesnou hodnotu vezmi z Vercelu)
4. Počkej na ověření (obvykle pár minut, někdy déle). HTTPS certifikát Vercel vyřeší sám.

> QR kód i instalační tlačítko začnou fungovat **až teď**, když doména žije.

---

## 5) Test (na telefonu i počítači)

- [ ] `https://tatvy.oaza-adamanthea.cz` se otevře, běží aktuální tatva, odpočet jede.
- [ ] Rozvrh „Nejbližší proudy" se rozklikává.
- [ ] „Tip z Oázy" ukazuje nabídku a proklik vede na web.
- [ ] **Android:** objeví se „Přidat na plochu"; po instalaci appka běží fullscreen.
- [ ] **iPhone:** vidíš nápovědu Sdílet → Přidat na plochu; po přidání jede z plochy.
- [ ] **Offline:** zapni letový režim, appka se pořád otevře a počítá tatvu.
- [ ] **Statistiky:** otevři `tatvy.oaza-adamanthea.cz/admin.html`, zadej `ADMIN_HESLO`, čísla naskočí (po pár otevřeních appky).
- [ ] Naskenuj `qr-tatvy.png` — otevře appku.

---

## 6) Šíření

- **Newsletter (Beehiiv):** odkaz `tatvy.oaza-adamanthea.cz` + krátké „Tvoje tatvy vždy po ruce".
- **Facebook / Instagram:** příspěvek + odkaz v biu.
- **Web Oázy:** dlaždice nebo odkaz v nabídce.
- **Tiskoviny / centrum / akce:** `qr-tatvy.png` (klidně v tvém letákovém stylu ivory/navy/gold).

---

## 7) Údržba

- **Změna tipů:** uprav `nabidky.json` (pole `nadpis` / `text` / `url`), nahraj, hotovo. Appka si stáhne čerstvou verzi.
- **Změna textů/činností tatev:** pole `TATTVAS` v `index.html`.
- **Po úpravě appky** zvyš ve `sw.js` verzi cache: `const CACHE = 'tatvy-v1'` → `'tatvy-v2'` (jinak lidem může držet stará verze). Pak redeploy.
- **Statistiky** čteš kdykoli na `/admin.html`.

---

## Poznámky k bezpečnosti a soukromí

- **anon klíč** v `index.html` je v pořádku — umí jen zapsat návštěvu, číst data nemůže (RLS).
- **service_role klíč** je jen na serveru (env proměnná), nikdy v kódu appky.
- Měření je **anonymní** (náhodné ID v zařízení, žádné jméno/e-mail/IP). Doporučuju přidat jednu větu do zásad o anonymní statistice návštěvnosti. (Orientačně — nejsem právník.)
