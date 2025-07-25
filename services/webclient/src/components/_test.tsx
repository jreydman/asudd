import useQueryCrossroadById from "@src/utils/useQueryCrossroadById";
import { useEffect } from "react";

type PictureProps = {
  crossroad_id: number;
};

export default function Picture({ crossroad_id }: PictureProps) {
  const { data: crossroad } = useQueryCrossroadById(crossroad_id);

  useEffect(() => console.info(crossroad), [crossroad]);

  return (
    <div>{crossroad && <img src={crossroad.picture_url} alt="Picture" />}</div>
  );
}
