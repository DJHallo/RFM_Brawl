# RFM Brawl: Castle Arena

Oryginalna bijatyka 2D w Godot. Układ fal nawiązuje do Stage Mode w Little Fighter 2: kampania ma pięć stref, serię fal i walki z bossem. Grywalni bohaterowie korzystają z postaci z paczki SHADOW Series. Dźwięki walki, menu i ambient zamku są syntezowane proceduralnie w grze.

## Uruchomienie

Otwórz `project.godot` w Godot 4.7.2 i uruchom projektem klawiszem F5.

## GitHub i grafiki

Repozytorium pomija surowe pliki zewnętrznych paczek graficznych ze względu na warunki ich autorów. Po sklonowaniu projektu pobierz wskazane darmowe paczki (lub kup wymagane wersje), a następnie odtwórz foldery `assets/enemies/`, `assets/heroes/shadow/`, `assets/effects/blood/` i `assets/effects/fire/` według [ASSET_LICENSES.md](ASSET_LICENSES.md). Bez tych plików pełna wersja gry nie uruchomi się poprawnie. Nie dodawaj tych folderów do repozytorium.

Szczegółowe źródła, warunki i autorzy assetów są w [ASSET_LICENSES.md](ASSET_LICENSES.md). Projekt nie ma jeszcze wybranej licencji open source dla kodu.

## Menu

- **Start Game** otwiera wybór bohatera, a potem wybór Stage Mode albo Survival Mode.
- **Resume** wraca do rozgrywki zachowanej w bieżącej sesji.
- **Options** ustawia poziom trudności Easy, Normal lub Hard; bohater gracza regeneruje 1,8 HP/s na Easy i 0,65 HP/s na Normal, a na Hard regeneracja jest wyłączona. Przeciwnicy nie regenerują życia.
- **Exit Game** zamyka grę.
- Menu główne ma pionową listę po lewej na tle nowoczesnego zamku, sprężyste animacje przycisków i podpis **DJHallo Games** w prawym dolnym rogu.

## Bohaterowie i style walki

- **Cinderguard — Shadow Knight:** Nightfall Slash, doskok i ciężkie cięcie. Combo korzysta z ataków podstawowych, drugiego ciosu i ataku z wyskoku.
- **Duskstalker — Veil Ranger:** Phantom Dash, specjalny doskok przecinający linię przeciwników. Zwykłe combo nie uruchamia dasha.

To dwie grywalne postacie dostępne obecnie w wyborze; nie pojawiają się jako przeciwnicy. Ich animacje ruchu, ataków, skoków, trafienia i śmierci pochodzą z paczki SHADOW Series.
## Fale i sterowanie

Stage Mode ma pięć stref. W każdej przechodzi się przez pięć akt, a każdy akt składa się z trzech fal; ostatnia fala finałowego aktu zawiera bossa. Wszyscy przeciwnicy i bossowie wchodzą z prawej krawędzi ekranu, a ich pościg ma spokojniejsze tempo. Mleko pojawia się jako leczący przedmiot. Survival Mode powtarza fale bez końca i wprowadza bossów co pięć fal.

- Ruch: WASD albo strzałki
- Combo ataków: J albo spacja
- Umiejętność: K albo Shift; każda zużywa MP
- Menu w czasie gry: Esc lub przycisk MENU
- Android: w grze używaj analogowego joysticka po lewej oraz dużych przycisków **ATTACK** i **SPECIAL** po prawej; w menu wybierz kartę bohatera i naciśnij **CONTINUE**
- Po nokaucie: **Resume** wznawia walkę od początku tej samej fali, a **Open Menu** otwiera menu główne
- HUD pokazuje życie i manę jako czerwony i niebieski pasek z ikonami serca i gwiazdy

## Przeciwnicy

- Dostępne typy z paczek: Soldier, Orc, Archer i Orc Champion z **Tiny RPG Character Asset Pack v1.03 — Free Soldier & Orc**, Hobbit Scout i Hobbit Raider z **GAP Hobbit** oraz Shadowed Wetlands Boss. Wszystkie są w rotacji fal; boss pojawia się też w falach finałowych.
- Liczba wrogów rośnie co dwie fale i wraz z kolejnymi etapami. HP i obrażenia typów pozostają stałe; wybrany poziom trudności zmienia liczbę przeciwników. Hobbit używa animacji idle, run, stop, jump, block, hit, death i wszystkich 17 klatek ataku. Soldier, Orc i Wetlands Boss wykorzystują dostępne im animacje ruchu, ataków, trafienia oraz śmierci.

## Grafiki

- `assets/castle_menu_background.png` — pełnoekranowe tło nowoczesnego zamku dla menu głównego
- `assets/castle_corridor.png` — wygenerowane tło zamkowego korytarza biegnącego w poziomie, z czerwonym dywanem; płomienie i odbicia pochodni migoczą w grze
- `assets/heroes/shadow/` — animacje dwóch wybieralnych postaci z paczki SHADOW Series — The Free Assets
- `assets/enemies/` — grafiki przeciwników Soldier & Orc oraz Hobbit, skopiowane do projektu z paczek wskazanych przez użytkownika
- `assets/game_logo_blended.png` — logo wycięte z tła, z metalicznym złoto-błękitnym cieniowaniem dopasowanym do menu
- `assets/effects/fire/` — animowane płomienie pochodni z paczki Pixel Fire Asset Pack v1.2
- `assets/effects/blood/` — klatki animacji krwi z BloodFX Batch 1, wyświetlane przy trafieniach ataków wręcz, specjalnych i pocisków
- `assets/fighters_atlas.png` — wcześniejszy atlas koncepcyjny
- Dźwięki ataków, trafień, menu, ukończenia fali i ambient zamku są generowane z poziomu `main.gd` i nie wymagają dodatkowych plików audio.

To projekt źródłowy Godot, nie gotowy plik APK. Eksport Android wymaga szablonów eksportu Godota oraz Android SDK/JDK.















