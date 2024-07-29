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

    brush_radius: f32,
}

CELL_TYPE :: enum {
    EMPTY,
    SAND,
    WATER,
}

PARTICLE_STATE :: enum {
    FREE_FALL,
    REST,
    SLIDING,
}

Cell :: struct {
    cell_type: CELL_TYPE,
    color: rl.Color,
    updated: bool,
    state: PARTICLE_STATE,
    grav_potential: f32,
    kinetic_energy: f32,
    velocity_mod: int,
}

globalTimeCounter : f32 = 0.0

Make_Grid :: proc(width : int, height : int, brush_size : f32, offset_pos: rl.Vector2,blockSize: f32,  backgroundColor: rl.Color) -> Grid {
    g := Grid{
        width = width,
        height = height,
        blockSize = blockSize,
        offset_pos = offset_pos,
        backgroundColor = backgroundColor,
        brush_radius = brush_size,
    }

    current_cells := make([]Cell, width*height)
    previous_cells := make([]Cell, width*height)

    g.fall_speed = fall_speed

    g.current_cells = current_cells
    g.previous_cells = previous_cells
    return g
}

fall_time : f32 = 0.0
fall_speed : f32 = 100

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

    g.brush_radius += rl.GetMouseWheelMove()
    g.brush_radius = math.clamp(g.brush_radius, 1, 100) //clamp brush radius to 1-100
    
    if color_change_time >= color_change_interval {
        sand_color_list := SAND_COLOR_LIST
        new_sand_color = sand_color_list[rand.int_max(len(SAND_COLOR_LIST))]
        color_change_time = 0
    }

    if rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
        x := int((mouse_pos.x - g.offset_pos.x) / g.blockSize)
        y := int((mouse_pos.y - g.offset_pos.y) / g.blockSize)
        brush_radius := int(g.brush_radius/g.blockSize)
        brush_density :f32 = 0.3
        for i in -brush_radius..< brush_radius {
            for j in -brush_radius..< brush_radius {
                if i*i + j*j < brush_radius*brush_radius {
                    if rand.float32() < brush_density {
                        generate_sand_at(g, x+i, y+j)
                    }
                }
            }
        }
    }
    if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
        x := int((mouse_pos.x - g.offset_pos.x) / g.blockSize)
        y := int((mouse_pos.y - g.offset_pos.y) / g.blockSize)
        brush_radius := int(g.brush_radius/g.blockSize)
        for i in -brush_radius..< brush_radius {
            for j in -brush_radius..< brush_radius {
                if i*i + j*j < brush_radius*brush_radius {
                    destroy_cells(g, x+i, y+j)
                }
            }
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

destroy_cells :: proc(g: ^Grid, x,y :int) {
    h := g.height
    w := g.width
    if x >= 0 && x < w && y >= 0 && y < h {
        g.current_cells[x + y*w] = Cell{
            cell_type = CELL_TYPE.EMPTY,
            color = rl.BLACK,
        }
    }
}

generate_sand_at :: proc(g: ^Grid, x,y :int) {
    
    if x >= 0 && x < g.width && y >= 0 && y < g.height {
        new_cell := Cell{
            cell_type = CELL_TYPE.SAND,
            color = new_sand_color,
            state = PARTICLE_STATE.FREE_FALL,
            updated = false,
            grav_potential = f32(g.height - y),
            kinetic_energy = 0,
            velocity_mod = 1,
        }
        g.previous_cells[x + y*g.width] = new_cell
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

gravity_acceleration : f32 = 9.8
drop_sand :: proc(g: ^Grid, cell : Cell, i,j :int){
    h := g.height
    w := g.width
    kinetic_energy := cell.kinetic_energy
    grav_potential := cell.grav_potential
    velocity_mod := cell.velocity_mod
    if cell.state == PARTICLE_STATE.REST{
        return
    }
    kinetic_energy += 1
    grav_potential -= 1
    if int(kinetic_energy)%int(70/gravity_acceleration) == 0 { //Magic number to make the sand fall nicer
        velocity_mod += 1
    }
    vm := cell.velocity_mod
    for k := vm; k > 0; k -= 1 {
        if j + k < h {
            if g.previous_cells[i + (j+k)*w].cell_type == CELL_TYPE.EMPTY ||  g.previous_cells[i + j*w+1].cell_type == CELL_TYPE.WATER{
                g.current_cells[i + j*w] = Cell{
                    cell_type = CELL_TYPE.EMPTY,
                    color = rl.BLACK,
                }
                g.current_cells[i + (j+k)*w] = cell
                g.current_cells[i + (j+k)*w].kinetic_energy = kinetic_energy
                g.current_cells[i + (j+k)*w].grav_potential = grav_potential
                g.current_cells[i + (j+k)*w].velocity_mod = velocity_mod
                g.current_cells[i + (j+k)*w].state = PARTICLE_STATE.FREE_FALL
                break
            }
            else if g.previous_cells[i + (j+k)*w].cell_type == CELL_TYPE.SAND{
                if g.previous_cells[(i-1) +(j+k)*w].cell_type != CELL_TYPE.SAND && g.previous_cells[(i+1) + (j+k)*w].cell_type != CELL_TYPE.SAND {
                    g.current_cells[i + j*w] = Cell{
                        cell_type = CELL_TYPE.EMPTY,
                        color = rl.BLACK,
                    }
                    if rand.float32() < 0.5 {
                        g.current_cells[(i-1) +(j+k)*w] = cell
                        g.current_cells[(i-1) +(j+k)*w].kinetic_energy = kinetic_energy
                        g.current_cells[(i-1) +(j+k)*w].grav_potential = grav_potential
                        g.current_cells[(i-1) +(j+k)*w].velocity_mod = velocity_mod
                        g.current_cells[(i-1) +(j+k)*w].state = PARTICLE_STATE.REST
                    } else {
                        g.current_cells[(i+1) + (j+k)*w] = cell
                        g.current_cells[(i+1) + (j+k)*w].kinetic_energy = kinetic_energy
                        g.current_cells[(i+1) + (j+k)*w].grav_potential = grav_potential
                        g.current_cells[(i+1) + (j+k)*w].velocity_mod = velocity_mod
                        g.current_cells[(i+1) + (j+k)*w].state = PARTICLE_STATE.REST
                    }
                    break
                }
                else if g.previous_cells[(i-1) +(j+k)*w].cell_type != CELL_TYPE.SAND {
                    g.current_cells[i + j*w] = Cell{
                        cell_type = CELL_TYPE.EMPTY,
                        color = rl.BLACK,
                    }
                    g.current_cells[(i-1) +(j+k)*w] = cell
                    g.current_cells[(i-1) +(j+k)*w].kinetic_energy = kinetic_energy
                    g.current_cells[(i-1) +(j+k)*w].grav_potential = grav_potential
                    g.current_cells[(i-1) +(j+k)*w].velocity_mod = velocity_mod
                    g.current_cells[(i-1) +(j+k)*w].state = PARTICLE_STATE.REST
                    break
                }
                else if g.previous_cells[(i+1) + (j+k)*w].cell_type != CELL_TYPE.SAND {

                        g.current_cells[i + j*w] = Cell{
                            cell_type = CELL_TYPE.EMPTY,
                            color = rl.BLACK,
                        }
                        g.current_cells[(i+1) + (j+k)*w] = cell
                        g.current_cells[(i+1) + (j+k)*w].kinetic_energy = kinetic_energy
                        g.current_cells[(i+1) + (j+k)*w].grav_potential = grav_potential
                        g.current_cells[(i+1) + (j+k)*w].velocity_mod = velocity_mod
                        g.current_cells[(i+1) + (j+k)*w].state = PARTICLE_STATE.REST
                    
                    break
                }
                else {
                    g.current_cells[i + j*w] = cell
                    g.current_cells[i + j*w].kinetic_energy = 0
                    g.current_cells[i + j*w].grav_potential = grav_potential
                    g.current_cells[i + j*w].velocity_mod = velocity_mod
                    g.current_cells[i + j*w].state = PARTICLE_STATE.REST
                }
            } 
        } else {
            g.current_cells[i + j*w] = cell
            g.current_cells[i + j*w].kinetic_energy = 0
            g.current_cells[i + j*w].grav_potential = grav_potential
            g.current_cells[i + j*w].velocity_mod = velocity_mod
            g.current_cells[i + j*w].state = PARTICLE_STATE.REST
        }
    }
    
}

copy_particles :: proc(g : ^Grid) {
    for i in 0..< g.width {
        for j in 0..< g.height {
            g.previous_cells[i + j*g.width] = g.current_cells[i + j*g.width]
        }
    }
}

particle_slickness : f32 = 0.01
update_empty_cells :: proc(g : ^Grid, cell : Cell, i,j :int) {
    h := g.height
    w := g.width
    if j > 0 && j < h {
        g.current_cells[i + (j-1)*w].state = PARTICLE_STATE.FREE_FALL 
    }
    if i > 0 {
        if g.current_cells[(i-1) + j*w].cell_type == CELL_TYPE.SAND {
            if rand.float32() < particle_slickness {
                g.current_cells[(i-1) + j*w].state = PARTICLE_STATE.SLIDING
            }
        }
    }
    if i < w - 1 {
        if g.current_cells[(i+1) + j*w].cell_type == CELL_TYPE.SAND {
            if rand.float32() < particle_slickness {
                g.current_cells[(i+1) + j*w].state = PARTICLE_STATE.SLIDING
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
            else if cell.cell_type == CELL_TYPE.EMPTY {
                update_empty_cells(g, cell, i, j)
            }
        }
    }
    
    copy_particles(g)

}

CELL_STATE_COLORS :: []rl.Color{
    rl.BLACK,
    rl.RED,
    rl.BLUE,
}

// Draw the grid
Draw :: proc(g : ^Grid) {
    rl.DrawRectangle(i32(g.offset_pos.x), i32(g.offset_pos.y), i32(f32(g.width)*g.blockSize), i32(f32(g.height)*g.blockSize), rl.WHITE)
    mouse_pos := rl.GetMousePosition()
    m_x := i32(mouse_pos.x - g.offset_pos.x)
    m_y := i32(mouse_pos.y - g.offset_pos.y)
    
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
            } else {
                color = cell.state == PARTICLE_STATE.FREE_FALL ? rl.BLACK: rl.DARKGRAY
            }
            rl.DrawRectangle(i32(f32(i) * g.blockSize + g.offset_pos.x), i32(f32(j) * g.blockSize + g.offset_pos.y), i32(g.blockSize), i32(g.blockSize), color)
        }
    }
    rl.DrawCircleLines(m_x, m_y,g.brush_radius, rl.WHITE)
}
