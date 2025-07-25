import type { ObjectPoint } from "@src/types";
import { useQuery } from "@tanstack/react-query";
import fetchObjectsByCrossroadId from "@utils/fetchObjectsByCrossroadId";

export default function useQueryObjectsByCrossroadId(crossroad_id: number) {
  return useQuery<ObjectPoint[]>({
    queryKey: ["crossroad_objects", crossroad_id],
    queryFn: () => fetchObjectsByCrossroadId(crossroad_id),
  });
}
