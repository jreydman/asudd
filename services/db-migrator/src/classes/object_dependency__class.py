from dataclasses import dataclass
from src.classes.object__class import Object

# ------------------------------------------------------------------------------

@dataclass
class ObjectDependency:
    master_id: type(Object.id)
    slave_id: type(Object.id)
