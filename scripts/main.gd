extends Control
class_name Main

# TUNING RELATED CODE START
var tuning = {}
var next_free_id 
var last_rating = [0.20, 1.54, 0.22, 0.44, 0.36, 0.42, 0.22, 0.43, 0.40, 0.10, 0.10, 0.42, 0.25, 0.42, 0.34, 0.18, 0.20, 0.10, 0.26, 0.46, 0.22, 0.30]
var last_price = [200, 2200, 0, 450, 300, 800, 100, 400, 300, 100, 100, 800, 600, 300, 0, 200, 250, 100, 350, 600, 100, 300]
var current_group : String
var active_part
var active_key
var group_delete_confirmation = false

const part_types = ["bed", "bodykit", "bodywork", "bullbars", "exhaust", "frontbumper", "headlights", "hood", "lightsbody", "louvre", "mudflaps", "rearbumper", "rollcage", "roof", "roof2", "sidemirrors", "sideskirts", "sidewindows", "sparetire", "spoiler", "taillights", "taillightsbody"]
const sample_objects = ["bed", "bodykit", "chassis_trim_", "bullbars", "Wydech", "ZderzakP", "", "Maska", "headlights", "Zalusja", "mudflaps", "ZderzakT", "cage", "RoofExtra", "roof", "sidemirrors", "Prog", "sidewindows", "sparetire", "Spoiler", "", "taillights"]

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets.visible = false
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group.visible = false
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor.visible = false
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupNamer.visible = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_Enable.visible = false
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_Disable.visible = false
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group.visible = false
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer.visible = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Delete.visible = false
	_populate_part_types_list()
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupNamer/TextEdit_GroupNamer.grab_focus()

func _save_tuning_line():
	var tuning_line = {
		"type" : $VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.get_item_text($VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.selected),
		"id" : $VBoxContainer/TabContainer/Tuning/HBoxContainer_ID/TextEdit_ID.text,
		"name" : $VBoxContainer/TabContainer/Tuning/HBoxContainer_Name/TextEdit_Name.text,
		"component" : $VBoxContainer/TabContainer/Tuning/HBoxContainer_Objects/TextEdit_Objects.text,
		"price" : $VBoxContainer/TabContainer/Tuning/HBoxContainer_Price/HBoxContainer/TextEdit_Price.text,
		"rate" : $VBoxContainer/TabContainer/Tuning/HBoxContainer_Rate/HBoxContainer/TextEdit_Rate.text,
		"imported" : false
	}
	if $VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.text == "bodykit":
		tuning_line["offset"] = Vector2($VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_Offset_X.value, $VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_Offset_Y.value)
		tuning_line["offsetF"] = Vector2($VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_OffsetF.value, $VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_OffsetR.value)
	if $VBoxContainer/TabContainer/Tuning/HBoxContainer_Lock/CheckButton.pressed:
		tuning_line["hidelocked"] = true
	else:
		tuning_line["hidelocked"] = false
	if tuning.has(current_group):
		tuning[current_group].append(tuning_line)
	else:
		tuning[current_group] = [tuning_line]
	print("Parts in current group: " + str(tuning[current_group].size() ) )
	_update_export()
	_populate_parts_list()

func _update_export():
	var group_control = []
	var carsxml : String = ""
	var tuningxml : String = ""
	for group in tuning:
		var bed = "" 
		var bodykit = "" 
		var bodywork = ""
		var bullbars = "" 
		var exhaust = ""
		var frontbumper = ""
		var headlights = ""
		var hood = ""
		var lightsbody = ""
		var louvre = "" 
		var mudflaps = "" 
		var rearbumper = ""
		var rollcage = ""
		var roof = ""
		var roof2 = "" 
		var sidemirrors = "" 
		var sideskirts = "" 
		var sidewindows = "" 
		var sparetire = ""
		var spoiler = "" 
		var taillights = ""
		var taillightsbody = ""
		for array in tuning[group]:
			print("array size= " + str(array.size()) + "\ntype= " + str(array["type"]))
			if not array["imported"]:
				if not group_control.has(group):
					group_control.append(group)
				match array["type"]:
					"bed":
						bed += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							bed += "%c	hidelocked=%ctrue" % [034, 034]
						bed += "%c/>\n" % [034]
						#print("bed= " + bed)
					"bodykit":
						if array["offsetF"]:
							bodykit += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	offset=%c" % [034, 034] + str(array["offset"][0]) + " " + str(array["offset"][1]) + "%c	offsetF=%c" % [034, 034] + str(array["offsetF"][0]) + " " + str(array["offsetF"][1]) + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						else:
							bodykit += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	offset=%c" % [034, 034] + str(array["offset"][0]) + " " + str(array["offset"][1]) + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							bodykit += "%c	hidelocked=%ctrue" % [034, 034]
						bodykit += "%c/>\n" % [034]
					"bodywork":
						bodywork += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							bodywork += "%c	hidelocked=%ctrue" % [034, 034]
						bodywork += "%c/>\n" % [034]
					"bullbars":
						bullbars += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							bullbars += "%c	hidelocked=%ctrue" % [034, 034]
						bullbars += "%c/>\n" % [034]
					"exhaust":
						exhaust += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							exhaust += "%c	hidelocked=%ctrue" % [034, 034]
						exhaust += "%c/>\n" % [034]
					"frontbumper":
						frontbumper += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							frontbumper += "%c	hidelocked=%ctrue" % [034, 034]
						frontbumper += "%c/>\n" % [034]
					"headlights":
						headlights += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	data=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							headlights += "%c	hidelocked=%ctrue" % [034, 034]
						headlights += "%c/>\n" % [034]
					"hood":
						hood += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							hood += "%c	hidelocked=%ctrue" % [034, 034]
						hood += "%c/>\n" % [034]
					"lightsbody":
						lightsbody += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							lightsbody += "%c	hidelocked=%ctrue" % [034, 034]
						lightsbody += "%c/>\n" % [034]
					"louvre":
						louvre += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							louvre += "%c	hidelocked=%ctrue" % [034, 034]
						louvre += "%c/>\n" % [034]
					"mudflaps":
						mudflaps += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							mudflaps += "%c	hidelocked=%ctrue" % [034, 034]
						mudflaps += "%c/>\n" % [034]
					"rearbumper":
						rearbumper += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							rearbumper += "%c	hidelocked=%ctrue" % [034, 034]
						rearbumper += "%c/>\n" % [034]
					"rollcage":
						rollcage += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							rollcage += "%c	hidelocked=%ctrue" % [034, 034]
						rollcage += "%c/>\n" % [034]
					"roof":
						roof += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							roof += "%c	hidelocked=%ctrue" % [034, 034]
						roof += "%c/>\n" % [034]
					"roof2":
						roof2 += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							roof2 += "%c	hidelocked=%ctrue" % [034, 034]
						roof2 += "%c/>\n" % [034]
					"sidemirrors":
						sidemirrors += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							sidemirrors += "%c	hidelocked=%ctrue" % [034, 034]
						sidemirrors += "%c/>\n" % [034]
					"sideskirts":
						sideskirts += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							sideskirts += "%c	hidelocked=%ctrue" % [034, 034]
						sideskirts += "%c/>\n" % [034]
					"sidewindows":
						sidewindows += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							sidewindows += "%c	hidelocked=%ctrue" % [034, 034]
						sidewindows += "%c/>\n" % [034]
					"sparetire":
						sparetire += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							sparetire += "%c	hidelocked=%ctrue" % [034, 034]
						sparetire += "%c/>\n" % [034]
					"spoiler":
						spoiler += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"] 
						if array["hidelocked"]:
							spoiler += "%c	hidelocked=%ctrue" % [034, 034]
						spoiler += "%c/>\n" % [034]
					"taillights":
						taillights += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	data=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							taillights += "%c	hidelocked=%ctrue" % [034, 034]
						taillights += "%c/>\n" % [034]
					"taillightsbody":
						taillightsbody += "		<part id=%c" % [034] + array["id"] + "%c	name=%c" % [034, 034] + array["name"] + "%c	component=%c" % [034, 034] + array["component"] + "%c	price=%c" % [034, 034] + array["price"] + "%c	rate=%c" % [034, 034] + array["rate"]
						if array["hidelocked"]:
							taillightsbody += "%c	hidelocked=%ctrue" % [034, 034]
						taillightsbody += "%c/>\n" % [034]
		if bed:
			bed = "	<group name=%c" % [034] + group + "%c type=%cbed%c>\n" % [034, 034, 034] + bed + "	</group>\n"
		if bodykit:
			bodykit = "	<group name=%c" % [034] + group + "%c type=%cbodykit%c>\n" % [034, 034, 034] + bodykit + "	</group>\n"
		if bodywork:
			bodywork = "	<group name=%c" % [034] + group + "%c type=%cbodywork%c>\n" % [034, 034, 034] + bodywork + "	</group>\n"
		if bullbars:
			bullbars = "	<group name=%c" % [034] + group + "%c type=%cbullbars%c>\n" % [034, 034, 034] + bullbars + "	</group>\n"
		if exhaust:
			exhaust = "	<group name=%c" % [034] + group + "%c type=%cexhaust%c>\n" % [034, 034, 034] + exhaust + "	</group>\n" 
		if frontbumper:
			frontbumper = "	<group name=%c" % [034] + group + "%c type=%cfrontbumper%c>\n" % [034, 034, 034] + frontbumper + "	</group>\n" 
		if headlights:
			headlights = "	<group name=%c" % [034] + group + "%c type=%cheadlights%c>\n" % [034, 034, 034] + headlights + "	</group>\n"
		if hood:
			hood = "	<group name=%c" % [034] + group + "%c type=%chood%c>\n" % [034, 034, 034] + hood + "	</group>\n"
		if lightsbody:
			lightsbody = "	<group name=%c" % [034] + group + "%c type=%clightsbody%c>\n" % [034, 034, 034] + lightsbody + "	</group>\n"
		if louvre:
			louvre = "	<group name=%c" % [034] + group + "%c type=%clouvre%c>\n" % [034, 034, 034] + louvre + "	</group>\n"
		if mudflaps:
			mudflaps = "	<group name=%c" % [034] + group + "%c type=%cmudflaps%c>\n" % [034, 034, 034] + mudflaps + "	</group>\n"
		if rearbumper:
			rearbumper = "	<group name=%c" % [034] + group + "%c type=%crearbumper%c>\n" % [034, 034, 034] + rearbumper + "	</group>\n"
		if rollcage:
			rollcage = "	<group name=%c" % [034] + group + "%c type=%crollcage%c>\n" % [034, 034, 034] + rollcage + "	</group>\n"
		if roof:
			roof = "	<group name=%c" % [034] + group + "%c type=%croof%c>\n" % [034, 034, 034] + roof + "	</group>\n" 
		if roof2:
			roof2 = "	<group name=%c" % [034] + group + "%c type=%croof2%c>\n" % [034, 034, 034] + roof2 + "	</group>\n" 
		if sidemirrors:
			sidemirrors = "	<group name=%c" % [034] + group + "%c type=%csidemirrors%c>\n" % [034, 034, 034] + sidemirrors + "	</group>\n"
		if sideskirts:
			sideskirts = "	<group name=%c" % [034] + group + "%c type=%csideskirts%c>\n" % [034, 034, 034] + sideskirts + "	</group>\n"
		if sidewindows:
			sidewindows = "	<group name=%c" % [034] + group + "%c type=%csidewindows%c>\n" % [034, 034, 034] + sidewindows + "	</group>\n"
		if sparetire:
			sparetire = "	<group name=%c" % [034] + group + "%c type=%csparetire%c>\n" % [034, 034, 034] + sparetire + "	</group>\n"
		if spoiler:
			spoiler = "	<group name=%c" % [034] + group + "%c type=%cspoiler%c>\n" % [034, 034, 034] + spoiler + "	</group>\n"
		if taillights:
			taillights = "	<group name=%c" % [034] + group + "%c type=%ctaillights%c>\n" % [034, 034, 034] + taillights + "	</group>\n"
		if taillightsbody:
			taillightsbody = "	<group name=%c" % [034] + group + "%c type=%ctaillightsbody%c>\n" % [034, 034, 034] + taillightsbody + "	</group>\n"
		tuningxml += bed + bodykit + bodywork + bullbars + exhaust + frontbumper + headlights + hood + lightsbody + louvre + mudflaps + rearbumper + rollcage + roof + roof2 + sidemirrors + sideskirts + sidewindows + sparetire + spoiler + taillights + taillightsbody
		#print("tuningxml= " + tuningxml)
	$VBoxContainer/TabContainer/Export/HBoxContainer_Tuning/Export_Tuning.text = tuningxml
	for group in tuning:
		if group_control.has(group):
			carsxml += "		<tuning group=%c" % [034] + group + "%c/>\n" % [034]
	$VBoxContainer/TabContainer/Export/HBoxContainer_Cars/Export_Cars.text = carsxml
	_export_conditionals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_OptionButton_Type_item_selected(index):
	get_node("VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets").visible = false
	if not $VBoxContainer/TabContainer/Tuning/HBoxContainer_Price/HBoxContainer/TextEdit_Price.text:
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Price/HBoxContainer/TextEdit_Price.text = str(last_price[index])
	if not $VBoxContainer/TabContainer/Tuning/HBoxContainer_Rate/HBoxContainer/TextEdit_Rate.text:
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Rate/HBoxContainer/TextEdit_Rate.text = str(last_rating[index])
	if not $VBoxContainer/TabContainer/Tuning/HBoxContainer_Objects/TextEdit_Objects.text or sample_objects.has($VBoxContainer/TabContainer/Tuning/HBoxContainer_Objects/TextEdit_Objects.text):
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Objects/TextEdit_Objects.text = sample_objects[index]
	match $VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.get_item_text(index): 
		"bodykit":
			get_node("VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets").visible = true

func _alphabetize(options_button):
	# Have a dictionary hold all of the necessary information. Assign the text strings as keys. Note that the text strings *must* be unique from the other items.
	var unorganized_items: Dictionary = {}

	for item_number in options_button.get_item_count():
		# Get all of the information for each item.
		var text: String = options_button.get_item_text( item_number )
		var id: int = options_button.get_item_id( item_number )
		# Put them into our dictionary.
		unorganized_items[text] = id
	# Clear out the options button so that we can put in our sorted list.
	options_button.clear()
	# Populate our options button with the newly alphabetized list.
	var sorted_keys: Array = unorganized_items.keys()
	# For some odd reason, this method has to be done separately.
	sorted_keys.sort()
	# Go through the sorted keys and add the new items to our options button.
	for text in sorted_keys:
		options_button.add_item( text , unorganized_items[text] )

func _populate_part_types_list():
	for i in part_types:
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.add_item(i)

func _populate_parts_list():
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/OptionButton_Part.clear()
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group1/VSplitContainer_Group1/ItemList_Group1.clear()
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group2/VSplitContainer_Group2/ItemList_Group2.clear()
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/VSplitContainer_Group3/ItemList_Group3.clear()
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/VSplitContainer_Group4/ItemList_Group4.clear()
	if tuning.has(current_group):
		for array in tuning[current_group]:
			var part = array["type"] + " " + array["id"] + " " + array["name"] + " $" + array["price"] + " *" + array["rate"]
			$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/OptionButton_Part.add_item(part)
		for group in tuning:
			for array in tuning[group]:
				var part = array["type"] + " " + array["id"] + " " + array["name"] + " " + array["component"]
				$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group1/VSplitContainer_Group1/ItemList_Group1.add_item(part)
				$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group2/VSplitContainer_Group2/ItemList_Group2.add_item(part)
				$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/VSplitContainer_Group3/ItemList_Group3.add_item(part)
				$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/VSplitContainer_Group4/ItemList_Group4.add_item(part)
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/OptionButton_Part.select(-1)
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group1/VSplitContainer_Group1/ItemList_Group1.sort_items_by_text()
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group2/VSplitContainer_Group2/ItemList_Group2.sort_items_by_text()
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/VSplitContainer_Group3/ItemList_Group3.sort_items_by_text()
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/VSplitContainer_Group4/ItemList_Group4.sort_items_by_text()

func _does_id_exist(id_to_check):
	var found = false
	for group in tuning:
		for array in tuning[group]:
			match array["id"]:
				id_to_check:
					found = true
	return found

func _on_Button_GetLastPrice_pressed():
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Price/HBoxContainer/TextEdit_Price.text = str(last_price[$VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.get_selected_id()])

func _on_Button_GetLastRating_pressed():
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Rate/HBoxContainer/TextEdit_Rate.text = str(last_rating[$VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.get_selected_id()])

func _on_Button_PartSave_pressed():
	next_free_id = str(int($VBoxContainer/TabContainer/Tuning/HBoxContainer_ID/TextEdit_ID.text) + 1)
	if _does_id_exist($VBoxContainer/TabContainer/Tuning/HBoxContainer_ID/TextEdit_ID.text):
		while _does_id_exist(next_free_id):
			next_free_id = str(int(next_free_id) + 1)
			if int(next_free_id) >= int($VBoxContainer/TabContainer/Tuning/HBoxContainer_ID/TextEdit_ID.text) + 100:
				$PopupPanel_IDinUse/CenterContainer/VBoxContainer/Button_NextID.visible = false
				next_free_id = false
				break
		if next_free_id:
			$PopupPanel_IDinUse/CenterContainer/VBoxContainer/Label_IDinUse.text = "ID " + $VBoxContainer/TabContainer/Tuning/HBoxContainer_ID/TextEdit_ID.text + " was already assigned.\nDid not save this entry.\n\nThe next free ID is " + next_free_id + "."
			$PopupPanel_IDinUse/CenterContainer/VBoxContainer/Button_NextID.visible = true
		$PopupPanel_IDinUse.visible = true
	else:
		_save_tuning_line()
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_ID/TextEdit_ID.text = next_free_id
		last_price[$VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.get_selected_id()] = int($VBoxContainer/TabContainer/Tuning/HBoxContainer_Price/HBoxContainer/TextEdit_Price.text)
		last_rating[$VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.get_selected_id()] = float($VBoxContainer/TabContainer/Tuning/HBoxContainer_Rate/HBoxContainer/TextEdit_Rate.text)
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Revert.disabled = true
		active_part = null

func _on_IDinUse_Button_Cancel_pressed():
	$PopupPanel_IDinUse.visible = false

func _on_IDinUse_Button_NextID_pressed():
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_ID/TextEdit_ID.text = next_free_id
	$PopupPanel_IDinUse.visible = false
	_on_Button_PartSave_pressed()

func _on_GroupNamer_Button_Save_pressed():
	if $VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupNamer/TextEdit_GroupNamer.text:
		current_group = $VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupNamer/TextEdit_GroupNamer.text
		var entries = $VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.get_item_count()
		print("Number of saved groups: " + str(entries))
		var save_entry = true
		for entry in range(entries):
			var entry_name = $VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.get_item_text(entry)
			print("Group found: " + entry_name + " (at index: " + str(entry) + " )")
			if entry_name == current_group:
				save_entry = false
				print("That group name already exists.")
		if save_entry:
			$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.add_item(current_group)
			$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.select(entries)
			print("New group " + current_group + " saved.")
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Clear.disabled = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Save.disabled = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupNamer.visible = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group.visible = true
		_populate_parts_list()
	else:
		pass

func _on_Group_Button_New_pressed():
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupNamer/TextEdit_GroupNamer.text = ""
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupNamer.visible = true
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group.visible = false
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Clear.disabled = true
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Save.disabled = true
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupNamer/TextEdit_GroupNamer.grab_focus()

func _on_Group_Button_Edit_pressed():
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/TextEdit_GroupEditor.text = current_group
	if tuning.has(current_group):
		active_key = tuning[current_group]
		tuning.erase(current_group) 
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor.visible = true
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group.visible = false
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Clear.disabled = true
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Save.disabled = true
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor.grab_focus()
	
func _on_GroupEditor_Button_Save_pressed():
	if $VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/TextEdit_GroupEditor.text:
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/Button_Save.text = " Save "
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/Button_Delete.text = " X "
		var new_key_name = $VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/TextEdit_GroupEditor.text
		if active_key:
			tuning[new_key_name] = active_key
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.set_item_text($VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.get_selected_id(), new_key_name)
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Clear.disabled = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Save.disabled = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor.visible = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group.visible = true
		current_group = new_key_name
		_update_export()
		active_key = null
	else:
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/TextEdit_GroupEditor.text = current_group

func _on_OptionButton_Group_item_selected(index):
	current_group = $VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.get_item_text(index)
	_populate_parts_list()

func _on_GroupEditor_Button_Delete_pressed():
	if group_delete_confirmation:
		active_key = null
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.remove_item($VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.get_selected_id())
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.select(0)
		current_group = $VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.get_item_text(0)
		_update_export()
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Clear.disabled = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Save.disabled = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor.visible = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group.visible = true
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/Button_Save.text = " Save "
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/Button_Delete.text = " X "
		group_delete_confirmation = false
	else:
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/Button_Delete.text = "Delete the whole group"
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupEditor/Button_Save.text = "Wait, what?"
		group_delete_confirmation = true

func _on_Part_Button_Clear_pressed():
	if $VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/OptionButton_Part.get_selected_id() == -1:
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_ID/TextEdit_ID.text = ""
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Name/TextEdit_Name.text = ""
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Objects/TextEdit_Objects.text = ""
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_Offset_X.value = 0
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_Offset_Y.value = 0
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_OffsetF.value = 0
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_OffsetR.value = 0
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Price/HBoxContainer/TextEdit_Price.text = ""
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Rate/HBoxContainer/TextEdit_Rate.text = ""
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Lock/CheckButton.pressed = false

func _on_OptionButton_Part_item_selected(index):
	active_part = tuning[current_group][index]
	_retrieve_active_part()
	tuning[current_group].remove(index)
	_populate_parts_list()
	_update_export()
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Revert.disabled = false

func _on_Part_Button_Revert_pressed():
	_retrieve_active_part()

func _retrieve_active_part():
	var counter = 0
	for part in part_types:
		if part == active_part["type"]:
			$VBoxContainer/TabContainer/Tuning/HBoxContainer_Type/OptionButton_Type.selected = counter
			break
		counter += 1
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_ID/TextEdit_ID.text = active_part["id"]
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Name/TextEdit_Name.text = active_part["name"]
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Objects/TextEdit_Objects.text = active_part["component"]
	if active_part.has("offset"):
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_Offset_X.value = active_part["offset"][0]
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_Offset_Y.value = active_part["offset"][1]
	if active_part.has("offsetF"):
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_OffsetF.value = active_part["offsetF"][0]
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Offsets/SpinBox_OffsetR.value = active_part["offsetF"][1]
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Price/HBoxContainer/TextEdit_Price.text = active_part["price"]
	$VBoxContainer/TabContainer/Tuning/HBoxContainer_Rate/HBoxContainer/TextEdit_Rate.text = active_part["rate"]

# CONDITIONALS RELATED CODE START
var conditional = {}
var current_conditional : String
var active_set 
var conditional_delete_confirmation = true

func _generate_conditionals():
	var group1 = $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group1/VSplitContainer_Group1/TextEdit_Group1.text.split(" ")
	var group2 = $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group2/VSplitContainer_Group2/TextEdit_Group2.text.split(" ")
	var group3 = $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/VSplitContainer_Group3/TextEdit_Group3.text.split(" ")
	var group4 = $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/VSplitContainer_Group4/TextEdit_Group4.text.split(" ")
	var enable_prefix = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnablePrefix/TextEdit_EnablePrefix.text.split(" ")
	var enable_suffix = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnableSuffix/TextEdit_EnableSuffix.text.split(" ")
	var disable_prefix = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisablePrefix/TextEdit_DisablePrefix.text.split(" ")
	var disable_suffix = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisableSuffix/TextEdit_DisableSuffix.text.split(" ")
	var standard_set = $VBoxContainer/TabContainer/Conditionals/VBoxContainer_StandardSet/TextEdit_Set.text
	var standard_enable = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_Enable/TextEdit_Enable.text
	var standard_disable = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_Disable/TextEdit_Disable.text
	var conditions = []
	if $VBoxContainer/TabContainer/Conditionals/VBoxContainer_StandardSet.visible:
		var condition = {
			"set" : standard_set,
			"enable" : standard_enable,
			"disable" : standard_disable,
			"imported" : false,
			"comment" : active_set["comment"]
		}
		conditions.append(condition)
	else:
		if not $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/CheckBox_Group3.pressed and not $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/CheckBox_Group4.pressed:
			for id1 in group1:
				if id1:
					for id2 in group2:
						if id2:
							var set = str(id1) + " " + str(id2)
							var disable = ""
							var enable = ""
							var comment = ""
							for group in tuning:
								for array in tuning[group]:
									match array["id"]:
										id1:
											var objects = array["component"].split(" ")
											for prefix in enable_prefix:
												if prefix:
													for object in objects:
														if object.begins_with(prefix):
															if enable:
																enable += " " + object
															else:
																enable += object
											for suffix in enable_suffix:
												if suffix:
													for object in objects:
														if object.ends_with(suffix):
															if enable:
																enable += " " + object
															else:
																enable += object
															if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																if disable:
																	disable += " " + object.trim_suffix(suffix)
																else:
																	disable += object.trim_suffix(suffix)
											for prefix in disable_prefix:
												if prefix:
													for object in objects:
														if object.begins_with(prefix):
															if disable:
																disable += " " + object
															else:
																disable += object
											for suffix in disable_suffix:
												if suffix:
													for object in objects:
														if object.ends_with(suffix):
															if disable:
																disable += " " + object
															else:
																disable += object
															if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																if enable:
																	enable += " " + object.trim_suffix(suffix)
																else:
																	enable += object.trim_suffix(suffix)
											comment += array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
										id2:
											var objects = array["component"].split(" ")
											for prefix in enable_prefix:
												if prefix:
													for object in objects:
														if object.begins_with(prefix):
															if enable:
																enable += " " + object
															else:
																enable += object
											for suffix in enable_suffix:
												if suffix:
													for object in objects:
														if object.ends_with(suffix):
															if enable:
																enable += " " + object
															else:
																enable += object
															if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																if disable:
																	disable += " " + object.trim_suffix(suffix)
																else:
																	disable += object.trim_suffix(suffix)
											for prefix in disable_prefix:
												if prefix:
													for object in objects:
														if object.begins_with(prefix):
															if disable:
																disable += " " + object
															else:
																disable += object
											for suffix in disable_suffix:
												if suffix:
													for object in objects:
														if object.ends_with(suffix):
															if disable:
																disable += " " + object
															else:
																disable += object
															if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																if enable:
																	enable += " " + object.trim_suffix(suffix)
																else:
																	enable += object.trim_suffix(suffix)
											comment += " + " + array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
							var condition = {"set" : set, "enable" : enable, "disable" : disable, "comment" : comment, "imported" : false}
							conditions.append(condition)
		elif $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/CheckBox_Group3.pressed and not $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/CheckBox_Group4.pressed:
			for id1 in group1:
				if id1:
					for id2 in group2:
						if id2:
							for id3 in group3:
								if id3:
									var set = str(id1) + " " + str(id2) + " " + str(id3)
									var disable = ""
									var enable = ""
									var comment = ""
									for group in tuning:
										for array in tuning[group]:
											match array["id"]:
												id1:
													var objects = array["component"].split(" ")
													for prefix in enable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
													for suffix in enable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
																	if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																		if disable:
																			disable += " " + object.trim_suffix(suffix)
																		else:
																			disable += object.trim_suffix(suffix)
													for prefix in disable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
													for suffix in disable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
																	if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																		if enable:
																			enable += " " + object.trim_suffix(suffix)
																		else:
																			enable += object.trim_suffix(suffix)
													comment += array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
												id2:
													var objects = array["component"].split(" ")
													for prefix in enable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
													for suffix in enable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
																	if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																		if disable:
																			disable += " " + object.trim_suffix(suffix)
																		else:
																			disable += object.trim_suffix(suffix)
													for prefix in disable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
													for suffix in disable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
																	if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																		if enable:
																			enable += " " + object.trim_suffix(suffix)
																		else:
																			enable += object.trim_suffix(suffix)
													comment += " + " + array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
												id3:
													var objects = array["component"].split(" ")
													for prefix in enable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
													for suffix in enable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
																	if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																		if disable:
																			disable += " " + object.trim_suffix(suffix)
																		else:
																			disable += object.trim_suffix(suffix)
													for prefix in disable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
													for suffix in disable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
																	if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																		if enable:
																			enable += " " + object.trim_suffix(suffix)
																		else:
																			enable += object.trim_suffix(suffix)
													comment += " + " + array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
									var condition = {"set" : set, "enable" : enable, "disable" : disable, "comment" : comment}
									conditions.append(condition)
		elif not $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/CheckBox_Group3.pressed and $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/CheckBox_Group4.pressed:
			for id1 in group1:
				if id1:
					for id2 in group2:
						if id2:
							for id4 in group4:
								if id4:
									var set = str(id1) + " " + str(id2) + " " + str(id4)
									var disable = ""
									var enable = ""
									var comment = ""
									for group in tuning:
										for array in tuning[group]:
											match array["id"]:
												id1:
													var objects = array["component"].split(" ")
													for prefix in enable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
													for suffix in enable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
																	if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																		if disable:
																			disable += " " + object.trim_suffix(suffix)
																		else:
																			disable += object.trim_suffix(suffix)
													for prefix in disable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
													for suffix in disable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
																	if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																		if enable:
																			enable += " " + object.trim_suffix(suffix)
																		else:
																			enable += object.trim_suffix(suffix)
													comment += array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
												id2:
													var objects = array["component"].split(" ")
													for prefix in enable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
													for suffix in enable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
																	if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																		if disable:
																			disable += " " + object.trim_suffix(suffix)
																		else:
																			disable += object.trim_suffix(suffix)
													for prefix in disable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
													for suffix in disable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
																	if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																		if enable:
																			enable += " " + object.trim_suffix(suffix)
																		else:
																			enable += object.trim_suffix(suffix)
													comment += " + " + array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
												id4:
													var objects = array["component"].split(" ")
													for prefix in enable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
													for suffix in enable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if enable:
																		enable += " " + object
																	else:
																		enable += object
																	if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																		if disable:
																			disable += " " + object.trim_suffix(suffix)
																		else:
																			disable += object.trim_suffix(suffix)
													for prefix in disable_prefix:
														if prefix:
															for object in objects:
																if object.begins_with(prefix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
													for suffix in disable_suffix:
														if suffix:
															for object in objects:
																if object.ends_with(suffix):
																	if disable:
																		disable += " " + object
																	else:
																		disable += object
																	if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																		if enable:
																			enable += " " + object.trim_suffix(suffix)
																		else:
																			enable += object.trim_suffix(suffix)
													comment += " + " + array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
									var condition = {"set" : set, "enable" : enable, "disable" : disable, "comment" : comment}
									conditions.append(condition)
		elif $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/CheckBox_Group3.pressed and $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/CheckBox_Group4.pressed:
			for id1 in group1:
				if id1:
					for id2 in group2:
						if id2:
							for id3 in group3:
								if id3:
									for id4 in group4:
										if id4:
											var set = str(id1) + " " + str(id2) + " " + str(id3) + " " + str(id4)
											var disable = ""
											var enable = ""
											var comment = ""
											for group in tuning:
												for array in tuning[group]:
													match array["id"]:
														id1:
															var objects = array["component"].split(" ")
															for prefix in enable_prefix:
																if prefix:
																	for object in objects:
																		if object.begins_with(prefix):
																			if enable:
																				enable += " " + object
																			else:
																				enable += object
															for suffix in enable_suffix:
																if suffix:
																	for object in objects:
																		if object.ends_with(suffix):
																			if enable:
																				enable += " " + object
																			else:
																				enable += object
																			if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																				if disable:
																					disable += " " + object.trim_suffix(suffix)
																				else:
																					disable += object.trim_suffix(suffix)
															for prefix in disable_prefix:
																if prefix:
																	for object in objects:
																		if object.begins_with(prefix):
																			if disable:
																				disable += " " + object
																			else:
																				disable += object
															for suffix in disable_suffix:
																if suffix:
																	for object in objects:
																		if object.ends_with(suffix):
																			if disable:
																				disable += " " + object
																			else:
																				disable += object
																			if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																				if enable:
																					enable += " " + object.trim_suffix(suffix)
																				else:
																					enable += object.trim_suffix(suffix)
															comment += array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
														id2:
															var objects = array["component"].split(" ")
															for prefix in enable_prefix:
																if prefix:
																	for object in objects:
																		if object.begins_with(prefix):
																			if enable:
																				enable += " " + object
																			else:
																				enable += object
															for suffix in enable_suffix:
																if suffix:
																	for object in objects:
																		if object.ends_with(suffix):
																			if enable:
																				enable += " " + object
																			else:
																				enable += object
																			if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																				if disable:
																					disable += " " + object.trim_suffix(suffix)
																				else:
																					disable += object.trim_suffix(suffix)
															for prefix in disable_prefix:
																if prefix:
																	for object in objects:
																		if object.begins_with(prefix):
																			if disable:
																				disable += " " + object
																			else:
																				disable += object
															for suffix in disable_suffix:
																if suffix:
																	for object in objects:
																		if object.ends_with(suffix):
																			if disable:
																				disable += " " + object
																			else:
																				disable += object
																			if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																				if enable:
																					enable += " " + object.trim_suffix(suffix)
																				else:
																					enable += object.trim_suffix(suffix)
															comment += " + " + array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
														id3:
															var objects = array["component"].split(" ")
															for prefix in enable_prefix:
																if prefix:
																	for object in objects:
																		if object.begins_with(prefix):
																			if enable:
																				enable += " " + object
																			else:
																				enable += object
															for suffix in enable_suffix:
																if suffix:
																	for object in objects:
																		if object.ends_with(suffix):
																			if enable:
																				enable += " " + object
																			else:
																				enable += object
																			if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																				if disable:
																					disable += " " + object.trim_suffix(suffix)
																				else:
																					disable += object.trim_suffix(suffix)
															for prefix in disable_prefix:
																if prefix:
																	for object in objects:
																		if object.begins_with(prefix):
																			if disable:
																				disable += " " + object
																			else:
																				disable += object
															for suffix in disable_suffix:
																if suffix:
																	for object in objects:
																		if object.ends_with(suffix):
																			if disable:
																				disable += " " + object
																			else:
																				disable += object
																			if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																				if enable:
																					enable += " " + object.trim_suffix(suffix)
																				else:
																					enable += object.trim_suffix(suffix)
															comment += " + " + array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
														id4:
															var objects = array["component"].split(" ")
															for prefix in enable_prefix:
																if prefix:
																	for object in objects:
																		if object.begins_with(prefix):
																			if enable:
																				enable += " " + object
																			else:
																				enable += object
															for suffix in enable_suffix:
																if suffix:
																	for object in objects:
																		if object.ends_with(suffix):
																			if enable:
																				enable += " " + object
																			else:
																				enable += object
																			if not object.trim_suffix(suffix) + " " in disable and not disable.ends_with(object.trim_suffix(suffix)):
																				if disable:
																					disable += " " + object.trim_suffix(suffix)
																				else:
																					disable += object.trim_suffix(suffix)
															for prefix in disable_prefix:
																if prefix:
																	for object in objects:
																		if object.begins_with(prefix):
																			if disable:
																				disable += " " + object
																			else:
																				disable += object
															for suffix in disable_suffix:
																if suffix:
																	for object in objects:
																		if object.ends_with(suffix):
																			if disable:
																				disable += " " + object
																			else:
																				disable += object
																			if not object.trim_suffix(suffix) + " " in enable and not enable.ends_with(object.trim_suffix(suffix)):
																				if enable:
																					enable += " " + object.trim_suffix(suffix)
																				else:
																					enable += object.trim_suffix(suffix)
															comment += " + " + array["type"] + " " + array["name"] + " (" + array["component"] + ")" 
											var condition = {"set" : set, "enable" : enable, "disable" : disable, "comment" : comment}
											conditions.append(condition) 
	if conditional.has(current_conditional):
		conditional[current_conditional].append_array(conditions)
	else:
		conditional[current_conditional] = conditions
	print("Conditionals in current group: " + str(conditional[current_conditional].size() ) )

func _populate_sets():
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/OptionButton_Set.clear()
	for array in conditional[current_conditional]:
		var set = array["set"]
		if array["enable"]:
			set += "; + " + array["enable"]
		if array["disable"]:
			set += "; - " + array["disable"]
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/OptionButton_Set.add_item(set)
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/OptionButton_Set.select(-1)

func _export_conditionals():
	var import_control = []
	var tuningxml = ""
	for group in conditional:
		var tuning_group = "\n	<conditional name=%c" % [034] + group + "%c>\n" % [034]
		for array in conditional[group]:
			if not array["imported"]:
				if not import_control.has(group):
					import_control.append(group)
				tuning_group += "		<condition	set=%c" % [034] + array["set"] + "%c	enable=%c" % [034, 034] + array["enable"] + "%c	disable=%c" % [034, 034] + array["disable"] + "%c/>" % [034] + "	<!--" + array["comment"] + "-->\n"
		tuning_group += "	</conditional>"
		if import_control.has(group):
			tuningxml += tuning_group
	var carsxml = ""
	for group in conditional:
		if import_control.has(group):
			carsxml += "\n		<tuning conditional=%c" % [034] + group + "%c/>" % [034]
	if carsxml:
		$VBoxContainer/TabContainer/Export/HBoxContainer_Cars/Export_Cars.text += carsxml
		$VBoxContainer/TabContainer/Export/HBoxContainer_Tuning/Export_Tuning.text += tuningxml
 
# A reminder that it works the same way as Python:
func _separate_string_by_spaces(string : String):
	var array = string.split(" ")
	return array

func _on_ConditionalsNamer_Button_Save_pressed():
	if $VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/TextEdit_GroupNamer.text:
		if active_set:
			$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Save.text = " Save "
			$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Delete.text = " X "
			var new_key_name = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/TextEdit_GroupNamer.text
			if active_set:
				tuning[new_key_name] = active_set
			$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.set_item_text($VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.get_selected_id(), new_key_name)
			current_conditional = new_key_name
			_update_export()
			active_set = null
		else:
			current_conditional = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/TextEdit_GroupNamer.text
			var entries = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.get_item_count()
			print("Number of saved conditionals: " + str(entries))
			var save_entry = true
			for entry in range(entries):
				var entry_name = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.get_item_text(entry)
				print("Conditional found: " + entry_name + " (at index: " + str(entry) + " )")
				if entry_name == current_conditional:
					save_entry = false
					print("That conditional name already exists.")
			if save_entry:
				$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.add_item(current_conditional)
				$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.select(entries)
				print("New conditional " + current_conditional + " saved.")
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Clear.disabled = false
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Save.disabled = false
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer.visible = false
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group.visible = true
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Save.text = " Save "
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Delete.visible = true
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Delete.text = " X "
	else:
		if current_conditional:
			$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/TextEdit_GroupNamer.text = current_conditional

func _add_id_to_set(index : int, itemlistgroup, texteditgroup):
	var selection = itemlistgroup.get_item_text(index).get_slice(" ", 1)
	texteditgroup.text += " " + selection

func _on_PartsList_Group1_item_selected(index):
	_add_id_to_set(index, $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group1/VSplitContainer_Group1/ItemList_Group1, $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group1/VSplitContainer_Group1/TextEdit_Group1)

func _on_Conditionals_Button_New_pressed():
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/TextEdit_GroupNamer.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer.visible = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group.visible = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Clear.disabled = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Save.disabled = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/TextEdit_GroupNamer.grab_focus()

func _on_Conditionals_Button_Edit_pressed():
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/TextEdit_GroupNamer.text = current_conditional
	if conditional.has(current_conditional):
		active_set = tuning[current_conditional]
		conditional.erase(current_conditional) 
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer.visible = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group.visible = false
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Clear.disabled = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Save.disabled = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/TextEdit_GroupNamer.grab_focus()

func _on_Conditional_Button_Delete_pressed():
	if conditional_delete_confirmation:
		active_set = null
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.remove_item($VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.get_selected_id())
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.select(0)
		current_conditional = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.get_item_text(0)
		_update_export()
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Clear.disabled = false
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Save.disabled = false
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer.visible = false
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group.visible = true
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Save.text = " Save "
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Delete.text = " X "
		conditional_delete_confirmation = false
	else:
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Delete.text = "YEET!"
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer/Button_Save.text = "OH GOD NO"
		conditional_delete_confirmation = true

func _on_ConditionalSet_Button_Clear_pressed():
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group1/VSplitContainer_Group1/TextEdit_Group1.text = ""
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group2/VSplitContainer_Group2/TextEdit_Group2.text = ""
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/VSplitContainer_Group3/TextEdit_Group3.text = ""
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/VSplitContainer_Group4/TextEdit_Group4.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnablePrefix/TextEdit_EnablePrefix.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnableSuffix/TextEdit_EnableSuffix.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisablePrefix/TextEdit_DisablePrefix.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisableSuffix/TextEdit_DisableSuffix.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_Enable/TextEdit_Enable.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_Disable/TextEdit_Disable.text = ""

func _on_CheckBox_Group1_toggled(_button_pressed):
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group1/CheckBox_Group1.pressed = true

func _on_CheckBox_Group2_toggled(_button_pressed):
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group2/CheckBox_Group2.pressed = true

func _on_Conditionals_Button_Switch_pressed():
	var holder = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnablePrefix/TextEdit_EnablePrefix.text
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnablePrefix/TextEdit_EnablePrefix.text = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisablePrefix/TextEdit_DisablePrefix.text
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisablePrefix/TextEdit_DisablePrefix.text = holder
	holder = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnableSuffix/TextEdit_EnableSuffix.text
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnableSuffix/TextEdit_EnableSuffix.text = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisableSuffix/TextEdit_DisableSuffix.text
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisableSuffix/TextEdit_DisableSuffix.text = holder
	holder = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_Enable/TextEdit_Enable.text
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_Enable/TextEdit_Enable.text = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_Disable/TextEdit_Disable.text
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_Disable/TextEdit_Disable.text = holder

func _retrieve_active_set():
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/CheckBox_Group3.pressed = false
	$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/CheckBox_Group4.pressed = false
	var set = active_set["set"].split(" ")
	var count = set.size()
	if count < 4:
		for i in range(count):
			match i:
				0:
					$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group1/VSplitContainer_Group1/TextEdit_Group1.text = set[0]
				1:
					$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group2/VSplitContainer_Group2/TextEdit_Group2.text = set[1]
				2:
					$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/VSplitContainer_Group3/TextEdit_Group3.text = set[2]
					$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/CheckBox_Group3.pressed = true
				3:
					$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/VSplitContainer_Group4/TextEdit_Group4.text = set[3]
					$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/CheckBox_Group4.pressed = true
	# DESIGN A NEW "SET" FIELD THAT WORKS THE TRADITIONAL WAY SO MORE THAN 4 IDS CAN BE INPUT TO IT
	elif count >= 4:
		$VBoxContainer/TabContainer/Conditionals/VBoxContainer_StandardSet.visible = true
		$VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs.visible = false
		$VBoxContainer/TabContainer/Conditionals/VBoxContainer_StandardSet/TextEdit_Set.text = active_set["set"]
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnablePrefix/TextEdit_EnablePrefix.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnablePrefix.visible = false
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnableSuffix/TextEdit_EnableSuffix.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_EnableSuffix.visible = false
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_Enable/TextEdit_Enable.text = active_set["enable"]
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToEnable/VBoxContainer_Enable.visible = true
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisablePrefix/TextEdit_DisablePrefix.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisablePrefix.visible = false
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisableSuffix/TextEdit_DisableSuffix.text = ""
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_DisableSuffix.visible = false
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_Disable/TextEdit_Disable.text = active_set["disable"]
	$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Objects/VBoxContainer_ToDisable/VBoxContainer_Disable.visible = true

func _on_Conditionals_OptionButton_Set_item_selected(index):
	active_set = conditional[current_conditional][index]
	_retrieve_active_set()
	conditional[current_conditional].remove(index)
	_populate_sets()
	_update_export()

func _on_Conditionals_Button_Save_pressed():
	_generate_conditionals()
	_populate_sets()
	_update_export()

func _on_Conditionals_OptionButton_Group_item_selected(index):
	current_conditional = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.get_item_text(index)
	_populate_sets()

func _on_ItemList_Group2_item_selected(index):
	_add_id_to_set(index, $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group2/VSplitContainer_Group2/ItemList_Group2, $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group2/VSplitContainer_Group2/TextEdit_Group2)

func _on_ItemList_Group3_item_selected(index):
	_add_id_to_set(index, $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/VSplitContainer_Group3/ItemList_Group3, $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group3/VSplitContainer_Group3/TextEdit_Group3)

func _on_ItemList_Group4_item_selected(index):
	_add_id_to_set(index, $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/VSplitContainer_Group4/ItemList_Group4, $VBoxContainer/TabContainer/Conditionals/GridContainer_GroupsOfIDs/VBoxContainer_Group4/VSplitContainer_Group4/TextEdit_Group4)

func _add_component_without_suffix(object, suffix, _able):
	if not object.trim_suffix(suffix) + " " in _able and not _able.ends_with(object.trim_suffix(suffix)):
		if _able:
			_able += " " + object.trim_suffix(suffix)
		else:
			_able += object.trim_suffix(suffix)

func _on_Import_Button_Load_pressed():
	var group_list = []
	var parser = XMLParser.new()
	var error = parser.open($VBoxContainer/TabContainer/Import/VSplitContainer/VBoxContainer_XMLPath/HBoxContainer/TextEdit_XMLPath.text)
	var last_node
	var last_tag
	var last_attribute
	if error != OK:
		print("Error opening XML file ", error)
		return
	else:
		print("XML file opened successfully.")
	while parser.read() == 0:
		last_node = parser.get_node_type()
		#print(last_node)
		if last_node == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() != "tuning" and parser.get_node_name() != "part":
				last_tag = parser.get_node_name()
#		elif last_node == XMLParser.NODE_CDATA:
				last_attribute = parser.get_named_attribute_value_safe("name")
				if last_tag and last_attribute:
					var group = last_tag + " " + last_attribute
					if not group_list.has(group):
						group_list.append(group)
	$VBoxContainer/TabContainer/Import/VSplitContainer/VBoxContainer_Import/ItemList_Import.clear()
	for entry in group_list:
		$VBoxContainer/TabContainer/Import/VSplitContainer/VBoxContainer_Import/ItemList_Import.add_item(entry)
	$VBoxContainer/TabContainer/Import/VSplitContainer/VBoxContainer_Import/ItemList_Import.sort_items_by_text()

func _on_Button_Import_pressed():
	var parser = XMLParser.new()
	parser.open($VBoxContainer/TabContainer/Import/VSplitContainer/VBoxContainer_XMLPath/HBoxContainer/TextEdit_XMLPath.text)
	var selection = $VBoxContainer/TabContainer/Import/VSplitContainer/VBoxContainer_Import/ItemList_Import.get_selected_items()
	var last_tag
	var last_attribute
	var last_type
	for entry in selection:
		var tag_attr = $VBoxContainer/TabContainer/Import/VSplitContainer/VBoxContainer_Import/ItemList_Import.get_item_text(entry).split(" ")
		while parser.read() == 0:
			#print("XMLParser read: " + str(parser.read()))
			if parser.get_node_type() == XMLParser.NODE_ELEMENT:
				if parser.get_node_name() == "conditional" or parser.get_node_name() == "group":
					last_tag = parser.get_node_name() 
					last_attribute = parser.get_named_attribute_value_safe("name")
				if parser.get_node_name() == "group":
					last_type = parser.get_named_attribute_value_safe("type")
				if last_attribute == tag_attr[1]:
					#print("Entering: " + last_tag + last_attribute)
					if parser.get_node_name() == "part":
						var type = last_type
						var id = parser.get_named_attribute_value_safe("id")
						var part_name = parser.get_named_attribute_value_safe("name")
						var component = parser.get_named_attribute_value_safe("component")
						var price = parser.get_named_attribute_value_safe("price")
						var rate = parser.get_named_attribute_value_safe("rate")
						var hidelocked = parser.get_named_attribute_value_safe("hidelocked")
						var offset = parser.get_named_attribute_value_safe("offset")
						var offsetF = parser.get_named_attribute_value_safe("offsetF")
						#print("Entering part: " + id + name + component)
						var imported = true
						if hidelocked == "true":
							hidelocked = true
						var dict = {}
						if offset:
							dict["offset"] = offset.split(" ")
							dict["offset"] = Vector2(int(dict["offset"][0]), int(dict["offset"][1]))
						else:
							dict["offset"] = Vector2(0.0 , 0.0)
						if offsetF:
							dict["offsetF"] = offsetF.split(" ")
							dict["offsetF"] = Vector2(int(dict["offsetF"][0]), int(dict["offsetF"][1]))
						else:
							dict["offsetF"] = Vector2(0.0 , 0.0)
						dict["type"] = type
						dict["id"] = id
						dict["name"] = part_name
						dict["component"] = component
						dict["price"] = price
						dict["rate"] = rate
						dict["hidelocked"] = hidelocked
						dict["imported"] = imported
						if tuning.has(tag_attr[1]):
							tuning[tag_attr[1]].append(dict)
						else:
							tuning[tag_attr[1]] = [dict]
						#print(str(tuning[tag_attr[1]][0]))
					if parser.get_node_name() == "condition":
						var set = parser.get_named_attribute_value_safe("set")
						var enable = parser.get_named_attribute_value_safe("enable")
						var disable = parser.get_named_attribute_value_safe("disable")
						var imported = true
						var dict = {}
						dict["set"] = set
						dict["enable"] = enable
						dict["disable"] = disable
						dict["comment"] = "Imported and edited."
						dict["imported"] = imported
						if conditional.has(tag_attr[1]):
							conditional[tag_attr[1]].append(dict)
						else:
							conditional[tag_attr[1]] = [dict]
		print("Scanned all nodes in search of: " + tag_attr[0] + " " + tag_attr[1])
	if not tuning.empty():
		print("tuning not empty")
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group.visible = true
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_GroupNamer.visible = false
		for group in tuning:
			$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.add_item(group)
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.selected = 0
		current_group = $VBoxContainer/TabContainer/Tuning/HBoxContainer_Group/OptionButton_Group.get_item_text(0)
		_populate_parts_list()
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Save.disabled = false
		$VBoxContainer/TabContainer/Tuning/HBoxContainer_Part/Button_Clear.disabled = false
	if not conditional.empty():
		print("conditionals not empty")
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group.visible = true
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_GroupNamer.visible = false
		for group in conditional:
			$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.add_item(group)
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.selected = 0
		current_conditional = $VBoxContainer/TabContainer/Conditionals/HBoxContainer_Group/OptionButton_Group.get_item_text(0)
		_populate_sets()
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Save.disabled = false
		$VBoxContainer/TabContainer/Conditionals/HBoxContainer_Set/Button_Clear.disabled = false
	if not tuning.empty() and not conditional.empty():
		_update_export()
