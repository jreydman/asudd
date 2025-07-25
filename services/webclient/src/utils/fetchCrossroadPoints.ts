import axios from "axios";

export default async function fetchCrossroadPoints() {
  const response = await axios.get(`/api/crossroad/points`);
  return response.data;
}
