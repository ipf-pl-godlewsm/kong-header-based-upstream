return {
  {
    name = "2017-10-12-_init_header-based-upstream",
    up =  [[
      CREATE TABLE IF NOT EXISTS header_based_upstream_urls(
        id uuid,
        api_id uuid,
        headers text,
        name text,
        upstream_url text,
        created_at timestamp,
        PRIMARY KEY (id)
      );
      CREATE INDEX IF NOT EXISTS header_based_upstream_api_id ON header_based_upstream_urls(api_id);
    ]],
    down = [[
      DROP TABLE header_based_upstream_urls;
    ]]
  }
}