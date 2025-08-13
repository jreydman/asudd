CREATE OR REPLACE FUNCTION public.func__truncate_tables()
RETURNS void AS $$
DECLARE
  sql text;
BEGIN
  SELECT string_agg(format('%I.%I', schemaname, tablename), ', ')
  INTO sql
  FROM pg_tables
  WHERE schemaname = 'public'
    AND tablename <> '__diesel_schema_migrations';

  IF sql IS NOT NULL THEN
    EXECUTE 'TRUNCATE ' || sql || ' RESTART IDENTITY CASCADE;';
  END IF;
END;
$$ LANGUAGE plpgsql;
