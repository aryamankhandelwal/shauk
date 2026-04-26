// SETUP: Copy this file to Secrets.swift and fill in your values.
// Secrets.swift is gitignored — never commit real keys.
//
// Get these from: Supabase Dashboard → Settings → API

enum Secrets {
    static let supabaseURL     = "https://YOUR_PROJECT_ID.supabase.co"
    static let supabaseAnonKey = "YOUR_ANON_PUBLIC_KEY"
    static let apiBaseURL      = "https://YOUR_VERCEL_PROJECT.vercel.app"
}
