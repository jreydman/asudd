DO $$
DECLARE
  tbl text;
  sql text;
BEGIN
  SELECT string_agg(format('%I.%I', schemaname, tablename), ', ')
  INTO sql
  FROM pg_tables
  WHERE schemaname = 'public'
    AND tablename <> 'spatial_ref_sys';

  IF sql IS NOT NULL THEN
    EXECUTE 'TRUNCATE ' || sql || ' RESTART IDENTITY CASCADE;';
  END IF;
END
$$;
