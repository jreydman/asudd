import type { Position } from "geojson";

function setLineDash(context: CanvasRenderingContext2D, pattern: number[]) {
  if ("setLineDash" in context) {
    context.setLineDash(pattern);
  } else if ("mozDash" in context) {
    (context as any).mozDash = pattern;
  } else if ("webkitLineDash" in context) {
    (context as any).webkitLineDash = pattern;
  }
}

type DrawCanvasVectorLineArrowOptions = {
  canvas_context: CanvasRenderingContext2D;
  imgWidth: number;
  imgHeight: number;
  axisWidth: number;
  axisHeight: number;
  vector: Position[];
  angle?: number;
  arrowSize?: number;
  lineWidth?: number;
  is_solid?: boolean;
};

export default function drawCanvasVectorLineArrow({
  canvas_context,
  imgWidth,
  imgHeight,
  axisWidth,
  axisHeight,
  vector,
  angle = 0,
  arrowSize = 20,
  lineWidth = 2,
  is_solid = true,
}: DrawCanvasVectorLineArrowOptions) {
  const lineColor = "#0004FF";
  const arrowColor = "#0004FF";

  if (vector.length < 2) return;

  const scaleX = imgWidth / axisWidth;
  const scaleY = imgHeight / axisHeight;
  const scaledVector = vector.map(([x, y]) => [x * scaleX, y * scaleY]);

  canvas_context.save();

  if (!is_solid) {
    setLineDash(canvas_context, [5, 3]);
  }

  canvas_context.beginPath();
  canvas_context.moveTo(scaledVector[0][0], scaledVector[0][1]);

  for (let i = 1; i < scaledVector.length; i++) {
    canvas_context.lineTo(scaledVector[i][0], scaledVector[i][1]);
  }

  canvas_context.lineWidth = lineWidth;
  canvas_context.strokeStyle = lineColor;
  canvas_context.stroke();

  if (!is_solid) {
    setLineDash(canvas_context, []);
  }

  const lastSegmentAngle = Math.atan2(
    scaledVector[scaledVector.length - 1][1] -
      scaledVector[scaledVector.length - 2][1],
    scaledVector[scaledVector.length - 1][0] -
      scaledVector[scaledVector.length - 2][0],
  );

  const endX = scaledVector[scaledVector.length - 1][0];
  const endY = scaledVector[scaledVector.length - 1][1];

  canvas_context.save();
  canvas_context.translate(endX, endY);
  canvas_context.rotate(lastSegmentAngle + angle);

  canvas_context.beginPath();
  canvas_context.moveTo(0, 0);
  canvas_context.lineTo(-arrowSize, -arrowSize / 2);
  canvas_context.lineTo(-arrowSize, arrowSize / 2);
  canvas_context.closePath();

  canvas_context.fillStyle = arrowColor;
  canvas_context.fill();
  canvas_context.restore();

  canvas_context.restore();
}
