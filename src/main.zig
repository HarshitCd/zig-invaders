const rl = @import("raylib");

const comp = @import("components.zig");
const conf = @import("game_config.zig");
const gameLogic = @import("game_logic.zig");

const gc: conf.GameConfig = conf.GameConfig.init();

const gameStates = enum {
    Home,
    Game,
    GameOver,
};

pub fn main() void {
    var state: gameStates = .Home;
    var gl: gameLogic.GameLogic = gameLogic.GameLogic.init();

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
                gl.player.update();
                gl.player.draw();

                if (rl.isKeyPressed(.space)) {
                    for (&gl.bullets) |*bullet| {
                        if (!bullet.active) {
                            bullet.x = gl.player.x + (gl.player.width - bullet.width) / 2;
                            bullet.y = gl.player.y;
                            bullet.active = true;
                            break;
                        }
                    }
                }

                for (&gl.bullets) |*bullet| {
                    bullet.update();
                    bullet.draw();
                }

                for (&gl.invader_bullets) |*bullet| {
                    bullet.update();
                    bullet.draw();

                    if (bullet.active and gl.player.getRect().intersect(bullet.getRect())) {
                        gl.game_lost = true;
                        state = .GameOver;
                    }
                }

                gl.invader_move_y = 0;
                gl.invader_move_x = gc.invaderMoveX * gl.invader_direction;
                gl.key_invader = gl.invaders[0][gc.invaderCols - 1];
                gl.val = gl.key_invader.x + gl.key_invader.width + gl.invader_move_x;

                gl.invader_move_timer += 1;
                if (gl.invader_move_timer == gc.invaderMoveDelay) {
                    gl.invader_move_timer = 0;

                    if (gl.val > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
                        gl.invader_direction *= -1;
                        gl.invader_move_y = gc.invaderMoveY;
                        gl.invader_move_x = 0;
                    }

                    gl.key_invader = gl.invaders[0][0];
                    gl.val = gl.key_invader.x + gl.invader_move_x;
                    if (gl.val < 0) {
                        gl.invader_direction *= -1;
                        gl.invader_move_y = gc.invaderMoveY;
                        gl.invader_move_x = 0;
                    }
                } else {
                    gl.invader_move_y = 0;
                    gl.invader_move_x = 0;
                }

                gl.invader_bullet_timer += 1;
                for (&gl.invaders) |*rows| {
                    for (rows) |*invader| {
                        if (invader.alive and gl.invader_bullet_timer == gc.enemyBulletDelay) {
                            for (&gl.invader_bullets) |*bullet| {
                                if (!bullet.active) {
                                    const chance = rl.getRandomValue(0, 100);
                                    if (chance < gc.enemyBulletChance) {
                                        bullet.active = true;
                                        bullet.x = invader.x + invader.width / 2;
                                        bullet.y = invader.y;
                                    }
                                }
                                break;
                            }
                        }

                        invader.update(gl.invader_move_x, 1.5 * gl.invader_move_y);
                        if (!invader.alive) {
                            continue;
                        }

                        invader.draw();
                        if (gl.player.getRect().intersect(invader.getRect()) or
                            invader.y >= @as(f32, @floatFromInt(rl.getScreenHeight())) - gc.padding)
                        {
                            gl.game_lost = true;
                            state = .GameOver;
                            break;
                        }

                        for (&gl.bullets) |*bullet| {
                            if (!bullet.active) {
                                continue;
                            }

                            if (bullet.getRect().intersect(invader.getRect())) {
                                bullet.active = false;
                                invader.alive = false;

                                gl.invaders_alive -= 1;
                                gl.score += 10;
                            }
                        }
                    }

                    if (gl.invaders_alive == 0) {
                        state = .GameOver;
                    }
                }
                if (gl.invader_bullet_timer == gc.enemyBulletDelay) {
                    gl.invader_bullet_timer = 0;
                }

                const score_text: [:0]const u8 = rl.textFormat("Score: %d", .{gl.score});
                rl.drawText(score_text, 10, rl.getScreenHeight() - 20 - 10, 20, .gray);
            },
            .GameOver => {
                rl.drawText(
                    gc.gameOverText,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(gc.gameOverText, gc.gameOverFontSize), 2),
                    @divTrunc(rl.getScreenHeight(), 2) - @divTrunc(gc.gameOverFontSize, 2) - @as(i32, @intFromFloat(gc.padding)),
                    gc.gameOverFontSize,
                    if (!gl.game_lost) .green else .red,
                );

                const score_text: [:0]const u8 = rl.textFormat("Score: %d", .{gl.score});
                rl.drawText(
                    score_text,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(score_text, 24), 2),
                    @divTrunc(rl.getScreenHeight(), 2) - @divTrunc(24, 2) + 50 - @as(i32, @intFromFloat(gc.padding)),
                    24,
                    if (!gl.game_lost) .green else .red,
                );

                if (rl.isKeyPressed(.r)) {
                    gl.resetLogic();
                    state = .Game;
                } else if (rl.isKeyPressed(.q)) {
                    gl.resetLogic();
                    state = .Home;
                }
            },
        }
    }
}
