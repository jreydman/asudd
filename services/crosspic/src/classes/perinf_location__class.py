class PerinfLocation:

    # --------------------------------------------------------------------------

    def __init__(self, perinf_id: int, lon: float, lat: float, angle: float=0):
        self.perinf_id = perinf_id
        self.lon = lon
        self.lat = lat
        self.angle = angle

    # --------------------------------------------------------------------------

    def __str__(self) -> str:
        return f'''Location [lon:{self.lon}, lat:{self.lat}], angle: {self.angle}'''
