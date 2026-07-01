-- Hyprland Lua config migrated from hyprland.conf.
-- API target: Hyprland 0.55.4.

local mocha = require("mocha")
-- -- hyprmon: managed monitor profile include
-- require("hyprmon")

local terminal = "alacritty"
local fileManager = "dolphin"
local menu = 'rofi -show drun --sorting-method fzf -run-command "uwsm-app -- {cmd}"'

local mainMod = "SUPER"
local shiftSuper = mainMod .. " + SHIFT"


----------------
-- Monitors
----------------

hl.config({
    debug = {
        disable_scale_checks = true,
    },
})

hl.monitor({
    output = "eDP-1",
    mode = "2560x1600@144.00",
    position = "2016x1376",
    scale = 1.50,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "2560x1440@75.00",
    position = "1792x192",
    scale = 1.25,
})


----------------
-- Autostart
----------------

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- thunderbird", { workspace = "9 silent" })
    hl.exec_cmd("uwsm app -- keepassxc", { workspace = "8 silent" })
    hl.exec_cmd("brightnessctl set 35%")
    hl.exec_cmd("hyprmon --profile standard")
end)


----------------
-- Environment
----------------

hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "breeze_cursors")
hl.env("XDG_MENU_PREFIX", "plasma-")


----------------
-- Look and feel
----------------

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,

        col = {
            active_border = {
                colors = { mocha.mauve.rgba("ee"), mocha.lavender.rgba("ee") },
                angle = 45,
            },
            inactive_border = mocha.surface2.rgba("aa"),
        },

        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 12,
        active_opacity = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled = true,
            range = 20,
            render_power = 2,
            color = mocha.shadow.active,
            color_inactive = mocha.shadow.inactive,
        },

        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            vibrancy = 0.1696,
            new_optimizations = true,
        },
    },

    cursor = {
        no_hardware_cursors = true,
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = false })
hl.animation({ leaf = "workspacesIn", enabled = false })
hl.animation({ leaf = "workspacesOut", enabled = false })

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})


----------------
-- Input
----------------

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "asce1203:00-04f3:330c-touchpad",
    sensitivity = 1.0,
    accel_profile = "flat",
})


----------------
-- Keybindings
----------------

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("uwsm-app -- " .. terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("dunstctl close-all"))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(shiftSuper .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(shiftSuper .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("my-audio-control up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("my-audio-control down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("my-audio-control mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("PRINT", hl.dsp.exec_cmd("uwsm app -- hyprshot -m window"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("uwsm app -- hyprshot -m region"))
hl.bind(shiftSuper .. " + l", hl.dsp.exec_cmd("uwsm app -- hyprlock"))
hl.bind("SUPER + Tab", hl.dsp.window.cycle_next())
hl.bind("SUPER + Tab", hl.dsp.window.bring_to_top())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + Y", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("~/.config/hypr/handle_lid_switch.sh"))
hl.bind("F9", hl.dsp.exec_cmd("hyprmon --profile docked"))
hl.bind("F10", hl.dsp.exec_cmd("hyprmon --profile standard"))


----------------
-- Rules
----------------

hl.window_rule({
    name = "float-class-floating",
    match = { class = "floating" },
    float = true,
})

for _, namespace in ipairs({ "waybar", "rofi" }) do
    hl.layer_rule({
        name = "glass-" .. namespace,
        match = { namespace = namespace },
        blur = true,
        ignore_alpha = 0,
        xray = false,
    })
end

hl.window_rule({
    name = "float-nm-connection-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
})

hl.window_rule({
    name = "float-mate-volume-control",
    match = { class = "^(mate-volume-control)$" },
    float = true,
})

hl.window_rule({
    name = "float-overskride",
    match = { class = "^(io.github.kaii_lb.Overskride)$" },
    float = true,
    size = "800 450",
})

hl.window_rule({
    name = "float-picture-in-picture",
    match = { title = "^Picture-in-Picture$" },
    float = true,
})

hl.window_rule({
    name = "float-bluetooth-title",
    match = { title = "^Bluetooth$" },
    float = true,
})

hl.window_rule({
    name = "float-nmtui",
    match = { class = "^(nmtui-float)$" },
    float = true,
    size = "1000 600",
})

local games = "^(steam_app_.*|steam_proton|streaming_client|gamescope)$"

hl.window_rule({
    name = "games-workspace-and-fullscreen",
    match = { class = games },
    workspace = "7",
    fullscreen = true,
    fullscreen_state = "2",
    idle_inhibit = "always",
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- hyprmon: managed monitor profile include
require("hyprmon")
