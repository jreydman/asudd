import drawCanvasGrid from "@src/utils/drawers/drawCanvasGrid";
import drawCanvasPointArrow from "@src/utils/drawers/drawCanvasPointArrow";
import { useEffect, useRef, useState } from "react";
import { OBJECT_TYPE, type CROSSROAD, type CROSSROAD_OBJECT } from "@src/types";
import drawCanvasVectorLineArrow from "@src/utils/drawers/drawCanvasVectorLineArrow";

type CrossroadMapEntryPictureProps = {
  crossroad: CROSSROAD;
  crossroadObjects: CROSSROAD_OBJECT[];
};

export default function CrossroadMapEntryPicture({
  crossroad,
  crossroadObjects,
}: CrossroadMapEntryPictureProps) {
  const canvasRef = useRef(null);
  const containerRef = useRef(null);
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 });

  useEffect(() => {
    if (!crossroad?.picture || !canvasRef.current) return;

    const canvas = canvasRef.current;
    const canvas_context = canvas.getContext("2d");
    const img = new Image();

    img.onload = function () {
      const originalWidth = img.width;
      const originalHeight = img.height;
      const axisWidth = crossroad.picture.axis_width || originalWidth;
      const axisHeight = crossroad.picture.axis_height || originalHeight;

      canvas.width = originalWidth;
      canvas.height = originalHeight;

      canvas_context.drawImage(img, 0, 0);

      drawCanvasGrid({
        canvas_context,
        imgWidth: originalWidth,
        imgHeight: originalHeight,
        axisWidth,
        axisHeight,
      });

      console.log(crossroadObjects);

      crossroadObjects.forEach((object) => {
        switch (object.type) {
          case OBJECT_TYPE.Signal: {
            drawCanvasPointArrow({
              canvas_context,
              imgWidth: originalWidth,
              imgHeight: originalHeight,
              axisWidth,
              axisHeight,
              point: object.geometry.coordinates,
              angle: object.geometry.angle,
            });
            break;
          }
          case OBJECT_TYPE.Direction: {
            drawCanvasVectorLineArrow({
              canvas_context,
              imgWidth: originalWidth,
              imgHeight: originalHeight,
              axisWidth,
              axisHeight,
              vector: object.geometry.coordinates,
              angle: object.geometry.angle,
              is_solid: !object.attributes.is_second_direction,
            });
            break;
          }
        }
      });

      setDimensions({ width: originalWidth, height: originalHeight });
    };

    img.src = crossroad.picture.blob_url;
  }, [crossroad, crossroadObjects]);

  return (
    <div
      ref={containerRef}
      style={{
        width: dimensions.width,
        height: dimensions.height,
        overflow: "hidden",
        position: "relative",
      }}
    >
      <canvas
        ref={canvasRef}
        style={{
          transformOrigin: "center",
          width: "100%",
          height: "100%",
        }}
      />
    </div>
  );
}
