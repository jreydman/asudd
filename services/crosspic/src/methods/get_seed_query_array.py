from classes.perinf__class import Perinf

# ------------------------------------------------------------------------------

def get_seed_query_array(perinf_array: [Perinf]) -> [str]:
    seed_query_array = []

    for perinf in perinf_array:
        pic_base64 = perinf.crosspic.buffer if isinstance(perinf.crosspic.buffer, str) else perinf.crosspic.buffer.decode("ascii")

        seed_query_array.append(f"""
            SELECT func__add_crossroad(
                '{perinf.name}'::TEXT,
                ST_SetSRID(ST_MakePoint(
                    {perinf.location.lat},
                    {perinf.location.lon}),
                    4326
                )::GEOMETRY,
                {perinf.location.angle}::DOUBLE PRECISION,
                '{pic_base64}'::TEXT,
                {perinf.crosspic.axis_width}::INTEGER,
                {perinf.crosspic.axis_height}::INTEGER,
                {perinf.crosspic.scale}::DOUBLE PRECISION,
                {perinf.crosspic.angle}::DOUBLE PRECISION
            );
        """)

    return seed_query_array

