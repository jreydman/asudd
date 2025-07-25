import type { CROSSROAD_LOCATION } from "@src/types";
import axios from "axios";

export default async function fetchCrossroadLocations(): Promise<
  CROSSROAD_LOCATION[]
> {
  const response = await axios.get(`/api/crossroad/location`);
  return response.data;
}
