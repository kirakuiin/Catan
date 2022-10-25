extends VBoxContainer


func init(rule: int):
    var data = UI_Data.RULE_DATA[rule]
    $RuleName.text = data.title
    $RuleName.modulate = data.color
    $RuleDesc.text = data.desc