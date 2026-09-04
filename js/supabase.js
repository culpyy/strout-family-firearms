// Loaded after the Supabase CDN script tag on every page that touches the DB:
// <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
// then <script src="js/supabase.js"></script>.
const SUPABASE_URL = 'https://ceowfkvvhjnwmmhcslti.supabase.co'
const SUPABASE_ANON_KEY = 'sb_publishable_4fBzXrtNs1Nro6uk5-3KBQ_BEd2ZzfK'

var supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
