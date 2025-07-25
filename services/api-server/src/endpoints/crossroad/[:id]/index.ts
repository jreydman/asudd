import fetchCrossroadById from "src/utils/fetchCrossroadById";

export default async function getCrossroadByIdEndpoint(request: any) {
  const id = request.params.id;

  if (!id || isNaN(Number(id))) {
    return Response.json({ error: "Invalid ID" }, { status: 400 });
  }

  try {
    const crossroad = await fetchCrossroadById(id);

    if (!crossroad)
      return Response.json({ error: "Crossroad not found" }, { status: 404 });

    return Response.json(crossroad);
  } catch (err) {
    return Response.json({ error: err }, { status: 500 });
  }
}
