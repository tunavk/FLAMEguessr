# Campus guessing game

A GeoGuessr-style game for one campus. Players see a photo and drop a pin on the campus map.
Photos, pin locations, the campus area and game settings are all managed from `admin.html`,
so the code never needs editing after setup.

## What's in the folder

| File | What it is |
| --- | --- |
| `index.html` | The game (Normal and Flash modes) |
| `admin.html` | The admin panel |
| `config.js` | Two values that connect both pages to your database. The only file you edit. |
| `setup.sql` | Creates the database tables and permissions. Run once. |

## One-time setup (about 15 minutes)

The photos and settings live in Supabase, a free hosted database. Menu names in its dashboard
may differ slightly from the ones below.

1. **Create a project.** Sign up at supabase.com, create a new project, and wait for it to finish starting.
2. **Create the tables.** Open **SQL Editor**, paste in everything from `setup.sql`, and press **Run**.
3. **Create your admin login.** Go to **Authentication > Users > Add user**. Enter your email and a
   password, and tick the auto-confirm option.
4. **Make that login an admin.** Back in the SQL Editor, run this with your email:

   ```sql
   insert into public.admins (user_id)
   select id from auth.users where email = 'you@example.com';
   ```

5. **Turn off public sign-ups.** In **Authentication > Sign In / Providers**, switch off
   "Allow new users to sign up". Only people on the admins list can change anything either way,
   but there is no reason to let strangers create accounts.
6. **Connect the pages.** In **Project Settings > API keys**, copy the Project URL and the
   publishable key (starts with `sb_publishable_`) into `config.js`. This key is meant to be public.
   Never put the secret key in these files.

## Try it on your laptop

Open the folder in VS Code, install the "Live Server" extension, right-click `index.html` and
choose "Open with Live Server". (Or run `python -m http.server` in the folder and open
http://localhost:8000.)

## Fill the game

1. Open `admin.html` and sign in.
2. In **Campus and game settings**, move the map until the campus fills the frame, press
   **Use this view as the campus area**, then **Save settings**.
3. In **Photos**, choose a photo, check the pin, and press **Save photo**. If the photo has GPS
   data the pin places itself. Phones often strip GPS when you upload from the phone's browser,
   so uploading from a laptop works better, or just click the map.
4. Untick **In the game** on any photo to hide it without deleting it.

Changes show up for players the next time they load the game.

## Put it online

1. Create a public repository on GitHub and upload these files.
2. In the repository, go to **Settings > Pages**, choose the `main` branch, and save.
3. Your game is at `https://your-username.github.io/your-repo/` and the admin panel is at `/admin.html`.

## Good to know

- Free Supabase projects pause after about a week with no visits. Resume it from the dashboard if that happens.
- Photo coordinates are sent to the player's browser, so a determined cheater can find them. Fine for a campus game.
- The street map comes from OpenStreetMap. If your campus looks empty there, switch the game to
  Satellite in settings, or add your buildings at openstreetmap.org. The satellite imagery is
  Esri's; check their terms if the game gets heavy traffic.
- Get permission before photographing people, and avoid faces and number plates.
