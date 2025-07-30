import { Feature, Point } from "geojson";

const t: Feature<Point> = {
  type: "Feature",
  geometry: {
    type: "Point",
    coordinates: [0, 0],
  },
  properties: {
    angle: 0,
  },
};

console.log(t);
