import { create } from "zustand";
import { immer } from "zustand/middleware/immer";

const useAppStore = create()(
  immer((set, get) => ({
    /** -------------------------------------- */
  })),
);

export default useAppStore;
