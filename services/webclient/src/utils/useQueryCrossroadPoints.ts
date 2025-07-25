import { useQuery } from "@tanstack/react-query";
import fetchCrossroadPoints from "@utils/fetchCrossroadPoints";
import type { ObjectPoint } from "@src/types";

export default function useQueryCrossroadPoints() {
  return useQuery<ObjectPoint[]>({
    queryKey: ["crossroad_points"],
    queryFn: fetchCrossroadPoints,
  });
}
