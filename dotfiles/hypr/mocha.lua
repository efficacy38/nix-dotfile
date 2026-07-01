local function color(hex)
    return {
        hex = hex,
        rgb = "rgb(" .. hex .. ")",
        rgba = function(alpha)
            return "rgba(" .. hex .. alpha .. ")"
        end,
    }
end

local shadow = color("1a1a1a")

return {
    rosewater = color("f5e0dc"),
    flamingo = color("f2cdcd"),
    pink = color("f5c2e7"),
    mauve = color("cba6f7"),
    red = color("f38ba8"),
    maroon = color("eba0ac"),
    peach = color("fab387"),
    yellow = color("f9e2af"),
    green = color("a6e3a1"),
    teal = color("94e2d5"),
    sky = color("89dceb"),
    sapphire = color("74c7ec"),
    blue = color("89b4fa"),
    lavender = color("b4befe"),
    text = color("cdd6f4"),
    subtext1 = color("bac2de"),
    subtext0 = color("a6adc8"),
    overlay2 = color("9399b2"),
    overlay1 = color("7f849c"),
    overlay0 = color("6c7086"),
    surface2 = color("585b70"),
    surface1 = color("45475a"),
    surface0 = color("313244"),
    base = color("1e1e2e"),
    mantle = color("181825"),
    crust = color("11111b"),

    shadow = {
        active = shadow.rgba("99"),
        inactive = shadow.rgba("55"),
    },
}
