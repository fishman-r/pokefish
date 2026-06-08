extends Control
class_name MainGame

const PondStageScene = preload("res://godot/scenes/ui/pond_stage.tscn")
const ResourceHudScene = preload("res://godot/scenes/ui/resource_hud.tscn")
const PartnerFloatScene = preload("res://godot/scenes/ui/partner_float.tscn")
const ActionDockScene = preload("res://godot/scenes/ui/action_dock.tscn")
const ModeDockScene = preload("res://godot/scenes/ui/mode_dock.tscn")
const FxLayerScene = preload("res://godot/scenes/ui/fx_layer.tscn")
const BottomSheetScene = preload("res://godot/scenes/ui/bottom_sheet.tscn")
const PartnerSheetScene = preload("res://godot/scenes/ui/partner_sheet.tscn")
const FoodSheetScene = preload("res://godot/scenes/ui/food_sheet.tscn")
const EvolutionSheetScene = preload("res://godot/scenes/ui/evolution_sheet.tscn")
const PanelHostScene = preload("res://godot/scenes/ui/panel_host.tscn")
const HatcheryPanelScene = preload("res://godot/scenes/ui/hatchery_panel.tscn")
const DexPanelScene = preload("res://godot/scenes/ui/dex_panel.tscn")
const AdventureMapScene = preload("res://godot/scenes/ui/adventure_map.tscn")
const QuestBoardScene = preload("res://godot/scenes/ui/quest_board.tscn")
const DebugLayerScene = preload("res://godot/scenes/ui/debug_layer.tscn")
const GameData = preload("res://godot/scripts/game_data.gd")

var controller
var world_layer
var hud_layer
var dock_layer
var sheet_layer
var fx_canvas
var debug_canvas
var pond_stage
var resource_hud
var partner_float
var action_dock
var mode_dock
var fx_layer
var debug_layer
var panel_host
var bottom_sheet
var active_panel_content
var evolution_locked = false
var collect_locked = false
var feed_locked = false

func _ready():
	_apply_theme()
	_build_layers()
	_build_home()
	_bind_controller()

func _apply_theme():
	theme = UiTheme.create_app_theme()

func _build_layers():
	world_layer = Control.new()
	world_layer.name = "GameWorldLayer"
	world_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(world_layer)

	hud_layer = CanvasLayer.new()
	hud_layer.name = "HudLayer"
	hud_layer.layer = 10
	add_child(hud_layer)

	dock_layer = CanvasLayer.new()
	dock_layer.name = "DockLayer"
	dock_layer.layer = 20
	add_child(dock_layer)

	sheet_layer = CanvasLayer.new()
	sheet_layer.name = "SheetLayer"
	sheet_layer.layer = 30
	add_child(sheet_layer)

	fx_canvas = CanvasLayer.new()
	fx_canvas.name = "FxLayer"
	fx_canvas.layer = 40
	add_child(fx_canvas)

	debug_canvas = CanvasLayer.new()
	debug_canvas.name = "DebugLayer"
	debug_canvas.layer = 50
	add_child(debug_canvas)

func _build_home():
	pond_stage = PondStageScene.instantiate()
	pond_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	world_layer.add_child(pond_stage)

	resource_hud = ResourceHudScene.instantiate()
	resource_hud.menu_pressed.connect(_open_menu_placeholder)
	hud_layer.add_child(resource_hud)

	partner_float = PartnerFloatScene.instantiate()
	partner_float.details_pressed.connect(_open_partner_details)
	dock_layer.add_child(partner_float)

	action_dock = ActionDockScene.instantiate()
	action_dock.feed_pressed.connect(_feed_selected)
	action_dock.collect_pressed.connect(_collect_idle)
	action_dock.evolve_pressed.connect(_try_evolution)
	dock_layer.add_child(action_dock)

	mode_dock = ModeDockScene.instantiate()
	mode_dock.mode_selected.connect(_select_mode)
	dock_layer.add_child(mode_dock)

	panel_host = PanelHostScene.instantiate()
	panel_host.closed.connect(_on_panel_closed)
	sheet_layer.add_child(panel_host)

	bottom_sheet = BottomSheetScene.instantiate()
	sheet_layer.add_child(bottom_sheet)

	fx_layer = FxLayerScene.instantiate()
	fx_canvas.add_child(fx_layer)

	debug_layer = DebugLayerScene.instantiate()
	debug_layer.attach(self)
	debug_canvas.add_child(debug_layer)

func _input(event):
	if debug_layer != null:
		debug_layer.record_input(event)

func _bind_controller():
	controller = GameStateController.new()
	controller.name = "GameStateController"
	add_child(controller)
	controller.state_changed.connect(_refresh_home)
	controller.fish_selected.connect(_on_fish_selected)
	controller.resources_changed.connect(_on_resources_changed)
	controller.log_added.connect(_on_log_added)
	pond_stage.fish_selected.connect(_select_fish_from_pond)
	controller.setup()

func _record_debug_event(event_id):
	if debug_layer != null:
		debug_layer.record_event(event_id)

func _select_fish_from_pond(fish_id):
	_record_debug_event("fish_selected")
	controller.select_fish(fish_id)

func _select_fish_from_dex(fish_id):
	_record_debug_event("fish_selected")
	controller.select_fish(fish_id)

func _refresh_home(_state = null):
	if controller == null or controller.state.is_empty():
		return
	pond_stage.set_game_state(controller.state, controller.active_pond_id, controller.selected_fish_id)
	resource_hud.update_view(controller.get_resources(), controller.get_active_pond_name(), controller.get_idle_rate())
	partner_float.update_fish(controller.get_selected_fish())
	_refresh_action_state()
	_refresh_active_panel()

func _on_fish_selected(fish):
	partner_float.update_fish(fish)
	pond_stage.set_game_state(controller.state, controller.active_pond_id, controller.selected_fish_id)
	pond_stage.pulse_selected()
	_refresh_action_state()

func _on_resources_changed(resources, _delta):
	resource_hud.update_view(resources, controller.get_active_pond_name(), controller.get_idle_rate())
	_refresh_action_state()

func _on_log_added(_text):
	pass

func _collect_idle():
	if collect_locked:
		return
	_record_debug_event("action")
	collect_locked = true
	var delta = controller.collect_idle_reward()
	if delta.get("reason", "") == "cooldown":
		fx_layer.show_result("还在积攒", "稍后再来收取泡泡", UiStyle.RESOURCE)
		await get_tree().create_timer(0.35).timeout
		collect_locked = false
		return
	var viewport_size = get_viewport_rect().size
	var from_pos = pond_stage.get_selected_fish_global_position()
	var to_pos = Vector2(viewport_size.x * 0.32, 64)
	fx_layer.play_water_ripple(from_pos, UiStyle.RESOURCE, 96)
	fx_layer.play_resource_fly(from_pos, to_pos, "bubbleCoins", 10)
	if delta.has("shells"):
		fx_layer.play_resource_fly(from_pos + Vector2(-18, 8), to_pos + Vector2(70, 0), "shells", 5)
	fx_layer.show_result("收取完成", _format_rewards(delta), UiStyle.ACTION_COLLECT)
	await get_tree().create_timer(0.6).timeout
	collect_locked = false

func _feed_selected():
	if feed_locked:
		return
	if bottom_sheet != null and bottom_sheet.visible:
		return
	_record_debug_event("action")
	_record_debug_event("sheet_open")
	var content = FoodSheetScene.instantiate()
	content.set_controller(controller)
	content.food_selected.connect(_feed_with_food)
	content.buy_requested.connect(_buy_food_from_sheet.bind(content))
	bottom_sheet.open_with(content, 560)

func _buy_food_from_sheet(food_id, sheet):
	var result = controller.buy_food(food_id)
	if bool(result.get("success", false)):
		var food = result.get("food", {})
		var amount = int(result.get("amount", 0))
		fx_layer.show_result("购买完成", "%s +%d · 库存 %d" % [food.get("name", "饲料"), amount, int(result.get("stock", 0))], UiStyle.RESOURCE)
	else:
		fx_layer.show_result("无法购买", _food_buy_fail_copy(str(result.get("reason", ""))), UiStyle.DISABLED)
	if sheet != null and is_instance_valid(sheet) and sheet.has_method("refresh"):
		sheet.refresh()

func _feed_with_food(food_id):
	if feed_locked:
		return
	feed_locked = true
	_record_debug_event("food")
	if bottom_sheet != null:
		bottom_sheet.close()
	var result = controller.feed_selected(food_id)
	if result.is_empty():
		feed_locked = false
		return
	if not bool(result.get("success", false)):
		fx_layer.show_result("无法投喂", _food_feed_fail_copy(str(result.get("reason", ""))), UiStyle.DISABLED)
		await get_tree().create_timer(0.35).timeout
		feed_locked = false
		return
	var food = result.get("food", {})
	var dock_rect = action_dock.get_global_rect()
	var from_pos = dock_rect.position + Vector2(dock_rect.size.x * 0.18, dock_rect.size.y * 0.5)
	var to_pos = pond_stage.get_selected_fish_global_position()
	fx_layer.play_food_throw(from_pos, to_pos, UiStyle.COST)
	fx_layer.play_water_ripple(to_pos, UiStyle.COST.lightened(0.14), 72)
	pond_stage.pulse_selected()
	if bool(result.get("overfed", false)):
		fx_layer.show_result("吃太饱了", "%s · 心情 %d" % [food.get("name", "饲料"), int(result.get("mood_delta", 0))], UiStyle.RED)
	else:
		fx_layer.show_result("投喂完成", "%s · 成长 +%s · 剩余 %d" % [food.get("name", "饲料"), int(result.get("exp_gain", food.get("exp", 0))), int(result.get("stock", 0))], UiStyle.COST)
	await get_tree().create_timer(0.45).timeout
	feed_locked = false

func _try_evolution():
	if evolution_locked:
		return
	if bottom_sheet != null and bottom_sheet.visible:
		return
	var fish = controller.get_selected_fish()
	if fish.is_empty():
		return
	_record_debug_event("action")
	_record_debug_event("sheet_open")
	var content = EvolutionSheetScene.instantiate()
	var preview = controller.calculate_evolution(fish, controller.active_pond_id, controller.selected_food_id)
	content.confirmed.connect(_confirm_evolution)
	bottom_sheet.open_with(content, 360)
	content.update_preview(fish, preview)

func _confirm_evolution():
	if evolution_locked:
		return
	_record_debug_event("evolve")
	evolution_locked = true
	action_dock.set_actions_enabled(false)
	if bottom_sheet != null:
		bottom_sheet.close()
	var result = controller.try_evolution(controller.selected_food_id)
	if result.get("reason", "") == "no_fish":
		evolution_locked = false
		action_dock.set_actions_enabled(true)
		return
	if result.get("reason", "") == "no_stock":
		fx_layer.show_result("饲料不足", "先购买当前鱼粮再进化", UiStyle.DISABLED)
		await get_tree().create_timer(0.45).timeout
		evolution_locked = false
		action_dock.set_actions_enabled(true)
		return
	if result.get("reason", "") == "max_stage":
		fx_layer.show_result("已经完全进化", "这条伙伴的形态已经稳定", UiStyle.DISABLED)
		await get_tree().create_timer(0.45).timeout
		evolution_locked = false
		action_dock.set_actions_enabled(true)
		return
	pond_stage.pulse_selected()
	var fish_pos = pond_stage.get_selected_fish_global_position()
	var chance = int(round(float(result.get("result", {}).get("chance", 0.0)) * 100.0))
	if bool(result.get("success", false)):
		fx_layer.play_screen_flash(UiStyle.CONFIRM, 0.36)
		fx_layer.play_water_ripple(fish_pos, UiStyle.CONFIRM, 148)
		fx_layer.play_resource_burst(fish_pos, Vector2(get_viewport_rect().size.x * 0.5, 160), UiStyle.CONFIRM, 16)
		fx_layer.show_result("进化成功", "%s 的新形态出现了 · %d%%" % [result.get("fish", {}).get("name", "伙伴"), chance], UiStyle.CONFIRM)
	else:
		fx_layer.play_screen_flash(UiStyle.RESOURCE, 0.22)
		fx_layer.play_water_ripple(fish_pos, UiStyle.RESOURCE, 112)
		fx_layer.show_result("形态波动", "这次没有定型，但成长已经记住了 · %d%%" % chance, UiStyle.RESOURCE)
	await get_tree().create_timer(0.85).timeout
	evolution_locked = false
	action_dock.set_actions_enabled(true)

func _food_buy_fail_copy(reason):
	return {
		"stock_full": "库存已满",
		"daily_limit": "今日购买次数用完",
		"not_enough": "资源不足",
	}.get(reason, "暂时不能购买")

func _food_feed_fail_copy(reason):
	return {
		"no_stock": "饲料库存不足",
		"too_full": "已经吃不下了",
	}.get(reason, "暂时不能投喂")

func _open_partner_details():
	_record_debug_event("sheet_open")
	var content = PartnerSheetScene.instantiate()
	content.release_requested.connect(_release_selected_from_sheet)
	bottom_sheet.open_with(content, 430)
	content.update_fish(controller.get_selected_fish())

func _open_menu_placeholder():
	if debug_layer != null:
		debug_layer.toggle()
	fx_layer.show_toast("QA 面板")

func _select_mode(mode_id):
	if debug_layer != null:
		debug_layer.set_mode(mode_id)
	if mode_dock != null:
		mode_dock.set_mode(mode_id)
	_record_debug_event("mode")
	if mode_id == "pond":
		if panel_host != null and panel_host.visible:
			panel_host.close_panel()
		return
	var content = _create_mode_panel(mode_id)
	if content == null:
		mode_dock.set_mode("pond")
		return
	if mode_dock != null:
		mode_dock.close_menu()
	_record_debug_event("panel_open")
	active_panel_content = content
	panel_host.open_panel(content, _mode_label(mode_id), mode_id)

func _create_mode_panel(mode_id):
	if mode_id == "hatchery":
		var hatchery = HatcheryPanelScene.instantiate()
		hatchery.set_controller(controller)
		hatchery.hatch_requested.connect(_hatch_from_panel)
		hatchery.buy_requested.connect(_buy_from_panel)
		return hatchery
	if mode_id == "dex":
		var dex = DexPanelScene.instantiate()
		dex.set_controller(controller)
		dex.fish_selected.connect(_select_fish_from_dex)
		dex.details_requested.connect(_open_partner_details_from_dex)
		return dex
	if mode_id == "adventure":
		var adventure = AdventureMapScene.instantiate()
		adventure.set_controller(controller)
		adventure.route_requested.connect(_run_route_from_panel)
		return adventure
	if mode_id == "quests":
		var quests = QuestBoardScene.instantiate()
		quests.set_controller(controller)
		quests.claim_requested.connect(_claim_rewards_from_panel)
		return quests
	return null

func _hatch_from_panel(slot_index := 0):
	var result = controller.hatch_fish({"slot": slot_index})
	if result.is_empty():
		return
	if not bool(result.get("success", false)):
		var reason = str(result.get("reason", ""))
		if reason == "incubating":
			fx_layer.show_result("还在孵化", _format_duration(int(result.get("remaining", 0))) + "后破壳", UiStyle.EGG)
		elif reason == "no_eggs":
			fx_layer.show_result("鱼蛋不足", "先去鱼蛋补给或远行获取", UiStyle.DISABLED)
		return
	_refresh_active_panel()
	if str(result.get("status", "")) == "started":
		var egg = result.get("egg", {})
		fx_layer.show_result("开始孵化", "%s · %s后破壳" % [egg.get("name", "鱼蛋"), _format_duration(int(result.get("remaining", 0)))], UiStyle.EGG)
		return
	var fish = result.get("fish", {})
	if fish.is_empty():
		return
	fx_layer.play_resource_burst(get_viewport_rect().size * 0.52, Vector2(get_viewport_rect().size.x * 0.5, 150), UiStyle.EGG, 12)
	var level = int(round(float(fish.get("level", 1))))
	fx_layer.show_result("孵化成功", "%s · %s Lv.%s" % [fish.get("name", "新伙伴"), fish.get("speciesName", "鱼"), level], UiStyle.rarity_color(fish.get("rarity", "common")))

func _buy_from_panel(item_id):
	var result = controller.buy_shop_item(item_id)
	if bool(result.get("success", false)):
		_refresh_active_panel()
		fx_layer.play_resource_burst(Vector2(get_viewport_rect().size.x * 0.62, get_viewport_rect().size.y * 0.45), Vector2(get_viewport_rect().size.x * 0.54, 64), UiStyle.COST, 8)

func _run_route_from_panel(route_id):
	var result = controller.run_explore(route_id)
	_refresh_active_panel()
	if not bool(result.get("success", false)):
		var reason = str(result.get("reason", ""))
		if reason == "explore_pending" or reason == "explore_busy":
			fx_layer.show_result("还在路上", _format_duration(int(result.get("remaining", 0))) + "后回来", UiStyle.RESOURCE)
		return
	if str(result.get("status", "claimed")) == "started":
		fx_layer.show_result("远行出发", "%s · %s后回来" % [result.get("route", {}).get("name", "路线"), _format_duration(int(result.get("remaining", 0)))], UiStyle.SUCCESS)
		return
	if str(result.get("status", "claimed")) == "claimed":
		_refresh_active_panel()
		fx_layer.play_resource_burst(Vector2(get_viewport_rect().size.x * 0.5, get_viewport_rect().size.y * 0.5), Vector2(get_viewport_rect().size.x * 0.34, 64), UiStyle.SUCCESS, 10)
		fx_layer.show_result("远行归来", "%s 带回 %s" % [result.get("route", {}).get("name", "路线"), _format_rewards(result.get("rewards", {}))], UiStyle.SUCCESS)

func _claim_rewards_from_panel():
	var result = controller.claim_all_rewards()
	if int(result.get("claimed", 0)) > 0:
		_refresh_active_panel()
		fx_layer.play_resource_burst(Vector2(get_viewport_rect().size.x * 0.5, get_viewport_rect().size.y * 0.36), Vector2(get_viewport_rect().size.x * 0.34, 64), UiStyle.REWARD, 12)
		fx_layer.show_result("奖励领取", _format_rewards(result.get("rewards", {})), UiStyle.REWARD)

func _open_partner_details_from_dex(_fish_id):
	_open_partner_details()

func _release_selected_from_sheet(fish_id):
	var result = controller.release_fish(fish_id)
	if not bool(result.get("success", false)):
		fx_layer.show_toast("至少保留一条伙伴")
		return
	if bottom_sheet != null:
		bottom_sheet.close()
	_refresh_active_panel()
	pond_stage.pulse_selected()
	fx_layer.show_toast("已送回海域")

func _refresh_active_panel():
	if panel_host != null and panel_host.visible:
		panel_host.refresh_content()

func _refresh_action_state():
	if action_dock == null or controller == null or controller.state.is_empty():
		return
	var fish = controller.get_selected_fish()
	var has_fish = not fish.is_empty()
	var now = int(Time.get_unix_time_from_system())
	var elapsed = max(0, now - int(controller.state.get("lastCollectAt", now)))
	var collect_ready = elapsed >= 60
	var evolution_percent = 0
	if has_fish:
		var preview = controller.calculate_evolution(fish, controller.active_pond_id, controller.selected_food_id)
		evolution_percent = int(round(float(preview.get("chance", 0.0)) * 100.0))
	action_dock.update_action_state(has_fish, collect_ready, evolution_percent)

func _on_panel_closed():
	_record_debug_event("panel_close")
	active_panel_content = null
	if mode_dock != null:
		mode_dock.set_mode("pond")
	if debug_layer != null:
		debug_layer.set_mode("pond")

func _mode_label(mode_id):
	return {
		"hatchery": "孵化",
		"dex": "图鉴",
		"adventure": "远行",
		"quests": "目标",
	}.get(mode_id, mode_id)

func _format_rewards(rewards):
	var parts = []
	for key in rewards.keys():
		parts.append("%s %s" % [GameData.resource_label(key), rewards[key]])
	return " · ".join(parts)

func _format_duration(seconds):
	var minutes = int(ceil(max(1, seconds) / 60.0))
	if minutes >= 60:
		var hours = int(floor(minutes / 60.0))
		var rest = minutes % 60
		if rest == 0:
			return "%d小时" % hours
		return "%d小时%d分" % [hours, rest]
	return "%d分钟" % minutes
