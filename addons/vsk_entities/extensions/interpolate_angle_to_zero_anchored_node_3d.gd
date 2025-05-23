# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# interpolate_angle_to_zero_anchored_node_3d.gd
# SPDX-License-Identifier: MIT

extends Node3D

var rotation_offset: float = 0.0

@export var anchor_node: Node3D


func _process(_delta: float) -> void:
	if !anchor_node:
		return

	var fraction: float = Engine.get_physics_interpolation_fraction()

	var lerped_angle: float = lerp_angle(rotation_offset, 0.0, fraction)

	transform = Transform3D()

	var offset_vector = (global_transform.affine_inverse() * anchor_node.global_transform).origin
	offset_vector.y = 0.0

	translate(offset_vector)
	rotate(Vector3.UP, lerped_angle)
	transform = transform.translated_local(-offset_vector)
