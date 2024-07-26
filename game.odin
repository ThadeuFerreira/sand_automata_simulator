package game

import rl "vendor:raylib"
import "./grid"


screen_width : i32 = 1000
screen_height : i32 = 1000




CELL_SIZE :: 2
CELL_COUNT_X :: 500
CELL_COUNT_Y :: 500

main :: proc()
{
    // Initialization
    //--------------------------------------------------------------------------------------
   gridOffset := rl.Vector2{0,0}

   gridInstance := grid.Make_Grid(
    CELL_COUNT_X,
    CELL_COUNT_Y,
    gridOffset,
    CELL_SIZE,
    rl.BLACK,
   )



    rl.InitWindow(screen_width, screen_height, "raylib [core] example - basic window");


    //rl.SetTargetFPS(120) // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    rl.SetTraceLogLevel(rl.TraceLogLevel.ALL) // Show trace log messages (LOG_INFO, LOG_WARNING, LOG_ERROR, LOG_DEBUG)
    // Main game loop
    for !rl.WindowShouldClose()    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        grid.Update(&gridInstance)
        grid.Draw(&gridInstance)
        rl.EndDrawing()
    }

    rl.CloseWindow()
}