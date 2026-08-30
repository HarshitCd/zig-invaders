const rl = @import("raylib");

const comp = @import("components.zig");
const conf = @import("game_config.zig");
const gameSetup = @import("game_setup.zig");

const gameStates = enum {
    Home,
    Game,
    GameOver,
};

const gc: conf.GameConfig = conf.GameConfig.init();

pub fn main() void {
    var state: gameStates = .Home;
    var gs: gameSetup.GameSetup = gameSetup.GameSetup.init();

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

                const nextAction: [:0]const u8 = "Press [space] to start";
                rl.drawText(
                    nextAction,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(nextAction, 20), 2),
                    3 * @divTrunc(rl.getScreenHeight(), 5),
                    20,
                    .light_gray,
                );

                if (rl.isKeyPressed(.space)) {
                    state = .Game;
                }
            },
            .Game => {
                gs.player.update();
                gs.player.draw();

                if (rl.isKeyPressed(.space)) {
                    for (&gs.bullets) |*bullet| {
                        if (!bullet.active) {
                            bullet.x = gs.player.x + (gs.player.width - bullet.width) / 2;
                            bullet.y = gs.player.y;
                            bullet.active = true;
                            break;
                        }
                    }
                }

                for (&gs.bullets) |*bullet| {
                    bullet.update();
                    bullet.draw();
                }

                for (&gs.invader_bullets) |*bullet| {
                    bullet.update();
                    bullet.draw();

                    if (bullet.active and gs.player.getRect().intersect(bullet.getRect())) {
                        gs.game_lost = true;
                        state = .GameOver;
                    }
                }

                gs.invader_move_y = 0;
                gs.invader_move_x = gc.invaderMoveX * gs.invader_direction;
                gs.key_invader = gs.invaders[0][gc.invaderCols - 1];
                gs.val = gs.key_invader.x + gs.key_invader.width + gs.invader_move_x;

                gs.invader_move_timer += 1;
                if (gs.invader_move_timer == gc.invaderMoveDelay) {
                    gs.invader_move_timer = 0;

                    if (gs.val > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
                        gs.invader_direction *= -1;
                        gs.invader_move_y = gc.invaderMoveY;
                        gs.invader_move_x = 0;
                    }

                    gs.key_invader = gs.invaders[0][0];
                    gs.val = gs.key_invader.x + gs.invader_move_x;
                    if (gs.val < 0) {
                        gs.invader_direction *= -1;
                        gs.invader_move_y = gc.invaderMoveY;
                        gs.invader_move_x = 0;
                    }
                } else {
                    gs.invader_move_y = 0;
                    gs.invader_move_x = 0;
                }

                gs.invader_bullet_timer += 1;
                for (&gs.invaders) |*rows| {
                    for (rows) |*invader| {
                        if (invader.alive and gs.invader_bullet_timer >= gc.enemyBulletDelay) {
                            for (&gs.invader_bullets) |*bullet| {
                                if (!bullet.active) {
                                    const chance = rl.getRandomValue(0, 100);
                                    if (chance < gc.enemyBulletChance) {
                                        bullet.active = true;
                                        bullet.x = invader.x + invader.width / 2;
                                        bullet.y = invader.y;

                                        gs.invader_bullet_timer = 0;
                                    }
                                    break;
                                }
                            }
                        }

                        invader.update(gs.invader_move_x, 1.5 * gs.invader_move_y);
                        if (!invader.alive) {
                            continue;
                        }

                        invader.draw();
                        if (gs.player.getRect().intersect(invader.getRect()) or
                            invader.y >= @as(f32, @floatFromInt(rl.getScreenHeight())) - gc.padding)
                        {
                            gs.game_lost = true;
                            state = .GameOver;
                            break;
                        }

                        for (&gs.bullets) |*bullet| {
                            if (!bullet.active) {
                                continue;
                            }

                            if (bullet.getRect().intersect(invader.getRect())) {
                                bullet.active = false;
                                invader.alive = false;

                                gs.invaders_alive -= 1;
                                gs.score += 10;
                            }
                        }
                    }

                    if (gs.invaders_alive == 0) {
                        state = .GameOver;
                    }
                }

                const score_text: [:0]const u8 = rl.textFormat("Score: %d", .{gs.score});
                rl.drawText(score_text, 10, rl.getScreenHeight() - 20 - 10, 20, .gray);
            },
            .GameOver => {
                rl.drawText(
                    gc.gameOverText,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(gc.gameOverText, gc.gameOverFontSize), 2),
                    @divTrunc(rl.getScreenHeight(), 2) - @divTrunc(gc.gameOverFontSize, 2) - @as(i32, @intFromFloat(gc.padding)),
                    gc.gameOverFontSize,
                    if (!gs.game_lost) .green else .red,
                );

                const score_text: [:0]const u8 = rl.textFormat("Score: %d", .{gs.score});
                rl.drawText(
                    score_text,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(score_text, 24), 2),
                    @divTrunc(rl.getScreenHeight(), 2) - @divTrunc(24, 2) + 50 - @as(i32, @intFromFloat(gc.padding)),
                    24,
                    if (!gs.game_lost) .green else .red,
                );

                const nextAction: [:0]const u8 = "[r]: reset, [q]: return to home, [esc]: quit";
                rl.drawText(
                    nextAction,
                    @divTrunc(rl.getScreenWidth(), 2) - @divTrunc(rl.measureText(nextAction, 20), 2),
                    3 * @divTrunc(rl.getScreenHeight(), 5),
                    20,
                    .light_gray,
                );

                if (rl.isKeyPressed(.r)) {
                    gs.resetLogic();
                    state = .Game;
                } else if (rl.isKeyPressed(.q)) {
                    gs.resetLogic();
                    state = .Home;
                }
            },
        }
    }
}
