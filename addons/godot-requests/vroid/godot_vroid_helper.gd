# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# godot_vroid_helper.gd
# SPDX-License-Identifier: MIT

@tool
extends GodotRequestHelper
class_name GodotVroidHelper

###

# enum VroidUserContentType { UNKNOWN, AVATAR }

const ROOT_PATH: String = "https://hub.vroid.com"
const API_VERSION: String = "11"
const API_PATH: String = "/api"
const PROFILE_PATH: String = "/account"
const UPLOADED_MODELS_PATH: String = "/account/character_models"
const MODEL_PATH: String = "/character_models" # character_models/{id}
const SEARCH_PATH: String = "/search/character_models"
const HEARTS_PATH: String = "/hearts"
const STAFF_PICKS_PATH: String = "/staff_picks"
const DEFAULT_ACCOUNT_ID: String = "UNKNOWN_ID"
const DEFAULT_ACCOUNT_USERNAME: String = "UNKNOWN_USERNAME"


func get_api_path() -> String:
	return ROOT_PATH + API_PATH

func get_api_header() -> String:
	return "X-Api-Version: " + API_VERSION

