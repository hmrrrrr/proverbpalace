@tool
extends EditorScript

const DISALLOWED_NUMBERS = [0,1]

func number_has_any_disallowed_number(n:int) -> bool:
	var valid := true
	for number in DISALLOWED_NUMBERS:
		if str(number) in str(n):
			valid = false
	
	return !valid
	

func _run() -> void:
	
	
	for n in range(99):
		if number_has_any_disallowed_number(n):
			continue
		for base in range(1,55):
			for x in range(1,25):
				var value = n + base*x
				if number_has_any_disallowed_number(value):
					break
				if x >= 15:
					print("x=%d %d+%d*%d = %d"%[x,n,base,x,value])
				
