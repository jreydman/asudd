import type { Position } from "geojson";

export default function drawCanvasVectorLineArrow(
  canvas_context: CanvasRenderingContext2D,
  imgWidth: number,
  imgHeight: number,
  axisWidth: number,
  axisHeight: number,
  vector: Position[],
  angle: number = 0, // Сделал угол опциональным, по умолчанию 0
  arrowSize: number = 20,
  lineWidth: number = 2,
) {
  const lineColor: string = "#0004FF";
  const arrowColor: string = "#0004FF";

  // Проверка наличия достаточного количества точек
  if (vector.length < 2) return;

  // Вычисление масштабных коэффициентов
  const scaleX = imgWidth / axisWidth;
  const scaleY = imgHeight / axisHeight;

  // Преобразование координат
  const scaledVector = vector.map(([x, y]) => [x * scaleX, y * scaleY]);

  // Сохранение состояния контекста
  canvas_context.save();

  // Отрисовка линии
  canvas_context.beginPath();
  canvas_context.moveTo(scaledVector[0][0], scaledVector[0][1]);

  for (let i = 1; i < scaledVector.length; i++) {
    canvas_context.lineTo(scaledVector[i][0], scaledVector[i][1]);
  }

  canvas_context.lineWidth = lineWidth;
  canvas_context.strokeStyle = lineColor;
  canvas_context.stroke();

  // Вычисление угла последнего сегмента вектора
  const lastSegmentAngle = Math.atan2(
    scaledVector[scaledVector.length - 1][1] -
      scaledVector[scaledVector.length - 2][1],
    scaledVector[scaledVector.length - 1][0] -
      scaledVector[scaledVector.length - 2][0],
  );

  // Отрисовка стрелки с учетом угла последнего сегмента и дополнительного поворота
  const endX = scaledVector[scaledVector.length - 1][0];
  const endY = scaledVector[scaledVector.length - 1][1];

  canvas_context.save();
  canvas_context.translate(endX, endY);
  canvas_context.rotate(lastSegmentAngle + angle); // Комбинируем углы

  // Рисуем стрелку
  canvas_context.beginPath();
  canvas_context.moveTo(0, 0);
  canvas_context.lineTo(-arrowSize, -arrowSize / 2);
  canvas_context.lineTo(-arrowSize, arrowSize / 2);
  canvas_context.closePath();

  canvas_context.fillStyle = arrowColor;
  canvas_context.fill();
  canvas_context.restore();

  // Восстановление состояния контекста
  canvas_context.restore();
}
