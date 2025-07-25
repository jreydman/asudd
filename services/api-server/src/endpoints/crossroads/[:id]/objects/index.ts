import getObjectsByCrossroadId from "src/endpoints/crossroads/[:id]/objects/fetchObjectsByCrossroadId";

export default async function getObjectsByCrossroadIdEndpoint(request: any) {
  const id = request.params.id;

  if (!id || isNaN(Number(id))) {
    return Response.json({ error: "Invalid ID" }, { status: 400 });
  }

  try {
    const objects = await getObjectsByCrossroadId(id);

    return Response.json(objects);
  } catch (err) {
    return Response.json({ error: err }, { status: 500 });
  }
}
