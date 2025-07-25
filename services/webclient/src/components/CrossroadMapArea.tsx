import useQueryCrossroadById from "@src/utils/useQueryCrossroadById";
import CrossroadPicture from "@src/components/CrossroadPicture";
import { useMap } from "react-map-gl/maplibre";
import { useEffect, useState } from "react";

type CrossroadMapAreaProps = {
  crossroad_id: number;
};

export default function CrossroadMapArea({
  crossroad_id,
}: CrossroadMapAreaProps) {
  const { data: crossroad } = useQueryCrossroadById(crossroad_id);
  const { current: map } = useMap();
  const [scale, setScale] = useState(1);

  useEffect(() => {
    if (!map || !crossroad) return;

    console.info(crossroad);

    const updateScale = () => {
      const currentZoom = map.getZoom();
      setScale(Math.pow(2, currentZoom - crossroad.scale));
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
      <CrossroadPicture crossroad={crossroad} />
    </div>
  );
}
