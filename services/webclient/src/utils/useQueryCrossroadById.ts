import type { CROSSROAD } from "@src/types";
import { useQuery } from "@tanstack/react-query";
import fetchCrossroadById from "@utils/fetchCrossroadById";

export default function useQueryCrossroadById(crossroad_id: number) {
  return useQuery<CROSSROAD>({
    queryKey: ["crossroad", crossroad_id],
    queryFn: () => fetchCrossroadById(crossroad_id),
  });
}
