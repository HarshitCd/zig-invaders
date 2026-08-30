const std = @import("std");
const rl = @import("raylib");

const comp = @import("components.zig");
const conf = @import("config.zig");

const gc: conf.GameConfig = conf.GameConfig.init();

const gameState = enum {
    Home,
    Game,
    GameOver,
};

pub fn main() void {
    var state: gameState = .Home;

    var invaders_alive: i32 = gc.invaderCols * gc.invaderRows;
    var invader_direction: f32 = 1.0;
    var invader_move_timer: i32 = 0;

    var key_invader: comp.Invader = undefined;
    var dy: f32 = undefined;
    var dx: f32 = undefined;
    var val: f32 = undefined;

    var score: u32 = 0;
    var game_lost = false;

    var player: comp.Player = comp.Player.init(
        gc.playerStartPosX,
        gc.playerStartPosY,
        gc.playerWidth,
        gc.playerHeight,
    );

    var bullets: [gc.maxBullets]comp.Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = comp.Bullet.init(
            0.0,
            0.0,
            gc.bulletWidth,
            gc.bulletHeight,
        );
    }

    var invaders: [gc.invaderRows][gc.invaderCols]comp.Invader = undefined;
    for (&invaders, 0..) |*rows, i| {
        for (rows, 0..) |*invader, j| {
            const posX: f32 = (gc.invaderSpace + gc.invaderWidth) * @as(f32, @floatFromInt(j));
            const posY: f32 = (gc.invaderSpace + gc.invaderHeight) * @as(f32, @floatFromInt(i)) + gc.padding;

            invader.* = comp.Invader.init(
                posX,
                posY,
                gc.invaderWidth,
                gc.invaderHeight,
            );
        }
    }

    rl.initWindow(gc.screenWidth, gc.screenHeight, "Zig Invaders");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);

        switch (state) {
            .Home => {
                rl.drawText(
                    gc.gameName,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(gc.gameName, gc.gameOverFontSize), 2),
                    @divTrunc(rl.getScreenHeight(), 2) - @divTrunc(gc.gameOverFontSize, 2) - @as(i32, @intFromFloat(gc.padding)),
                    gc.gameOverFontSize,
                    .yellow,
                );

                const instructionText: [:0]const u8 = "[space]: shoot, [<-]: move left, [->]: move right, [esc]: quit";
                rl.drawText(
                    instructionText,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(instructionText, 20), 2),
                    @divTrunc(rl.getScreenHeight(), 2) - @divTrunc(20, 2) + 50 - @as(i32, @intFromFloat(gc.padding)),
                    20,
                    .gray,
                );

                if (rl.isKeyPressed(.space)) {
                    state = .Game;
                }
            },
            .Game => {
                player.update();
                player.draw();

                if (rl.isKeyPressed(.space)) {
                    for (&bullets) |*bullet| {
                        if (!bullet.active) {
                            bullet.x = player.x + (player.width - bullet.width) / 2;
                            bullet.y = player.y;
                            bullet.active = true;
                            break;
                        }
                    }
                }

                for (&bullets) |*bullet| {
                    bullet.update();
                    bullet.draw();
                }

                dy = 0;
                dx = gc.invaderMoveX * invader_direction;
                key_invader = invaders[0][gc.invaderCols - 1];
                val = key_invader.x + key_invader.width + dx;

                if (invader_move_timer == gc.invaderMoveDelay) {
                    invader_move_timer = 0;

                    if (val > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
                        invader_direction *= -1;
                        dy = gc.invaderMoveY;
                        dx = 0;
                    }

                    key_invader = invaders[0][0];
                    val = key_invader.x + dx;
                    if (val < 0) {
                        invader_direction *= -1;
                        dy = gc.invaderMoveY;
                        dx = 0;
                    }
                } else {
                    dy = 0;
                    dx = 0;
                    invader_move_timer += 1;
                }

                for (&invaders) |*rows| {
                    for (rows) |*invader| {
                        invader.update(dx, 1.5 * dy);
                        if (!invader.alive) {
                            continue;
                        }

                        invader.draw();
                        if (player.getRect().intersect(invader.getRect()) or
                            invader.y >= @as(f32, @floatFromInt(rl.getScreenHeight())) - gc.padding)
                        {
                            game_lost = true;
                            state = .GameOver;
                            break;
                        }

                        for (&bullets) |*bullet| {
                            if (!bullet.active) {
                                continue;
                            }

                            if (bullet.getRect().intersect(invader.getRect())) {
                                bullet.active = false;
                                invader.alive = false;

                                invaders_alive -= 1;
                                score += 10;
                            }
                        }
                    }

                    if (invaders_alive == 0) {
                        state = .GameOver;
                    }
                }

                var buf: [32]u8 = undefined;
                const score_text: [:0]const u8 = std.fmt.bufPrintSentinel(&buf, "Score: {d}", .{score}, 0) catch "Score: --error--";
                rl.drawText(score_text, 10, rl.getScreenHeight() - 20 - 10, 20, .gray);
            },
            .GameOver => {
                rl.drawText(
                    gc.gameOverText,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(gc.gameOverText, gc.gameOverFontSize), 2),
                    @divTrunc(rl.getScreenHeight(), 2) - @divTrunc(gc.gameOverFontSize, 2) - @as(i32, @intFromFloat(gc.padding)),
                    gc.gameOverFontSize,
                    if (!game_lost) .green else .red,
                );

                var buf: [32]u8 = undefined;
                const score_text: [:0]const u8 = std.fmt.bufPrintSentinel(&buf, "Score: {d}", .{score}, 0) catch "Score: --error--";
                rl.drawText(
                    score_text,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(score_text, 24), 2),
                    @divTrunc(rl.getScreenHeight(), 2) - @divTrunc(24, 2) + 50 - @as(i32, @intFromFloat(gc.padding)),
                    24,
                    if (!game_lost) .green else .red,
                );

                if (rl.isKeyPressed(.r)) {
                    invaders_alive = gc.invaderCols * gc.invaderRows;
                    score = 0;
                    game_lost = false;
                    invader_direction = 1;

                    player.reset(gc.playerStartPosX, gc.playerStartPosY);
                    key_invader.reset();

                    for (&invaders) |*rows| {
                        for (rows) |*invader| {
                            invader.reset();
                        }
                    }

                    for (&bullets) |*bullet| {
                        bullet.reset();
                    }

                    state = .Game;
                } else if (rl.isKeyPressed(.q)) {
                    invaders_alive = gc.invaderCols * gc.invaderRows;
                    score = 0;
                    game_lost = false;
                    invader_direction = 1;

                    player.reset(gc.playerStartPosX, gc.playerStartPosY);
                    key_invader.reset();

                    for (&invaders) |*rows| {
                        for (rows) |*invader| {
                            invader.reset();
                        }
                    }

                    for (&bullets) |*bullet| {
                        bullet.reset();
                    }

                    state = .Home;
                }
            },
        }
    }
}
