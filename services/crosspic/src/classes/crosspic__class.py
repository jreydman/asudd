import base64
import io
from PIL import Image

# ------------------------------------------------------------------------------

class Crosspic:

    # --------------------------------------------------------------------------

    def __init__(
        self,
        perinf_id: int,
        buffer,
        axis_width: float,
        axis_height: float,
        scale: float=18.5,
        angle: float=0
    ):
        self.perinf_id = perinf_id
        self.buffer = buffer
        self.axis_width = axis_width
        self.axis_height = axis_height
        self.scale = scale
        self.angle = angle

        if isinstance(self.buffer, str):
            image_bytes = base64.b64decode(self.buffer)
        else:
            image_bytes = base64.b64decode(self.buffer.decode("ascii"))

        image = Image.open(io.BytesIO(image_bytes))
        self.width, self.height = image.size

    # --------------------------------------------------------------------------

    def __str__(self) -> str:
        return f'''
Crosspic [perinf_id:{self.perinf_id}]:
    buffer: base64 / len({len(self.buffer)})
    width: {self.width}
    height: {self.height}
    axis_width: {self.axis_width}
    axis_height: {self.axis_height}
    scale: {self.scale}
    angle: {self.angle}
        '''
