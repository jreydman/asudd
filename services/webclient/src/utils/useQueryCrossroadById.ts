import type { CrossroadObject } from "@src/types";
import { useQuery } from "@tanstack/react-query";
import fetchCrossroadById from "@utils/fetchCrossroadById";

export default function useQueryCrossroadById(crossroad_id: number) {
  return useQuery<CrossroadObject>({
    queryKey: ["crossroad", crossroad_id],
    queryFn: () => fetchCrossroadById(crossroad_id),
  });
}
