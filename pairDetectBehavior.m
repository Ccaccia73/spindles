function behavior_detection = pairDetectBehavior( data, detect, filename )
%pairDetectBehavios pairs arrays in data.behavior and detect
%   the function takes each of the cells in data.behavior
%	compares the size with the corresponding cell in detect and
%	generates a 2xn matrix with the data
%	if input is correct, data is saved in filename, if present

if not(isfield(data,'behavior'))
	disp('First function argument of wrong type')
	return
end

if not(iscell(data.behavior))
	disp('data.behavior not a cell array')
	return
end

if not(iscell(detect))
	disp('Detect not a cell array')
	return
end

if not( length(data.behavior) == length(detect) )
	disp('Behavior data and Detect not of the same size')
	return
end

behavior_detection = cell(size(detect));

for k=1:length(detect)
	if( length(data.behavior{k}) == length (detect{k}) )
		if(~isempty(data.behavior{k}))
			behavior_detection{k} = cat(2,data.behavior{k},detect{k});
		else
			behavior_detection{k} = [];
		end
	else
		disp(['Dimensions in behavior ',num2str(k),' not equal'])
		behavior_detection = cell(0,0);
		return
	end
end

if nargin == 3
	disp(['Saving data in: ',filename])
	save(filename,'behavior_detection')
end


end

