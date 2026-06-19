// Tatvy — admin statistiky. Čte agregace ze Supabase servisním klíčem.
// Env proměnné (Vercel → Settings → Environment Variables):
//   SUPABASE_URL          = https://myybuesoourgpbouwwst.supabase.co
//   SUPABASE_SERVICE_KEY  = (service_role key ze Supabase → Settings → API)
//   ADMIN_HESLO           = (tvoje heslo do admin stránky)

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Pouze POST' });
    return;
  }

  let heslo = '';
  try {
    const body = typeof req.body === 'string' ? JSON.parse(req.body || '{}') : (req.body || {});
    heslo = body.heslo || '';
  } catch (e) { heslo = ''; }

  if (!process.env.ADMIN_HESLO || heslo !== process.env.ADMIN_HESLO) {
    res.status(401).json({ error: 'Špatné heslo' });
    return;
  }

  try {
    const r = await fetch(`${process.env.SUPABASE_URL}/rest/v1/rpc/tatvy_stats`, {
      method: 'POST',
      headers: {
        apikey: process.env.SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${process.env.SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: '{}'
    });
    if (!r.ok) {
      const t = await r.text();
      res.status(500).json({ error: 'Supabase: ' + t });
      return;
    }
    const data = await r.json();
    res.setHeader('Cache-Control', 'no-store');
    res.status(200).json(data);
  } catch (e) {
    res.status(500).json({ error: String(e) });
  }
}
