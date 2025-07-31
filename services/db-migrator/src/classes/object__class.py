from dataclasses import dataclass
from src.classes.object_type__class import ObjectType

# ------------------------------------------------------------------------------

@dataclass
class Object:
    id: int
    type: ObjectType
    is_active: bool
    attributes: dict
    created_at: str
    updated_at: str
