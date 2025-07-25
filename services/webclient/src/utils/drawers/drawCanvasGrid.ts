export default function drawCanvasGrid(
  canvas_context: CanvasRenderingContext2D,
  imgWidth: number,
  imgHeight: number,
  axisWidth: number,
  axisHeight: number,
) {
  const gridColor = "#FF0000";
  const textColor = "#FFFF00";

  const axisStepX = axisWidth / 10;
  const axisStepY = axisHeight / 10;

  const scaleX = imgWidth / axisWidth;
  const scaleY = imgHeight / axisHeight;

  for (let axisX = 0; axisX <= axisWidth; axisX += axisStepX) {
    const x = axisX * scaleX;

    canvas_context.beginPath();
    canvas_context.moveTo(x, 0);
    canvas_context.lineTo(x, imgHeight);
    canvas_context.strokeStyle = gridColor;
    canvas_context.lineWidth = 1;
    canvas_context.stroke();

    canvas_context.fillStyle = textColor;
    canvas_context.font = "12px Arial";
    canvas_context.fillText(String(Math.round(axisX)), x + 5, 15);
  }

  for (let axisY = 0; axisY <= axisHeight; axisY += axisStepY) {
    const y = axisY * scaleY;

    canvas_context.beginPath();
    canvas_context.moveTo(0, y);
    canvas_context.lineTo(imgWidth, y);
    canvas_context.strokeStyle = gridColor;
    canvas_context.lineWidth = 1;
    canvas_context.stroke();

    canvas_context.fillStyle = textColor;
    canvas_context.fillText(String(Math.round(axisY)), 5, y + 15);
  }
}
