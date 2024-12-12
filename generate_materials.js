var locometal_types = "slashed_locometal riveted_locometal locometal_pillar locometal_smokebox plated_locometal flat_slashed_locometal flat_riveted_locometal brass_wrapped_locometal copper_wrapped_locometal iron_wrapped_locometal locometal_boiler brass_wrapped_locometal_boiler copper_wrapped_locometal_boiler iron_wrapped_locometal_boiler".split(" ")

var locometal_colors = " white_ light_gray_ gray_ black_ brown_ red_ orange_ yellow_ lime_ green_ cyan_ light_blue_ blue_ purple_ magenta_ pink_".split(" ")

var copper_types = "s _stairs _slab".split(" ")

var copper_oxidations = " exposed_ weathered_ oxidized_".split(" ")

var copper_sets = "shingle tile".split(" ")
var copper_states = " waxed_".split(" ")

var dd_metal_shapes = "block stairs slab".split(" ")

var dd_metal_types = "polished tiled".split(" ")

var dd_metal_materials = "steel zinc bronze".split(" ")

var cbc_materials = "cast_iron bronze steel nethersteel".split(" ")

var cbc_shapes = ",sliding_breech unbored_,sliding_breech incomplete_,sliding_breech ,quickfiring_breech ,screw_breech unbored_,screw_breech incomplete_,screw_breech ,cannon_end ,autocannon_breech unbored_,autocannon_breech incomplete_,autocannon_breech ,autocannon_recoil_spring unbored_,autocannon_recoil_spring incomplete_,autocannon_recoil_spring ,autocannon_barrel unbored_,autocannon_barrel very_small_,cannon_layer small_,cannon_layer medium_,cannon_layer large_,cannon_layer very_large_,cannon_layer unbored_very_small_,cannon_layer unbored_small_,cannon_layer unbored_medium_,cannon_layer unbored_large_,cannon_layer unbored_very_large_,cannon_layer ,cannon_barrel built_up_,cannon_barrel ,cannon_chamber built_up_,cannon_chamber thick_,cannon_chamber".split(" ").map(x => x.split(","))

var createcasing_block_shapes = "mixer press depot".split(" ")

var createcasing_casing_shapes = "gearbox encased_chain_drive adjustable_chain_gearshift".split(" ").concat(createcasing_block_shapes)

var createcasing_block_materials = "brass copper".split(" ")

var createcasing_casing_materials = "railway creative industrial_iron".split(" ")

var createdeco_shapes = ",coinstack ,bars ,bars_overlay ,mesh_fence ,hull ,catwalk ,catwalk_stairs ,catwalk_railing ,support_wedge ,support ,sheet_metal ,door locked_,door ,trapdoor red_,lamp green_,lamp blue_,lamp yellow_,lamp".split(" ").map(x => x.split(","))

var createdeco_materials = "brass iron copper industrial_iron zinc".split(" ")

var handcrafted_woods = "acacia birch bamboo cherry crimson dark_oak jungle mangrove oak spruce warped".split(" ")

var handcrafted_fabrics = "couch fancy_bed".split(" ")

var colors = "white light_gray gray black brown red orange yellow lime green cyan light_blue blue purple magenta pink".split(" ")

var createframed_shapes = ",framed_glass_door ,framed_glass_trapdoor ,tiled_glass ,tiled_glass_pane ,framed_glass ,framed_glass_pane horizontal_,framed_glass horizontal_,framed_glass_pane vertical_,framed_glass vertical_,framed_glass_pane".split(" ").map(x => x.split(","))

var metals = []
var fabrics = []
var glass = []

locometal_colors.forEach(color => {
    locometal_types.forEach(type => {
        metals.push(`railways:${color}${type}`)
    })
})

copper_sets.forEach(set => {
    copper_oxidations.forEach(oxidation => {
        copper_states.forEach(state => {
            copper_types.forEach(type => {
                metals.push(`create:${state}${oxidation}copper_${set}${type}`)
            })
        })
    })
})

dd_metal_materials.forEach(material => {
    dd_metal_types.forEach(type => {
        dd_metal_shapes.forEach(shape => {
            metals.push(`create_dd:${material}_${type}_${shape}`)
        })
    })
})

cbc_materials.forEach(material => {
    cbc_shapes.forEach(shape => {
        metals.push(`createbigcannons:${shape[0]}${material}_${shape[1]}`)
    })
})

createcasing_block_materials.forEach(material => {
    createcasing_block_shapes.forEach(shape => {
        metals.push(`createcasing:${material}_${shape}`)
    })
})
createcasing_casing_materials.forEach(material => {
    createcasing_casing_shapes.forEach(shape => {
        metals.push(`createcasing:${material}_${shape}`)
    })
})

createdeco_materials.forEach(material => {
    createdeco_shapes.forEach(shape => {
        metals.push(`createdeco:${shape[0]}${material}_${shape[1]}`)
    })
})

handcrafted_fabrics.forEach(shape => {
    handcrafted_woods.forEach(wood => {
        fabrics.push(`handcrafted:${wood}_${shape}`)
    })
})

colors.forEach(color => {
    fabrics.push(`create:${color}_seat`)
    fabrics.push(`interiors:${color}_chair`)
    fabrics.push(`interiors:${color}_floor_chair`)
})

colors.forEach(color => {
    createframed_shapes.forEach(shape => {
        glass.push(`createframed:${shape[0]}${color}_stained_${shape[1]}`)
    })
})

console.log(`\x1b[36mmetal = \x1b[0m${metals.join(" ")}\n\n\x1b[36mfabric = \x1b[0m${fabrics.join(" ")}\n\n\x1b[36mglass = \x1b[0m${glass.join(" ")}`)