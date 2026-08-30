const comp = @import("components.zig");
const conf = @import("game_config.zig");

const gc = conf.GameConfig.init();

pub const GameSetup = struct {
    score: u32,
    game_lost: bool,

    player: comp.Player,
    bullets: [gc.maxBullets]comp.Bullet,

    invaders_alive: i32,
    invaders: [gc.invaderRows][gc.invaderCols]comp.Invader,
    key_invader: comp.Invader,
    invader_bullets: [gc.maxBullets]comp.EnemyBullet,
    invader_move_timer: i32,
    invader_bullet_timer: i32,
    invader_move_x: f32,
    invader_move_y: f32,
    invader_direction: f32,
    val: f32,

    pub fn init() @This() {
        var player: comp.Player = undefined;
        player = comp.Player.init(
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

        var invader_bullets: [gc.maxBullets]comp.EnemyBullet = undefined;
        for (&invader_bullets) |*bullet| {
            bullet.* = comp.EnemyBullet.init(
                0.0,
                0.0,
                gc.enemyBulletWidth,
                gc.enemyBulletHeight,
            );
        }

        return .{
            .score = 0,
            .game_lost = false,

            .player = player,
            .bullets = bullets,

            .invaders_alive = gc.invaderCols * gc.invaderRows,
            .invaders = invaders,
            .key_invader = invaders[0][0],
            .invader_bullets = invader_bullets,
            .invader_move_timer = 0,
            .invader_bullet_timer = 0,
            .invader_move_x = 0,
            .invader_move_y = 0,
            .invader_direction = 1,
            .val = 0,
        };
    }

    pub fn resetLogic(self: *@This()) void {
        self.invaders_alive = gc.invaderCols * gc.invaderRows;
        self.score = 0;
        self.game_lost = false;
        self.invader_direction = 1;

        self.player.reset(gc.playerStartPosX, gc.playerStartPosY);
        self.key_invader.reset();

        for (&self.invaders) |*rows| {
            for (rows) |*invader| {
                invader.reset();
            }
        }

        for (&self.bullets) |*bullet| {
            bullet.reset();
        }

        for (&self.invader_bullets) |*bullet| {
            bullet.reset();
        }
    }
};
