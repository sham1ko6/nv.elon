# Run nv.elon on your computer (backend + app)

You will use **two terminal windows**:
- **Terminal 1** runs the backend server (stays open the whole time).
- **Terminal 2** runs the Flutter app in Chrome (stays open the whole time).

Do the parts in order. After each command, the expected result is written below it.

---

## PART A — Database (do this once)

### A0. Clear any half-started database process
```
sudo pkill -x mysqld
```
✅ It returns to the prompt. If it prints nothing, that's also fine.
(This removes a stray old database process that would block the real one.)

### A1. Start MariaDB (this is the fix for your "port 3306" problem)
```
sudo systemctl start mariadb
```
✅ It asks for your computer password, then returns to the prompt with no message.
⚠️ If it says **"Job for mariadb.service failed"**, run `sudo pkill -x mysqld` again,
   wait 3 seconds, then re-run this command.

### A2. Confirm the database is now reachable on port 3306
```
ss -tlnp | grep 3306
```
✅ You should see a line containing `127.0.0.1:3306` and `mariadbd`.
   That means the port-3306 issue is fixed. If nothing prints, A1 didn't work — retry it.

### A3. Create the database and all tables
```
sudo mysql < /home/shamshod/nv.elon/backend/db/schema.sql
```
✅ No message = success.

### A4. Load the sample data (categories, plans, a few ads, a demo user)
```
sudo mysql < /home/shamshod/nv.elon/backend/db/seed.sql
```
✅ No message = success.

### A5. Create the database account the app uses
```
sudo mysql -e "CREATE USER IF NOT EXISTS 'nvuser'@'127.0.0.1' IDENTIFIED BY 'nvpass123'; GRANT ALL PRIVILEGES ON nv_elon.* TO 'nvuser'@'127.0.0.1'; FLUSH PRIVILEGES;"
```
✅ No message = success.

### A6. (Optional) Prove the account works
```
mysql -h 127.0.0.1 -u nvuser -pnvpass123 nv_elon -e "SELECT COUNT(*) AS ads FROM listings;"
```
✅ Prints a tiny table with a number (e.g. `4`). (No space after `-p` — that's normal.)

---

## PART B — Backend server (Terminal 1 — keep it open)

### B1. Go to the backend folder
```
cd /home/shamshod/nv.elon/backend
```

### B2. Install (already done once, safe to repeat)
```
npm install
```
✅ Ends with something like "up to date" or "added N packages".

### B3. Start the server
```
npm start
```
✅ You should see:
```
⚠️  Dev routes enabled (/dev/*). Do NOT use in production.
✅ nv.elon API running at http://localhost:4000
✅ Database connection OK
```
The **"Database connection OK"** line is the one that matters.
⚠️ If you see **"Could NOT connect to the database"**, MariaDB isn't running (redo A1)
   or the account didn't get created (redo A5).

**Leave this terminal open.** Closing it stops the server.

### B4. (Optional) See it with your own eyes
Open Chrome and go to:  `http://localhost:4000/listings`
✅ You'll see raw data (text) listing the sample ads. That alone proves the backend works.

---

## PART C — The app (Terminal 2 — a NEW window)

### C1. Open a brand-new terminal window, then go to the app folder
```
cd /home/shamshod/nv.elon/flutter
```

### C2. Launch the app in Chrome
```
flutter run -d chrome
```
✅ It compiles (1–2 minutes the first time), then a Chrome window opens showing the
   nv.elon splash screen, then the Login / Register screen.
ℹ️ If no window opens but you see a `http://localhost:NNNNN` link in the terminal,
   just open that link in Chrome yourself.

**Leave this terminal open too.**

---

## PART D — Try it

1. **Register:** tap the **"Ro'yxatdan o'tish"** tab. Enter a name, a phone like
   `+998901234567`, an email, and a password (6+ characters). Tap the button.
   ✅ You land on the home feed showing the sample ads (loaded from your backend).
2. **Browse:** tap the round category icons, type in the search box.
3. **Post an ad:** tap **"Boshlash"** (or the + tab), fill the form, submit.
   ✅ The app sends it to the backend, auto-"pays" the posting fee (dev mode), and your
   new ad appears at the top of the feed — proof the whole chain works.
4. **Log in later / demo account:** a ready-made account exists from the sample data —
   phone **`+998901112233`**, password **`password123`**.

---

## Stopping everything
- In each terminal press **Ctrl + C**.
- To stop the database: `sudo systemctl stop mariadb`

## Common issues
| You see | Fix |
|--------|-----|
| `mariadb.service failed` (A1) | `sudo pkill -x mysqld`, wait, retry A1 |
| Backend: `Could NOT connect to the database` | MariaDB not started (A1) or user missing (A5) |
| App feed is empty after login | Backend terminal must show "Database connection OK"; restart `npm start` |
| App can't reach server | Make sure Terminal 1 still shows the server running |
