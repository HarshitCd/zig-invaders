pub const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    padding: f32,

    playerStartPosX: f32,
    playerStartPosY: f32,
    playerHeight: f32,
    playerWidth: f32,

    bulletWidth: f32,
    bulletHeight: f32,

    gameOverText: [:0]const u8,
    gameOverFontSize: i32,

    maxBullets: i32,
    invaderRows: i32,
    invaderCols: i32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderSpace: f32,
    invaderMoveX: f32,
    invaderMoveY: f32,
    invaderMoveDelay: i32,

    pub fn init() @This() {
        const sw: i32 = 800;
        const sh: i32 = 600;

        const pw: f32 = 50;
        const ph: f32 = 25;

        const padding = 50;

        return .{
            .screenWidth = sw,
            .screenHeight = sh,
            .padding = padding,

            .playerStartPosX = (@as(f32, @floatFromInt(sw)) - pw) / 2.0,
            .playerStartPosY = @as(f32, @floatFromInt(sh)) - ph - padding,
            .playerWidth = pw,
            .playerHeight = ph,

            .bulletWidth = 8.0,
            .bulletHeight = 8.0,
            .maxBullets = 10,

            .gameOverText = "Game Over",
            .gameOverFontSize = 50,

            .invaderRows = 5,
            .invaderCols = 10,
            .invaderWidth = 40,
            .invaderHeight = 20,
            .invaderSpace = 10,
            .invaderMoveX = 20,
            .invaderMoveY = 30,
            .invaderMoveDelay = 10,
        };
    }
};
