import { serve } from "bun";
import getCrossroadByIdEndpoint from "src/endpoints/crossroads/[:id]/index";
import getCrossroadPointsEndpoint from "src/endpoints/crossroads/points/index";
import getObjectsByCrossroadIdEndpoint from "src/endpoints/crossroads/[:id]/objects/index";

const PORT = Number(process.env.APISERVER_PORT ?? 3001);

serve({
  hostname: "0.0.0.0",
  port: PORT,

  routes: {
    "/crossroad/:id": getCrossroadByIdEndpoint,
    "/crossroad/:id/objects": getObjectsByCrossroadIdEndpoint,
    "/crossroad/points": getCrossroadPointsEndpoint,
  },

  fetch() {
    return new Response("Not Found", { status: 404 });
  },
});

console.log(`Server run http://0.0.0.0:${PORT}`);
