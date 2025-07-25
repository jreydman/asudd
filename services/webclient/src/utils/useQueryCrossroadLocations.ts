import type { CROSSROAD_LOCATION } from "@src/types";
import { useQuery } from "@tanstack/react-query";
import fetchCrossroadLocations from "@src/utils/fetchCrossroadLocations";

export default function useQueryCrossroadLocations() {
  return useQuery<CROSSROAD_LOCATION[]>({
    queryKey: ["crossroad_locations"],
    queryFn: fetchCrossroadLocations,
  });
}
