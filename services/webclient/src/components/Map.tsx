import useMapStore from "@src/store/useMapStore";
import useQueryCrossroadPoints from "@src/utils/useQueryCrossroadPoints";
import React from "react";
import {
  Map as MapLibre,
  type ViewStateChangeEvent,
  type MapLayerMouseEvent,
  GeolocateControl,
  Marker,
} from "react-map-gl/maplibre";
import CrossroadMapArea from "./CrossroadMapArea";

const MAPSTYLE = "https://tiles.stadiamaps.com/styles/osm_bright.json";

export default function Map() {
  const mapViewState = useMapStore((state) => state.mapViewState);
  const setMapViewState = useMapStore((state) => state.setMapViewState);

  const { data: crossroadPoints } = useQueryCrossroadPoints();

  // Map controls ----------------------------------------------------------------

  const onMapMove = React.useCallback((_event: ViewStateChangeEvent) => {
    const { viewState } = _event;
    setMapViewState(viewState);
  }, []);

  const onMapCLick = React.useCallback((_event: MapLayerMouseEvent) => {
    console.info(_event);
  }, []);

  // -----------------------------------------------------------------------------

  return (
    <section className="h-screen">
      <MapLibre
        {...mapViewState}
        onMove={onMapMove}
        onClick={onMapCLick}
        mapStyle={MAPSTYLE}
      >
        {/** Map controls */}
        <GeolocateControl />
        {crossroadPoints &&
          crossroadPoints.map((crossroadPoint) => {
            return (
              <Marker
                key={crossroadPoint.id}
                longitude={crossroadPoint.geometry.coordinates[0]}
                latitude={crossroadPoint.geometry.coordinates[1]}
                color="blue"
                anchor="center"
                rotation={15}
              >
                <CrossroadMapArea crossroad_id={crossroadPoint.id} />
              </Marker>
            );
          })}
        {/** # Map controls */}
      </MapLibre>
    </section>
  );
}
