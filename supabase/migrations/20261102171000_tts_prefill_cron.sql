-- Applied on prod 2026-11-02 after a manual 3-slide test of tts-prefill.
-- Requires the Vault secret `tts_prefill_token` (created by the operator, not
-- stored in git). Undo: select cron.unschedule('tts-prefill');
select cron.schedule('tts-prefill', '*/10 * * * *', $job$
  select net.http_post(
    url := 'https://igvzlmpgwybjdgkyowrl.supabase.co/functions/v1/tts-prefill',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-prefill-token', (select decrypted_secret from vault.decrypted_secrets where name = 'tts_prefill_token')),
    body := '{"action":"run","max":8}'::jsonb,
    timeout_milliseconds := 10000);
$job$);
