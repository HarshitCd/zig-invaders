const rl = @import("raylib");

pub const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn init(x: f32, y: f32, width: f32, height: f32) @This() {
        return .{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
        };
    }

    pub fn intersect(self: @This(), rec: @This()) bool {
        return self.x < rec.x + rec.width and
            self.x + self.width > rec.x and
            self.y < rec.y + rec.height and
            self.y + self.height > rec.y;
    }
};

pub const Player = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(x: f32, y: f32, width: f32, height: f32) @This() {
        return .{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .speed = 5.0,
        };
    }

    pub fn reset(self: *@This(), playerPosX: f32, playerPosY: f32) void {
        self.x = playerPosX;
        self.y = playerPosY;
    }

    pub fn getRect(self: @This()) Rectangle {
        return Rectangle.init(
            self.x,
            self.y,
            self.width,
            self.height,
        );
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            if (self.x + self.width + self.speed <= @as(f32, @floatFromInt(rl.getScreenWidth()))) {
                self.x += self.speed;
            }
        } else if (rl.isKeyDown(rl.KeyboardKey.left)) {
            if (self.x - self.speed >= 0)
                self.x -= self.speed;
        }
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.x),
            @intFromFloat(self.y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            .light_gray,
        );
    }
};

pub const Bullet = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(x: f32, y: f32, width: f32, height: f32) @This() {
        return .{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .speed = 10.0,
            .active = false,
        };
    }

    pub fn reset(self: *@This()) void {
        self.active = false;
    }

    pub fn getRect(self: @This()) Rectangle {
        return Rectangle.init(
            self.x,
            self.y,
            self.width,
            self.height,
        );
    }

    pub fn update(self: *@This()) void {
        if (self.active) {
            self.y -= self.speed;
            if (self.y + self.height <= 0) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.x),
                @intFromFloat(self.y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                .red,
            );
        }
    }
};

pub const Invader = struct {
    initX: f32,
    initY: f32,
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    alive: bool,

    pub fn init(x: f32, y: f32, width: f32, height: f32) @This() {
        return .{
            .initX = x,
            .initY = y,
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .alive = true,
        };
    }

    pub fn reset(self: *@This()) void {
        self.x = self.initX;
        self.y = self.initY;
        self.alive = true;
    }

    pub fn getRect(self: @This()) Rectangle {
        return Rectangle.init(
            self.x,
            self.y,
            self.width,
            self.height,
        );
    }

    pub fn draw(self: @This()) void {
        if (self.alive) {
            rl.drawRectangle(
                @intFromFloat(self.x),
                @intFromFloat(self.y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                .green,
            );
        }
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        self.x += dx;
        self.y += dy;
    }
};
