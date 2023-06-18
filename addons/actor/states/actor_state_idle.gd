# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# actor_state_idle.gd
# SPDX-License-Identifier: MIT

extends "res://addons/actor/states/actor_state.gd"  # actor_state.gd


func enter() -> void:
	state_machine.set_velocity(Vector3())

	if state_machine.is_noclipping():
		change_state("Noclip")
	else:
		if state_machine.is_attempting_movement():
			change_state("Locomotion")
			return
		elif state_machine.is_attempting_jumping():
			change_state("Pre-Jump")
			return


func update(_delta: float) -> void:
	if state_machine.is_noclipping():
		change_state("Noclip")
	else:
		if state_machine.is_attempting_movement():
			change_state("Locomotion")
			return
		elif state_machine.is_attempting_jumping():
			change_state("Pre-Jump")
			return

		state_machine.set_movement_vector(state_machine.get_velocity())


func exit() -> void:
	pass
