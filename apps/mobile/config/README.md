# Backend config (public values only)

`backend.json` — FORENSIC EXPERT's own Supabase project (`forensic-expert`,
eu-central-1). Contains ONLY the project URL and the **publishable** key,
which is public by design (it ships inside every APK/IPA; access is enforced
by Row Level Security and server functions). No service-role key, SMTP
password, Gemini key or signing material may ever be added here.

Build: `flutter build apk --dart-define-from-file=config/backend.json`
(the release workflows do this automatically unless the
`FE_SUPABASE_URL` / `FE_SUPABASE_ANON_KEY` secrets override it).
