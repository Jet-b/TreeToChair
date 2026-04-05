extends PanelContainer

@onready var money_label = $HBoxContainer/MoneyLabel
@onready var wood_label = $HBoxContainer/WoodLabel
@onready var planks_label = $HBoxContainer/PlanksLabel
@onready var metal_label = $HBoxContainer/MetalLabel
@onready var nails_label = $HBoxContainer/NailsLabel
@onready var chairs_label = $HBoxContainer/ChairsLabel

func _ready() -> void:
	FundManager.resource_changed.connect(resource_changed)
	

func update_labels(type):
	if type == FundManager.ResType.MONEY:
		money_label.text = "Money: " + str(FundManager.get_amount(FundManager.ResType.MONEY))
	if type == FundManager.ResType.WOOD:
		wood_label.text = "Wood: " + str(FundManager.get_amount(FundManager.ResType.WOOD))
	if type == FundManager.ResType.PLANKS:
		planks_label.text = "Planks: " + str(FundManager.get_amount(FundManager.ResType.PLANKS))
	if type == FundManager.ResType.METAL:
		metal_label.text = "Metal: " + str(FundManager.get_amount(FundManager.ResType.METAL))
	if type == FundManager.ResType.NAILS:
		nails_label.text = "Nails: " + str(FundManager.get_amount(FundManager.ResType.NAILS))
	if type == FundManager.ResType.CHAIRS:
		chairs_label.text = "Chairs: " + str(FundManager.get_amount(FundManager.ResType.CHAIRS))
	


func resource_changed(type, amount):
	update_labels(type)
