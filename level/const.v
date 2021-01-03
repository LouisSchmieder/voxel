module level

import nbt

const(

	dimension_codec = nbt.Node{
		typ: .tag_compound
		name: ''
		payload: nbt.NodePayload([
			nbt.Node{
				typ: .tag_compound
				name: 'minecraft:dimension_type'
				payload: nbt.NodePayload([
					nbt.Node{
						typ: .tag_string
						name: 'type'
						payload: nbt.NodePayload('minecraft:dimension_type')
					},
					nbt.Node {
						typ: .tag_list
						name: 'value'
						payload: nbt.NodePayload(nbt.NodeList{
							typ: .tag_compound
							list: [nbt.NodePayload(dimension)]
						})
					},
					nbt.Node{
						typ: .tag_invalid
					}
				])
			}
			nbt.Node{
				typ: .tag_compound
				name: 'minecraft:worldgen/biome'
				payload: nbt.NodePayload([
					nbt.Node{
						typ: .tag_string
						name: 'type'
						payload: nbt.NodePayload('minecraft:worldgen/biome')
					}
					nbt.Node{
						typ: .tag_list
						name: 'value'
						payload: nbt.NodePayload(nbt.NodeList{
							typ: .tag_string
							list: []nbt.NodePayload{}
						})
					}
					nbt.Node{
						typ: .tag_invalid
					}
				])
			}
			nbt.Node{
				typ: .tag_invalid
			}
		])
	}
	dimension = nbt.Node{
		typ: .tag_compound
		name: ''
		payload: nbt.NodePayload([
			nbt.Node{
				typ: .tag_string
				name: 'name'
				payload: nbt.NodePayload('minecraft:overworld')
			},
			nbt.Node{
				typ: .tag_int
				name: 'id'
				payload: nbt.NodePayload(int(0))
			}
			nbt.Node{
				typ: .tag_compound
				name: 'element'
				payload: nbt.NodePayload([
					nbt.Node{
						typ: .tag_byte
						name: 'piglin_safe'
						payload: nbt.NodePayload(0x00)
					}
					nbt.Node{
						typ: .tag_byte
						name: 'natural'
						payload: nbt.NodePayload(0x01)
					}
					nbt.Node{
						typ: .tag_float
						name: 'ambient_light'
						payload: nbt.NodePayload(0.0)
					}
					nbt.Node{
						typ: .tag_string
						name: 'infiniburn'
						payload: nbt.NodePayload('minecraft:infiniburn_overworld')
					}
					nbt.Node{
						typ: .tag_byte
						name: 'respawn_anchor_works'
						payload: nbt.NodePayload(0x00)
					}
					nbt.Node{
						typ: .tag_byte
						name: 'has_skylight'
						payload: nbt.NodePayload(0x01)
					}
					nbt.Node{
						typ: .tag_byte
						name: 'bed_works'
						payload: nbt.NodePayload(0x01)
					}
					nbt.Node{
						typ: .tag_string
						name: 'effects'
						payload: nbt.NodePayload('minecraft:overworld')
					}
					nbt.Node{
						typ: .tag_byte
						name: 'has_raids'
						payload: nbt.NodePayload(0x01)
					}
					nbt.Node{
						typ: .tag_int
						name: 'logical_height'
						payload: nbt.NodePayload(int(256))
					}
					nbt.Node{
						typ: .tag_float
						name: 'coordinate_scale'
						payload: nbt.NodePayload(f32(1.0))
					}
					nbt.Node{
						typ: .tag_byte
						name: 'ultrawarm'
						payload: nbt.NodePayload(0x00)
					}
					nbt.Node{
						typ: .tag_byte
						name: 'has_ceiling'
						payload: nbt.NodePayload(0x00)
					}
					nbt.Node{
						typ: .tag_invalid
					}
				])
			}
			nbt.Node{
				typ: .tag_invalid
			}
		])
	}

)