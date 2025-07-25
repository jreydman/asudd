import fetchCrossroadPoints from "@src/utils/fetchCrossroadPoints";
import Map from "./Map";

export default function Main() {
  fetchCrossroadPoints();

  return (
    <main>
      {/** ---------------------------- */}
      <Map />
      {/** ---------------------------- */}
    </main>
  );
}
