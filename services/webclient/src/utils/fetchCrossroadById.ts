import axios from "axios";

export default async function fetchCrossroadById(crossroad_id: number) {
  const response = await axios.get(`/api/crossroad/${crossroad_id}`);

  const crossroad = response.data;

  const byteArray = crossroad.buffer.data;
  const blob = new Blob([new Uint8Array(byteArray)], { type: "image/bmp" });
  const url = URL.createObjectURL(blob);

  delete crossroad.buffer;

  crossroad.picture_url = url;

  return response.data;
}
