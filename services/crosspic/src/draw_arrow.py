from PIL import Image, ImageDraw
import math

def draw_arrow_line(draw, start_point, end_point, fill_color, line_width=1, arrow_head_size=10):
    """
    Draws an arrowed line on a Pillow ImageDraw object.

    Args:
        draw (ImageDraw.Draw): The ImageDraw object to draw on.
        start_point (tuple): (x, y) coordinates of the line's starting point.
        end_point (tuple): (x, y) coordinates of the line's ending point.
        fill_color (str or tuple): Color for the line and arrowhead (e.g., "black", (255, 0, 0)).
        line_width (int): Width of the line.
        arrow_head_size (int): Size of the arrowhead (length of the arrowhead sides).
    """
    # Draw the main line
    draw.line([start_point, end_point], fill=fill_color, width=line_width)

    # Calculate the angle of the line
    dx = end_point[0] - start_point[0]
    dy = end_point[1] - start_point[1]
    angle = math.atan2(dy, dx)

    # Calculate the points for the arrowhead triangle
    arrow_angle_left = angle + math.radians(150)  # Adjust angle for arrowhead wings
    arrow_angle_right = angle - math.radians(150)

    arrow_point1 = (
        end_point[0] + arrow_head_size * math.cos(arrow_angle_left),
        end_point[1] + arrow_head_size * math.sin(arrow_angle_left)
    )
    arrow_point2 = (
        end_point[0] + arrow_head_size * math.cos(arrow_angle_right),
        end_point[1] + arrow_head_size * math.sin(arrow_angle_right)
    )

    # Draw the arrowhead as a filled polygon
    draw.polygon([end_point, arrow_point1, arrow_point2], fill=fill_color)

# Example usage:
if __name__ == "__main__":
    # Create a new image
    img = Image.new("RGB", (400, 300), color="white")
    draw = ImageDraw.Draw(img)

    # Draw an arrow
    start = (50, 250)
    end = (350, 50)
    draw_arrow(draw, start, end, fill_color="blue", line_width=3, arrow_head_size=15)

    # Show the image
    img.show()
