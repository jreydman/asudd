import fetchCrossroadPoints from "./fetchCrossroadPoints";

export default async function getCrossroadPointsEndpoint() {
  try {
    const crossroad_points = await fetchCrossroadPoints();
    return Response.json(crossroad_points);
  } catch (err: unknown) {
    return Response.json({ error: err }, { status: 500 });
  }
}
