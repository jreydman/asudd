import io
import json
from pathlib import Path
from PIL import Image, ImageDraw
from draw_arrow import draw_arrow_line

# ------------------------------------------------------------------------------

def bmp_mark():
    per_inf_path = Path('../../data/mdb_tables_test/Cup_u/Per_inf.json')
    per_obj_path = Path('../../data/mdb_tables_test/Cup_u/Per_Obj.json')
    per_pic_path = Path('../../data/mdb_tables_test/CupCip/pictures/pic_9_7920-6195.bmp')

    # --------------------------------------------------------------------------

    try:
        per_inf_file = open(per_inf_path, 'r')
        per_obj_file = open(per_obj_path, 'r')
        per_pic_file = open(per_pic_path, 'rb')

    except Exception as e:
        print(f'bmp_mark: {e}')

    # --------------------------------------------------------------------------

    per_inf_array = json.load(per_inf_file)
    per_obj_array = json.load(per_obj_file)
    per_pic_image = Image.open(io.BytesIO(per_pic_file.read()))

    directions = set()
    nomnap = 9
    direction_objs = list(filter(lambda obj: obj['NomNap'] == nomnap, per_obj_array))

    for obj in per_obj_array:
        directions.add(obj['NomNap'])


    print(f'bmp_mark: Directions: {directions}')
    print(f'bmp_mark: Direction Objects by {nomnap}(len={len(direction_objs)}): {direction_objs}')

    # --------------------------------------------------------------------------

    per_inf_obj = per_inf_array[0]

    per_inf_obj = {
        key: value for key, value in per_inf_obj.items()
            if key in ['NomPer', 'KoorX', 'KoorY']
    }

    # --------------------------------------------------------------------------

    __per_pic_filename = per_pic_path.name.split('.')[0]
    __per_pic_resolution = __per_pic_filename.split('_')[-1]
    __per_pic_pwidth, __per_pic_pheight = map(int,__per_pic_resolution.split('-'))

    per_pic_obj = {
        'NomPer': per_inf_obj['NomPer'],
        'PWidth': __per_pic_pwidth,
        'PHeight': __per_pic_pheight,
        'Width': per_pic_image.size[0],
        'Height': per_pic_image.size[1],
        'Pil': per_pic_image,
    }

    # --------------------------------------------------------------------------

    draw = ImageDraw.Draw(per_pic_obj['Pil'])

    grid_color = (255, 0, 0)
    text_color = (255, 255, 0)
    signal_point_color = (0, 255, 0)
    direction_line_color = (0, 0, 255)

    step_x = per_pic_obj['PWidth'] // 10
    step_y = per_pic_obj['PHeight'] // 10

    step_scale = per_pic_obj['Width'] / per_pic_obj['PWidth']

    point_radius = 5

    # --------------------------------------------------------------------------

    for x in range(0, per_pic_obj['PWidth'] + step_x, step_x):
        pixel_x = int(x * per_pic_obj['Width'] / per_pic_obj['PWidth'])
        draw.line([(pixel_x, 0), (pixel_x, per_pic_obj['Height'])], fill=grid_color, width=1)
        draw.text((pixel_x + 5, 5), str(x), fill=text_color)

    for y in range(0, per_pic_obj['PHeight'] + step_y, step_y):
        pixel_y = int(y * per_pic_obj['Height'] / per_pic_obj['PHeight'])
        draw.line([(0, pixel_y), (per_pic_obj['Width'], pixel_y)], fill=grid_color, width=1)
        draw.text((5, pixel_y + 5), str(y), fill=text_color)

    # --------------------------------------------------------------------------

    for obj in per_obj_array:
        match (obj.get('TypeObj'), obj.get('KindObj')):
            case (2,3) | (2,9):
                obj_left = int(obj['ObjLeft'] * step_scale)
                obj_top = int(obj['ObjTop'] * step_scale)
                match (obj.get('LineX1')):
                    case 1:
                        obj_x1 = obj_left-20
                        obj_y1 = obj_top
                    case 2:
                        obj_x1 = obj_left
                        obj_y1 = obj_top-20
                    case 3:
                        obj_x1 = obj_left+20
                        obj_y1 = obj_top
                    case 4:
                        obj_x1 = obj_left
                        obj_y1 =obj_top+20
                draw.ellipse([
                    (obj_left - point_radius, obj_top - point_radius),
                    (obj_left + point_radius, obj_top + point_radius),
                ], fill=signal_point_color)
                draw_arrow_line(draw,
                    (obj_left, obj_top),
                    (obj_x1, obj_y1),
                    fill_color=signal_point_color)

            case (4,2) | (4,3):
                obj_left = int(obj['ObjLeft'] * step_scale)
                obj_top = int(obj['ObjTop'] * step_scale)
                obj_x1 = int(obj['LineX1'] * step_scale)
                obj_y1 = int(obj['LineY1'] * step_scale)
                obj_x2 = int(obj['LineX2'] * step_scale)
                obj_y2 = int(obj['LineY2'] * step_scale)
                draw.text((obj_x1, obj_y1), str(obj['NomNap']), fill=text_color)
                draw_arrow_line(draw,
                    (obj_x1, obj_y1),
                    (obj_x2, obj_y2),
                    fill_color=direction_line_color)


    # --------------------------------------------------------------------------

    per_pic_save_path = Path(per_pic_path.parent, __per_pic_filename + '_enchanced.bmp')
    per_pic_save_path.unlink() if per_pic_save_path.exists()else None
    per_pic_obj['Pil'].save(per_pic_save_path)

    # ------------------------------------------------------------------------------
