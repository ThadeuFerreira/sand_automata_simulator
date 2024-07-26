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
    cells: [][]Cell,

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

    cells := make([][]Cell, width)
    for i in 0..< width {
        cells[i] = make([]Cell, height)
    }
    g.fall_speed = fall_speed

    g.cells = cells
    return g
}

fall_time : f32 = 0.0
fall_speed : f32 = 1000

// Update the grid
Update :: proc(g : ^Grid) {

    get_input(g)
    fall_time += rl.GetFrameTime()
    if fall_time >= 1/g.fall_speed {
        drop_particle(g)
        fall_time = 0
    }

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
            g.cells[x][y] = new_cell
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
            g.cells[x][y] = new_cell
        }
    }
}

drop_water :: proc(g: ^Grid, new_cells : [][]Cell, cell : Cell, i,j :int){
    if j + 1 < g.height {
        if g.cells[i][j+1].cell_type == CELL_TYPE.EMPTY {
            new_cells[i][j] = Cell{
                cell_type = CELL_TYPE.EMPTY,
                color = rl.BLACK,
            }
            new_cells[i][j+1] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        }
        else if g.cells[i-1][j+1].cell_type == CELL_TYPE.EMPTY && g.cells[i+1][j+1].cell_type == CELL_TYPE.EMPTY{
               if rand.float32() < 0.5 && new_cells[i-1][j].cell_type == CELL_TYPE.EMPTY {
                   new_cells[i][j] = Cell{
                       cell_type = CELL_TYPE.EMPTY,
                       color = rl.BLACK,
                   }
                   new_cells[i-1][j+1] = Cell{
                       cell_type = cell.cell_type,
                       color = cell.color,
                   }
               } else if new_cells[i+1][j].cell_type == CELL_TYPE.EMPTY {
                   new_cells[i][j] = Cell{
                       cell_type = CELL_TYPE.EMPTY,
                       color = rl.BLACK,
                   }
                   new_cells[i+1][j+1] = Cell{
                       cell_type = cell.cell_type,
                       color = cell.color,
                   }
               }
               else {
                   new_cells[i][j] = Cell{
                       cell_type = cell.cell_type,
                       color = cell.color,
                   }
               }
        }
        else if g.cells[i-1][j].cell_type == CELL_TYPE.EMPTY && g.cells[i+1][j].cell_type == CELL_TYPE.EMPTY {
            if rand.float32() < 0.5 && new_cells[i-1][j].cell_type == CELL_TYPE.EMPTY {
                new_cells[i][j] = Cell{
                    cell_type = CELL_TYPE.EMPTY,
                    color = rl.BLACK,
                }
                new_cells[i-1][j] = Cell{
                    cell_type = cell.cell_type,
                    color = cell.color,
                }
            } else if new_cells[i+1][j].cell_type == CELL_TYPE.EMPTY  {
                new_cells[i][j] = Cell{
                    cell_type = CELL_TYPE.EMPTY,
                    color = rl.BLACK,
                }
                new_cells[i+1][j] = Cell{
                    cell_type = cell.cell_type,
                    color = cell.color,
                }
            } else {
                new_cells[i][j] = Cell{
                    cell_type = cell.cell_type,
                    color = cell.color,
                }
            }
        }
        else if g.cells[i-1][j].cell_type == CELL_TYPE.EMPTY && new_cells[i-1][j].cell_type == CELL_TYPE.EMPTY {
            new_cells[i][j] = Cell{
                cell_type = CELL_TYPE.EMPTY,
                color = rl.BLACK,
            }
            new_cells[i-1][j] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        }
        else if g.cells[i+1][j].cell_type == CELL_TYPE.EMPTY {
            new_cells[i][j] = Cell{
                cell_type = CELL_TYPE.EMPTY,
                color = rl.BLACK,
            }
            new_cells[i+1][j] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        }
        else {
            new_cells[i][j] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        } 
    } else {
       new_cells[i][j] = Cell{
           cell_type = cell.cell_type,
           color = cell.color,
       }
   }
}

sand_stickness : f32 = 0.5
drop_sand :: proc(g: ^Grid, new_cells : [][]Cell, cell : Cell, i,j :int){
    if j + 1 < g.height {
        if g.cells[i][j+1].cell_type == CELL_TYPE.EMPTY ||  g.cells[i][j+1].cell_type == CELL_TYPE.WATER{
            new_cells[i][j] = Cell{
                cell_type = CELL_TYPE.EMPTY,
                color = rl.BLACK,
            }
            new_cells[i][j+1] = Cell{
                cell_type = cell.cell_type,
                color = cell.color,
            }
        }
        else if g.cells[i][j+1].cell_type == CELL_TYPE.SAND{
            if g.cells[i-1][j+1].cell_type != CELL_TYPE.SAND && g.cells[i+1][j+1].cell_type != CELL_TYPE.SAND {
                if rand.float32() > sand_stickness {
                    new_cells[i][j] = Cell{
                        cell_type = CELL_TYPE.EMPTY,
                        color = rl.BLACK,
                    }
                    if rand.float32() < 0.5 {
                        new_cells[i-1][j+1] = Cell{
                            cell_type = cell.cell_type,
                            color = cell.color,
                        }
                    } else {
                        new_cells[i+1][j+1] = Cell{
                            cell_type = cell.cell_type,
                            color = cell.color,
                        }
                    }
                }
                else {
                    new_cells[i][j] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
            }
            else if g.cells[i-1][j+1].cell_type != CELL_TYPE.SAND {
                if rand.float32() > sand_stickness {
                    new_cells[i][j] = Cell{
                        cell_type = CELL_TYPE.EMPTY,
                        color = rl.BLACK,
                    }
                    new_cells[i-1][j+1] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
                else {
                    new_cells[i][j] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
            }
            else if g.cells[i+1][j+1].cell_type != CELL_TYPE.SAND {
                if rand.float32() < sand_stickness {
                    new_cells[i][j] = Cell{
                        cell_type = CELL_TYPE.EMPTY,
                        color = rl.BLACK,
                    }
                    new_cells[i+1][j+1] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
                else {
                    new_cells[i][j] = Cell{
                        cell_type = cell.cell_type,
                        color = cell.color,
                    }
                }
            }
            else{
                new_cells[i][j] = Cell{
                    cell_type = cell.cell_type,
                    color = cell.color,
                }
            }
        } 
    } else {
        new_cells[i][j] = Cell{
            cell_type = cell.cell_type,
            color = cell.color,
        }
    }
}


drop_particle :: proc(g : ^Grid) {
    new_cells := make([][]Cell, g.width)
    for i in 0..< g.width {
        new_cells[i] = make([]Cell, g.height)
    }

    
    water_flow := rand.float32() 
    for i in 1..< g.width -1 {
        for j in 0..< g.height  {
            cell := g.cells[i][j]
            if cell.cell_type == CELL_TYPE.WATER {
                drop_water(g, new_cells, cell, i, j)
            }
            else if cell.cell_type == CELL_TYPE.SAND {
                drop_sand(g, new_cells, cell, i, j)
            }
        }
    }
    
    for col in g.cells {
        delete(col)
    }
    delete(g.cells)
    g.cells = new_cells
}

// Draw the grid
Draw :: proc(g : ^Grid) {
    rl.DrawRectangle(i32(g.offset_pos.x), i32(g.offset_pos.y), i32(f32(g.width)*g.blockSize), i32(f32(g.height)*g.blockSize), rl.WHITE)
    for i in 0..< g.width {
        for j in 0..< g.height {
            cell := g.cells[i][j]
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
