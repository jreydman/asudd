import json
from pathlib import Path
from classes.perinf__class import Perinf

# ------------------------------------------------------------------------------

def get_perinf_array() -> [Perinf]:
    perinf_file = Path("../../data/mdb_tables/Cup_u/Per_inf.json")
    perinf_array = []


    for object in json.load(perinf_file.open('rb')):
        perinf = Perinf(id=int(object['NomPer']), name=object['NameDK'])
        perinf_array.append(perinf)


    return perinf_array
