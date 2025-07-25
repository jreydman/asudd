import { create } from "zustand";
import { immer } from "zustand/middleware/immer";

type MapStore = {
  mapViewState: {
    latitude: number;
    longitude: number;
    zoom: number;
  };
  setMapViewState: (newMapViewState: Partial<MapStore["mapViewState"]>) => void;
};

const useMapStore = create<MapStore>()(
  immer((set) => ({
    mapViewState: {
      latitude: 50.447914,
      longitude: 30.522192,
      zoom: 15,
    },

    setMapViewState: (newMapViewState) =>
      set((state) => {
        state.mapViewState = { ...state.mapViewState, ...newMapViewState };
      }),
  })),
);

export default useMapStore;
