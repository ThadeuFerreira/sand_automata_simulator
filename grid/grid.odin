package grid

import rl "vendor:raylib"
import "core:math/rand"
import "core:math"


SAND_COLOR_LIST :: []rl.Color{
    rl.RED,
    rl.ORANGE,
    rl.YELLOW,
    rl.MAGENTA,
    rl.GOLD,
    rl.MAROON,
}

// Grid
Grid :: struct {
    width, height: int,
    offset_pos: rl.Vector2,
    blockSize: f32,
    current_cells: []Cell,
    previous_cells: []Cell,

    backgroundColor: rl.Color,
    fall_speed: f32,
}

CELL_TYPE :: enum {
    EMPTY,
    SAND,
    WATER,
}

Cell :: struct {
    cell_type: CELL_TYPE,
    color: rl.Color,
    updated: bool,
}

globalTimeCounter : f32 = 0.0

Make_Grid :: proc(width : int, height : int, offset_pos: rl.Vector2,blockSize: f32,  backgroundColor: rl.Color) -> Grid {
    g := Grid{
        width = width,
        height = height,
        blockSize = blockSize,
        offset_pos = offset_pos,
        backgroundColor = backgroundColor,
    }

    current_cells := make([]Cell, width*height)
    previous_cells := make([]Cell, width*height)
    // for i in 0..< width {
    //     current_cells[i] = make([]Cell, height)
    //     previous_cells[i] = make([]Cell, height)
    // }
    g.fall_speed = fall_speed

    g.current_cells = current_cells
    g.previous_cells = previous_cells
    return g
}

fall_time : f32 = 0.0
fall_speed : f32 = 10000

// Update the grid
Update :: proc(g : ^Grid) {

    get_input(g)
    fall_time += rl.GetFrameTime()
    //if fall_time >= 1/g.fall_speed {
        drop_particle(g)
        fall_time = 0
    //}

}

color_change_time : f32 = 0.0
color_change_interval : f32 = 5
new_sand_color : rl.Color = rl.GOLD
get_input :: proc(g : ^Grid) {
    mouse_pos := rl.GetMousePosition()
    color_change_time += rl.GetFrameTime()
    if color_change_time >= color_change_interval {
        sand_color_list := SAND_COLOR_LIST
        new_sand_color = sand_color_list[rand.int_max(len(SAND_COLOR_LIST))]
        color_change_time = 0
    }
    if rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
        x := int((mouse_pos.x - g.offset_pos.x) / g.blockSize)
        y := int((mouse_pos.y - g.offset_pos.y) / g.blockSize)
        if x >= 0 && x < g.width && y >= 0 && y < g.height {
            new_cell := Cell{
                cell_type = CELL_TYPE.SAND,
                color = new_sand_color,
            }
            g.previous_cells[x + y*g.width] = new_cell
        }
    }
    if rl.IsMouseButtonDown(rl.MouseButton.RIGHT) {
        x := int((mouse_pos.x - g.offset_pos.x) / g.blockSize)
        y := int((mouse_pos.y - g.offset_pos.y) / g.blockSize)
        if x >= 0 && x < g.width && y >= 0 && y < g.height {
            new_cell := Cell{
                cell_type = CELL_TYPE.WATER,
                color = rl.BLUE,
            }
            g.previous_cells[x + y*g.width] = new_cell
        }
    }
}

drop_water :: proc(g: ^Grid, cell : Cell, i,j :int){
    h := g.height
    w := g.width
    if j + 1 < h{
        if g.previous_cells[i + (j+1)*w].cell_type == CELL_TYPE.EMPTY {
            g.current_cells[i + j*w] = Cell{
                cell_type = CELL_TYPE.EMPTY,
                color = rl.BLACK,
            }
            g.current_cells[i + (j+1)*w] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        }
        else if g.previous_cells[(i -1) + (j+1)*w].cell_type == CELL_TYPE.EMPTY && g.previous_cells[(i +1) + (j+1)*w].cell_type == CELL_TYPE.EMPTY{
               if rand.float32() < 0.5 && g.current_cells[(i-1) + j*w].cell_type == CELL_TYPE.EMPTY {
                   g.current_cells[i + j*w] = Cell{
                       cell_type = CELL_TYPE.EMPTY,
                       color = rl.BLACK,
                   }
                   g.current_cells[(i-1) +( j+1)*w] = Cell{
                       cell_type = cell.cell_type,
                       color = cell.color,
                   }
               } else if g.current_cells[(i+1) + j*w].cell_type == CELL_TYPE.EMPTY {
                   g.current_cells[i + j*w] = Cell{
                       cell_type = CELL_TYPE.EMPTY,
                       color = rl.BLACK,
                   }
                   g.current_cells[(i+1) + (j+1)*w] = Cell{
                       cell_type = cell.cell_type,
                       color = cell.color,
                   }
               }
               else {
                   g.current_cells[i + j*w] = Cell{
                       cell_type = cell.cell_type,
                       color = cell.color,
                   }
               }
        }
        else if g.previous_cells[(i-1) + j*w].cell_type == CELL_TYPE.EMPTY && g.previous_cells[(i+1) + j*w].cell_type == CELL_TYPE.EMPTY {
            if rand.float32() < 0.5 && g.current_cells[(i-1) + j*w].cell_type == CELL_TYPE.EMPTY {
                g.current_cells[i + j*w] = Cell{
                    cell_type = CELL_TYPE.EMPTY,
                    color = rl.BLACK,
                }
                g.current_cells[(i-1) + j*w] = Cell{
                    cell_type = cell.cell_type,
                    color = cell.color,
                }
            } else if g.current_cells[(i+1) + j*w].cell_type == CELL_TYPE.EMPTY  {
                g.current_cells[i + j*w] = Cell{
                    cell_type = CELL_TYPE.EMPTY,
                    color = rl.BLACK,
                }
                g.current_cells[(i+1) + j*w] = Cell{
                    cell_type = cell.cell_type,
                    color = cell.color,
                }
            } else {
                g.current_cells[i + j*w] = Cell{
                    cell_type = cell.cell_type,
                    color = cell.color,
                }
            }
        }
        else if g.previous_cells[(i-1) + j*w].cell_type == CELL_TYPE.EMPTY && g.current_cells[(i-1) + j*w].cell_type == CELL_TYPE.EMPTY {
            g.current_cells[i + j*w] = Cell{
                cell_type = CELL_TYPE.EMPTY,
                color = rl.BLACK,
            }
            g.current_cells[(i-1) + j*w] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        }
        else if g.previous_cells[(i+1) + j*w].cell_type == CELL_TYPE.EMPTY {
            g.current_cells[i + j*w] = Cell{
                cell_type = CELL_TYPE.EMPTY,
                color = rl.BLACK,
            }
            g.current_cells[(i+1) + j*w] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        }
        else {
            g.current_cells[i + j*w] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        } 
    } else {
       g.current_cells[i + j*w] = Cell{
           cell_type = cell.cell_type,
           color = cell.color,
       }
   }
}

sand_stickness : f32 = 0.5
drop_sand :: proc(g: ^Grid, cell : Cell, i,j :int){
    h := g.height
    w := g.width
    if j + 1 < h {
        if g.previous_cells[i + (j+1)*w].cell_type == CELL_TYPE.EMPTY ||  g.previous_cells[i + j*w+1].cell_type == CELL_TYPE.WATER{
            g.current_cells[i + j*w] = Cell{
                cell_type = CELL_TYPE.EMPTY,
                color = rl.BLACK,
            }
            g.current_cells[i + (j+1)*w] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        }
        else if g.previous_cells[i + (j+1)*w].cell_type == CELL_TYPE.SAND{
            if g.previous_cells[(i-1) +(j+1)*w].cell_type != CELL_TYPE.SAND && g.previous_cells[(i+1) + (j+1)*w].cell_type != CELL_TYPE.SAND {
                if rand.float32() > sand_stickness {
                    g.current_cells[i + j*w] = Cell{
                        cell_type = CELL_TYPE.EMPTY,
                        color = rl.BLACK,
                    }
                    if rand.float32() < 0.5 {
                        g.current_cells[(i-1) +(j+1)*w] = Cell{
                            cell_type = cell.cell_type,
                            color = cell.color,
                        }
                    } else {
                        g.current_cells[(i+1) + (j+1)*w] = Cell{
                            cell_type = cell.cell_type,
                            color = cell.color,
                        }
                    }
                }
                else {
                    g.current_cells[i + j*w] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
            }
            else if g.previous_cells[(i-1) +(j+1)*w].cell_type != CELL_TYPE.SAND {
                if rand.float32() > sand_stickness {
                    g.current_cells[i + j*w] = Cell{
                        cell_type = CELL_TYPE.EMPTY,
                        color = rl.BLACK,
                    }
                    g.current_cells[(i-1) +(j+1)*w] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
                else {
                    g.current_cells[i + j*w] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
            }
            else if g.previous_cells[(i+1) + (j+1)*w].cell_type != CELL_TYPE.SAND {
                if rand.float32() < sand_stickness {
                    g.current_cells[i + j*w] = Cell{
                        cell_type = CELL_TYPE.EMPTY,
                        color = rl.BLACK,
                    }
                    g.current_cells[(i+1) + (j+1)*w] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
                else {
                    g.current_cells[i + j*w] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
            }
            else{
                g.current_cells[i + j*w] = Cell{
                    cell_type = cell.cell_type,
                    color = cell.color,
                }
            }
        } 
    } else {
        g.current_cells[i + j*w] = Cell{
            cell_type = cell.cell_type,
            color = cell.color,
        }
    }
}

copy_particles :: proc(g : ^Grid) {
    for i in 0..< g.width {
        for j in 0..< g.height {
            g.previous_cells[i + j*g.width] = g.current_cells[i + j*g.width]
        }
    }
    //clear current cells
    for i in 0..< g.width {
        for j in 0..< g.height {
            g.current_cells[i + j*g.width] = Cell{
                cell_type = CELL_TYPE.EMPTY,
                color = rl.BLACK,
            }
        }
    }
}


drop_particle :: proc(g : ^Grid) {
    h := g.height
    w := g.width
    for i in 1..< w -1 {
        for j in 0..< h  {
            cell := g.previous_cells[i + j*w]
            if cell.cell_type == CELL_TYPE.WATER {
                drop_water(g, cell, i, j)
            }
            else if cell.cell_type == CELL_TYPE.SAND {
                drop_sand(g, cell, i, j)
            }
        }
    }
    
    copy_particles(g)

}

// Draw the grid
Draw :: proc(g : ^Grid) {
    rl.DrawRectangle(i32(g.offset_pos.x), i32(g.offset_pos.y), i32(f32(g.width)*g.blockSize), i32(f32(g.height)*g.blockSize), rl.WHITE)
    h := g.height
    w := g.width
    for i in 0..< w {
        for j in 0..< h {
            cell := g.previous_cells[i + j*w]
            x := f32(i) * g.blockSize + g.offset_pos.x
            y := f32(j) * g.blockSize + g.offset_pos.y
            width := g.blockSize - 1
            height := g.blockSize - 1
            color := rl.BLACK
            if cell.cell_type != CELL_TYPE.EMPTY {
                color = cell.color
            }
            rl.DrawRectangle(i32(f32(i) * g.blockSize + g.offset_pos.x), i32(f32(j) * g.blockSize + g.offset_pos.y), i32(g.blockSize), i32(g.blockSize), color)
        }
    }
}
