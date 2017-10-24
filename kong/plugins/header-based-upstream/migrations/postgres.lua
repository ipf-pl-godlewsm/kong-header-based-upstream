return {
    {
      name = "2017-10-12-_init_header-based-upstream",
      up = [[
        CREATE TABLE IF NOT EXISTS header_based_upstream_urls(
            id uuid,
            api_id uuid REFERENCES apis (id) ON DELETE CASCADE,
            name text,
            headers json,
            upstream_url text,
            created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
            PRIMARY KEY (id)  
        );
        DO $$
        BEGIN
          
          IF (SELECT to_regclass('header_based_upstream_urls_api_id_idx')) IS NULL THEN
            CREATE INDEX header_based_upstream_urls_api_id_idx ON header_based_upstream_urls(api_id);
          END IF;
          
        END$$;
      ]],
      down = [[
        DROP TABLE header_based_upstream_urls;
      ]]
    }
  }
