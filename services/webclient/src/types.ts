import type { Point } from "geojson";

export enum OBJECT_TYPE {
  Crossroad = "crossroad",
  Direction = "direction",
  Signal = "signal",
}

export enum OBJECT_GEOMETRY_GEOTYPE {
  Global = "global",
  Local = "local",
}

export enum OBJECT_SIGNAL_KIND {
  Traffic = "traffic",
  Pedestrian = "pedestrian",
}

export type ObjectPoint = {
  id: number;
  type: OBJECT_TYPE;
  geometry: Point;
  angle: number;
};

export type CrossroadObject = ObjectPoint & {
  name: string;
  picture_url: string;
  axis_width: number;
  axis_height: number;
  scale: number;
  angle: number;
};
