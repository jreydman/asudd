from methods.gen_database_seed import seed
from methods.print_row import print_row
from methods.run_query import run_query

# ------------------------------------------------------------------------------

def main():
    perinf_seed_query_array = seed()


    for perinf_seed_query in perinf_seed_query_array:
        run_query(perinf_seed_query)

    print_row()

# ------------------------------------------------------------------------------

if __name__ == "__main__":
    main()

# ------------------------------------------------------------------------------

