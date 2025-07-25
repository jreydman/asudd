import type { CROSSROAD } from "@src/types";
import axios from "axios";

export default async function fetchCrossroadById(
  crossroad_id: number,
): Promise<CROSSROAD> {
  const response = await axios.get(`/api/crossroad/${crossroad_id}`);

  const crossroad = response.data;

  const byteArray = crossroad.picture.buffer.data;
  const blob = new Blob([new Uint8Array(byteArray)], { type: "image/bmp" });
  const url = URL.createObjectURL(blob);

  delete crossroad.picture.buffer;

  crossroad.picture.blob_url = url;

  return response.data;
}
