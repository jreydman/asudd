import type { Position } from "geojson";

export default function drawCanvasArrowPoint(
  canvas_context: CanvasRenderingContext2D,
  imgWidth: number,
  imgHeight: number,
  axisWidth: number,
  axisHeight: number,
  point: Position,
  angle: number,
  arrowSize: number = 20,
) {
  const arrowColor = "#00FF00"; // Green color for the arrow

  // Calculate scaling factors
  const scaleX = imgWidth / axisWidth;
  const scaleY = imgHeight / axisHeight;

  // Convert axis coordinates to canvas coordinates
  const [axisX, axisY] = point;
  const x = axisX * scaleX;
  const y = axisY * scaleY;

  // Save the current context state
  canvas_context.save();

  // Move to the point and rotate the context
  canvas_context.translate(x, y);
  canvas_context.rotate(angle);

  // Draw the arrow
  canvas_context.beginPath();
  canvas_context.moveTo(0, 0);
  canvas_context.lineTo(-arrowSize, -arrowSize / 2);
  canvas_context.lineTo(-arrowSize, arrowSize / 2);
  canvas_context.closePath();

  // Style the arrow
  canvas_context.fillStyle = arrowColor;
  canvas_context.fill();

  // Restore the context state
  canvas_context.restore();
}
