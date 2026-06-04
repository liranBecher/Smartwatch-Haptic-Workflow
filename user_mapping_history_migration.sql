BEGIN;

ALTER TABLE public."User_UC_Mappings"
ADD COLUMN IF NOT EXISTS id bigint,
ADD COLUMN IF NOT EXISTS active boolean NOT NULL DEFAULT true,
ADD COLUMN IF NOT EXISTS assigned_at timestamp with time zone NOT NULL DEFAULT now(),
ADD COLUMN IF NOT EXISTS deactivated_at timestamp with time zone;

CREATE SEQUENCE IF NOT EXISTS public."User_UC_Mappings_id_seq";

UPDATE public."User_UC_Mappings"
SET id = nextval('public."User_UC_Mappings_id_seq"')
WHERE id IS NULL;

SELECT setval(
  'public."User_UC_Mappings_id_seq"',
  COALESCE((SELECT max(id) FROM public."User_UC_Mappings"), 0) + 1,
  false
);

ALTER TABLE public."User_UC_Mappings"
ALTER COLUMN id SET DEFAULT nextval('public."User_UC_Mappings_id_seq"'),
ALTER COLUMN id SET NOT NULL;

ALTER SEQUENCE public."User_UC_Mappings_id_seq"
OWNED BY public."User_UC_Mappings".id;

DO $$
DECLARE
  pk_name text;
BEGIN
  SELECT conname INTO pk_name
  FROM pg_constraint
  WHERE conrelid = 'public."User_UC_Mappings"'::regclass
    AND contype = 'p';

  IF pk_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public."User_UC_Mappings" DROP CONSTRAINT %I', pk_name);
  END IF;
END $$;

ALTER TABLE public."User_UC_Mappings"
ADD CONSTRAINT "User_UC_Mappings_pkey" PRIMARY KEY (id);

CREATE UNIQUE INDEX IF NOT EXISTS user_uc_mappings_one_active_per_user
ON public."User_UC_Mappings" (user_id)
WHERE active = true;

CREATE INDEX IF NOT EXISTS user_uc_mappings_restore_lookup
ON public."User_UC_Mappings" (user_id, assigned_at DESC, id DESC);

COMMIT;
