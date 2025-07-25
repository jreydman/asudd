import getCrossroadLocationsEndpoint from "@srcendpoints/crossroad/location/index";
import getCrossroadByIdEndpoint from "src/endpoints/crossroad/[:id]/index";
import getObjectsByCrossroadIdEndpoint from "src/endpoints/crossroad/[:id]/object/index";
import { serve } from "bun";

const PORT = Number(process.env.APISERVER_PORT ?? 3001);

serve({
  hostname: "0.0.0.0",
  port: PORT,

  routes: {
    "/crossroad/:id": getCrossroadByIdEndpoint,
    "/crossroad/:id/object": getObjectsByCrossroadIdEndpoint,
    "/crossroad/location": getCrossroadLocationsEndpoint,
  },

  fetch() {
    return new Response("Not Found", { status: 404 });
  },
});

console.log(`Server run http://0.0.0.0:${PORT}`);
