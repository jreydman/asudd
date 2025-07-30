from methods.get_crosspic_array import get_crosspic_array
from methods.get_perinf_array import get_perinf_array
from methods.get_perinf_location_array import get_perinf_location_array
from methods.get_seed_query_array import get_seed_query_array
from methods.print_row import print_row

# ------------------------------------------------------------------------------

def seed():

    print_row("Load crossroad Pictures")

    crosspic_array = get_crosspic_array()

    print(f"Loaded {len(crosspic_array)} crossroad pictures")

    print_row("Load crossroad Perinf")

    perinf_array = get_perinf_array()

    print(f"Loaded {len(perinf_array)} crossroad perinfs")

    print_row("Load  crossroad Locations")

    perinf_location_array = get_perinf_location_array()

    print(f"Loaded {len(perinf_location_array)} crossroad perinf locations")

    # ------------------------------------------------------------------------------

    crosspic_dict = {pic.perinf_id: pic for pic in crosspic_array}
    location_dict = {loc.perinf_id: loc for loc in perinf_location_array}

    for perinf in perinf_array:
        perinf.crosspic = crosspic_dict.get(perinf.id, None)
        perinf.location = location_dict.get(perinf.id, None)

    perinf_array_filtered = list(filter(lambda perinf:
        perinf.location is not None
            and perinf.crosspic is not None, perinf_array))

    print(f"Filtered {len(perinf_array_filtered)} crossroad perinfs")

    # ------------------------------------------------------------------------------
    print_row("Load crossroad seed records")

    perinf_seed_query_array = get_seed_query_array(perinf_array_filtered)

    return perinf_seed_query_array

# ------------------------------------------------------------------------------
