import useMapStore from "@src/store/useMapStore";
import React from "react";
import {
  Map as MapLibre,
  type ViewStateChangeEvent,
  type MapLayerMouseEvent,
  GeolocateControl,
  Marker,
} from "react-map-gl/maplibre";
import CrossroadMapEntry from "@components/Crossroad/CrossroadMapEntry.component";
import useQueryCrossroadLocations from "@src/utils/useQueryCrossroadLocations";

const MAPSTYLE = "https://tiles.stadiamaps.com/styles/osm_bright.json";

export default function Map() {
  const mapViewState = useMapStore((state) => state.mapViewState);
  const setMapViewState = useMapStore((state) => state.setMapViewState);

  const { data: crossroadLocations } = useQueryCrossroadLocations();

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
        {crossroadLocations &&
          crossroadLocations.map((crossroadLocation) => {
            return (
              <Marker
                key={crossroadLocation.id}
                longitude={crossroadLocation.geometry.coordinates[0]}
                latitude={crossroadLocation.geometry.coordinates[1]}
                rotation={crossroadLocation.angle}
              >
                <CrossroadMapEntry crossroad_id={crossroadLocation.id} />
              </Marker>
            );
          })}
        {/** # Map controls */}
      </MapLibre>
    </section>
  );
}
