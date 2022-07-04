tool
extends TextEdit

const Colors = {
	"keyword" : Color(0.890196, 0.403922, 0.478431),
	"string" : Color(0.87451, 0.815686, 0.572549)
}

func _ready():
	add_keyword_color("true", Colors.keyword)
	add_keyword_color("false", Colors.keyword)
	add_color_region("\"", "\"", Colors.string)
