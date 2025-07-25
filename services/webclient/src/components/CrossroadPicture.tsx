import drawCanvasGrid from "@src/utils/drawers/drawCanvasGrid";
import drawCanvasArrowPoint from "@src/utils/drawers/drawCanvasArrowPoint";
import useQueryObjectsByCrossroadId from "@src/utils/useQueryObjectsByCrossroadId";
import { useEffect, useRef, useState } from "react";

export default function CrossroadPicture({ crossroad }) {
  const { data: objects = [] } = useQueryObjectsByCrossroadId(crossroad.id);

  const canvasRef = useRef(null);
  const containerRef = useRef(null);
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 });

  useEffect(() => {
    if (!crossroad?.picture_url || !canvasRef.current) return;

    const canvas = canvasRef.current;
    const canvas_context = canvas.getContext("2d");
    const img = new Image();

    img.onload = function () {
      const originalWidth = img.width;
      const originalHeight = img.height;
      const axisWidth = crossroad.axis_width || originalWidth;
      const axisHeight = crossroad.axis_height || originalHeight;

      canvas.width = originalWidth;
      canvas.height = originalHeight;

      canvas_context.drawImage(img, 0, 0);

      drawCanvasGrid(
        canvas_context,
        originalWidth,
        originalHeight,
        axisWidth,
        axisHeight,
      );

      objects.forEach((object) => {
        if (!object.geotype || object.geotype !== "local") return;

        console.log(object);

        drawCanvasArrowPoint(
          canvas_context,
          originalWidth,
          originalHeight,
          axisWidth,
          axisHeight,
          object.geometry.coordinates,
          object.angle,
        );
      });

      setDimensions({ width: originalWidth, height: originalHeight });
    };

    img.src = crossroad.picture_url;
  }, [crossroad, objects]);

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
