from classes.perinf_location__class import PerinfLocation

def get_perinf_location_array() -> [PerinfLocation]:
    perinf_location__array = []

    # бульв. Т.Шевченка - вул. Володимирська
    perinf_location__array.append(PerinfLocation(
        perinf_id=9,
        lon=50.443600,
        lat=30.512462,
        angle=13.5)
    )

    # бульв. Т.Шевченка - вул. Леонтовича
    perinf_location__array.append(PerinfLocation(
        perinf_id=10,
        lon=50.444116,
        lat=30.509292,
        angle=13.5)
    )

    # бульв. Т.Шевченка - вул. С.Петлюри
    perinf_location__array.append(PerinfLocation(
        perinf_id=11,
        lon=50.445460,
        lat=30.500937,
        angle=13.5
    ))

    # бульв. Т.Шевченка - вул. Старовокзальна
    perinf_location__array.append(PerinfLocation(
        perinf_id=12,
        lon=50.446550,
        lat=30.494248,
        angle=13.5
    ))



    return perinf_location__array
