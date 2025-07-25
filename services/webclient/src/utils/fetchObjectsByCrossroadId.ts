import type { CROSSROAD_OBJECT } from "@src/types";
import axios from "axios";

export default async function fetchObjectsByCrossroadId(
  crossroad_id: number,
): Promise<CROSSROAD_OBJECT[]> {
  const response = await axios.get(`/api/crossroad/${crossroad_id}/object`);
  return response.data;
}
