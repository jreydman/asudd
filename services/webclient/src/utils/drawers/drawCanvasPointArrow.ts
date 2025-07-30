import type { Position } from "geojson";

type DrawCanvasPointArrowOptions = {
  canvas_context: CanvasRenderingContext2D;
  imgWidth: number;
  imgHeight: number;
  axisWidth: number;
  axisHeight: number;
  point: Position;
  angle: number;
  arrowSize?: number;
};

export default function drawCanvasPointArrow({
  canvas_context,
  imgWidth,
  imgHeight,
  axisWidth,
  axisHeight,
  point,
  angle,
  arrowSize = 20,
}: DrawCanvasPointArrowOptions) {
  const arrowColor = "#00FF00";

  const scaleX = imgWidth / axisWidth;
  const scaleY = imgHeight / axisHeight;

  const [axisX, axisY] = point;
  const x = axisX * scaleX;
  const y = axisY * scaleY;

  canvas_context.save();

  canvas_context.translate(x, y);
  canvas_context.rotate(angle);

  canvas_context.beginPath();
  canvas_context.moveTo(0, 0);
  canvas_context.lineTo(-arrowSize, -arrowSize / 2);
  canvas_context.lineTo(-arrowSize, arrowSize / 2);
  canvas_context.closePath();

  canvas_context.fillStyle = arrowColor;
  canvas_context.fill();

  canvas_context.restore();
}
