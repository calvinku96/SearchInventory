-- data.lua
data:extend{
    {
        type="sprite",
        name="search-sprite",
        filename="__core__/graphics/search-icon.png",
        priority="extra-high-no-scale",
        width=32,
        height=32,
        scale=1,
        tint={r=1, g=0, b=0, a=1}
    },
    {
        type="custom-input",
        name="search-inventory",
        key_sequence="CONTROL + SHIFT + F",
        consuming="all"
    },
    {
        type="custom-input",
        name="search-inventory-toggle-button",
        key_sequence="CONTROL + SHIFT + ALT + F",
        consuming="all"
    }
}
-- Taken from https://mods.factorio.com/mods/Coppermine/what-is-it-really-used-for

data.raw["gui-style"].default.small_spacing_scroll_pane_style = {
    type="scroll_pane_style",
    parent="scroll_pane_style",
    top_padding=5,
    left_padding=5,
    right_padding=5,
    bottom_padding=5,
    flow_style={"slot_table_spacing_flow_style"}
}

data.raw["gui-style"].default.row_table_style = {
    type="table_style",
    cell_padding=10,
    horizontal_spacing=10,
    vertical_spacing=10,
    odd_row_graphical_set={
        type="composition",
        filename="__core__/graphics/gui.png",
        priority="extra-high-no-scale",
        corner_size={3, 3},
        position={8, 0}
    },
    even_row_graphical_set={
        type="composition",
        filename="__core__/graphics/gui.png",
        priority="extra-high-no-scale",
        corner_size={3, 3},
        position={8, 0}
    }
}
