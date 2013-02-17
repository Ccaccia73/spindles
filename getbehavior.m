function behavior = getbehavior(arr_value)

switch arr_value
	case 1
		behavior = 1;
	case 2
		behavior = 2;
	case 3
		behavior = 3;
	case 4
		behavior = 4;
	case 11
		behavior = 5;
	case 22
		behavior = 6;
	case 33
		behavior = 7;
	case 44
		behavior = 8;
	otherwise
		behavior = -1;
end
		