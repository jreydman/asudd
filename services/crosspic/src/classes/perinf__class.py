from classes.object_type__class import ObjectType
from classes.crosspic__class import Crosspic
from classes.perinf_location__class import PerinfLocation

# ------------------------------------------------------------------------------

class Perinf:

    # --------------------------------------------------------------------------

    def __init__(
        self,
        id: int,
        name: str,
        crosspic: Crosspic = None,
        location: PerinfLocation = None
    ):
        self.type = ObjectType.Crossroad
        self.id = id
        self.name = name
        self.crosspic = crosspic
        self.location = location

    # --------------------------------------------------------------------------

    def __str__(self) -> str:
        crosspic_str = (
            '\n' + '\n'.join('\t' + line for line in str(self.crosspic).strip().splitlines())
            if self.crosspic else ' None'
        )
        return f'''Perif [id:{self.id}]:
    type: {self.type.value}
    name: {self.name}
    location: {self.location if self.location else 'None'}
    crosspic:{crosspic_str}
    '''
