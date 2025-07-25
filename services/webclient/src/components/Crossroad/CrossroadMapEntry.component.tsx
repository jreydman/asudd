import useQueryCrossroadById from "@src/utils/useQueryCrossroadById";
import CrossroadMapEntryPicture from "@src/components/Crossroad/CrossroadMapEntryPicture.component";
import { useMap } from "react-map-gl/maplibre";
import { useEffect, useState } from "react";
import useQueryObjectsByCrossroadId from "@src/utils/useQueryObjectsByCrossroadId";

type CrossroadMapAreaProps = {
  crossroad_id: number;
};

export default function CrossroadMapEntry({
  crossroad_id,
}: CrossroadMapAreaProps) {
  const { data: crossroad } = useQueryCrossroadById(crossroad_id);
  const { data: crossroadObjects } = useQueryObjectsByCrossroadId(crossroad_id);
  const { current: map } = useMap();
  const [scale, setScale] = useState(1);

  useEffect(() => {
    if (!map || !crossroad) return;

    const updateScale = () => {
      const currentZoom = map.getZoom();
      setScale(Math.pow(2, currentZoom - crossroad.picture.scale));
    };

    map.on("zoom", updateScale);
    updateScale();

    return () => {
      map.off("zoom", updateScale);
    };
  }, [map, crossroad]);

  if (!crossroad) return null;

  return (
    <div
      style={{
        transform: `scale(${scale})`,
        transformOrigin: "center",
        display: "inline-block",
      }}
    >
      <CrossroadMapEntryPicture
        crossroad={crossroad}
        crossroadObjects={crossroadObjects}
      />
    </div>
  );
}
