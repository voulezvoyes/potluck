// Potluck public browser configuration.
// These values are safe to expose in the browser ONLY because database access
// is protected by Row Level Security. Never put a service_role key here.
window.POTLUCK_CONFIG = {
  supabaseUrl: "YOUR_SUPABASE_PROJECT_URL",
  supabaseKey: "YOUR_SUPABASE_PUBLISHABLE_KEY"
};
