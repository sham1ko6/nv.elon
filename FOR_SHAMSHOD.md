# FOR SHAMSHOD — real-world things YOU will need to set up later

This is the **non-coding** stuff. I (the developer side) build the software; these
are accounts, services and registrations only **you**, the owner, can create —
usually because they need your identity, your business, or your money/bank.

You do **not** need these yet. This list is just so you know what's coming and can
start preparing (some, like a business registration or a Payme merchant account,
take days or weeks to approve). Roughly in the order you'll need them.

## A. Needed before real users can use it (launch essentials)

1. **Domain name** — your web address, e.g. `nvelon.uz`. Used for the API and the
   admin website. (Buy from a domain registrar; UZ `.uz` domains via local providers.)

2. **Server / hosting (VPS)** — a computer in the cloud that runs the backend and
   database 24/7 so the app is always online. (e.g. a cloud VPS — DigitalOcean,
   Hetzner, or a local Uzbek hosting provider.)

3. **HTTPS / SSL certificate** — makes the connection encrypted and secure (the
   padlock in the browser). Required for payments and app stores. (Usually free via
   Let's Encrypt — I set it up, you just need the domain + server first.)

4. **Production MySQL database** — the real database on the server (the schema we
   already wrote runs there). Can live on the same VPS or a managed DB service.

5. **Business / legal registration** — a registered company or sole proprietor
   (yakka tartibdagi tadbirkor) in Uzbekistan. **Payme and Click require this** to
   open a merchant account, and you need it to legally collect money.

6. **Bank account (business)** — where the money the platform earns actually lands.
   Payme/Click pay out (settle) into this account.

7. **Payme merchant account** — lets users pay you through Payme. Needs your business
   + bank account. They give you merchant keys that I plug into the backend.

8. **Click merchant account** — same as Payme, but for Click. Many Uzbek users prefer
   one or the other, so supporting both is worth it.

9. **SMS / OTP service** — sends the login code by SMS (so users sign in with their
   phone number). (Local options: Eskiz.uz, Play Mobile. You register and get an API key.)

## B. Needed to publish the mobile app

10. **Google Play Developer account** — to publish the Android app. One-time ~$25 fee.

11. **Apple Developer account** — to publish the iPhone app. ~$99 per year. (Skip if
    you only target Android at first.)

12. **Privacy policy + Terms of Service** — short legal pages about how you handle
    user data and phone numbers. **Required** by the app stores and good practice.

## C. Can wait / optional (add when you grow)

13. **Image storage** — where uploaded ad photos are kept. Can start on the server's
    own disk; move to S3-compatible storage (Wasabi, Backblaze) when it grows.

14. **Automated backups** — scheduled copies of the database so you never lose data.

15. **Email service** — for receipts / notifications by email (e.g. SendGrid, Mailgun).
    Optional; SMS is more important in Uzbekistan.

16. **Push notifications** — "your ad/subscription expires in 3 days" alerts on the
    phone. (Firebase Cloud Messaging — free.)

17. **Analytics / error tracking** — to see usage and catch crashes (e.g. Sentry).

---

### Quick mental model
- **Money flow:** user pays → **Payme/Click** → your **business bank account**.
  (Needs: business registration → bank account → merchant accounts.)
- **Being online:** **domain** → **server** → **HTTPS** → **database**.
- **Logging in:** **SMS service** sends the OTP code.
- **Reaching users:** **Play/Apple** accounts to publish the app.

Start early on the slow ones: **business registration**, **Payme/Click merchant
approval**, and the **bank account** — these depend on each other and take the longest.
