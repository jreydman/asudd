import axios from "axios";

export default async function fetchObjectsByCrossroadId(crossroad_id: number) {
  const response = await axios.get(`/api/crossroad/${crossroad_id}/objects`);
  return response.data;
}
