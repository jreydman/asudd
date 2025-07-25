import fetchCrossroadGeoPoints from "src/utils/fetchCrossroadLocations";

export default async function getCrossroadLocationsEndpoint() {
  try {
    const crossroad_locations = await fetchCrossroadGeoPoints();
    return Response.json(crossroad_locations);
  } catch (err: unknown) {
    return Response.json({ error: err }, { status: 500 });
  }
}
