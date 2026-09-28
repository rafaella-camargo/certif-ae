select GeoKey, cidade, estado, pais
from {{ ref('int_geografia') }}
