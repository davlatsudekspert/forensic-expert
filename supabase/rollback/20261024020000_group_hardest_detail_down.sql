-- Rollback for 20261024020000_group_hardest_detail.sql (manual, owner-approved).
drop function if exists public.group_assignment_hardest_detail(uuid, int);
