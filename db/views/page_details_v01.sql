select
  pg.owner_id
  ,pg.owner_type
  ,json_build_object(
    'id', pg.id,
    'html', pg.html,
    'contents', pg.contents
  ) as page
from pages pg
