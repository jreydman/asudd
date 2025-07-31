from dataclasses import dataclass, field
from src.classes.object__class import Object
from src.classes.object_type__class import ObjectType

# ------------------------------------------------------------------------------

@dataclass
class ObjectGateway(Object):
    type: ObjectType = field(init=False, default=ObjectType.Gateway)
    is_inbound: bool
    is_outbound: bool
