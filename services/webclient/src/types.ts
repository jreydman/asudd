import type { LineString, Point } from "geojson";

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

export type CROSSROAD_LOCATION = {
  id: number;
  name: string;
  geometry: Point;
  angle: number;
};

export type CROSSROAD = {
  id: number;
  name: string;
  picture: {
    blob_url: `blob:${string}`;
    axis_width: number;
    axis_height: number;
    scale: number;
    angle: number;
  };
};

export type OBJECT_CLASS_SIGNAL = {
  type: OBJECT_TYPE.Signal;
  geometry: Point & { angle: number };
};

export type OBJECT_CLASS_DIRECTION = {
  type: OBJECT_TYPE.Direction;
  geometry: LineString & { angle: number };
};

export type CROSSROAD_OBJECT = (
  | OBJECT_CLASS_SIGNAL
  | OBJECT_CLASS_DIRECTION
) & {
  id: number;
};
