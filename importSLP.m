function [behavior,timestamp,status,errmsg] = importSLP(pathname,filename)


fullname=strcat(pathname,filename);

nlines = str2num(perl('countlines.pl',fullname));

fileID = fopen(fullname,'r');

k = 1;
oldperc = -1;

behavior = cell(8,1);

if fileID == -1 || nlines < 8
	errmsg = 'Not enough lines in file';
	status = false;
	return
end


for k1=1:7
	% get rid of header
	tmpline = fgetl(fileID);
end

h = waitbar(0,'1','Name',['Reading SLP file ',filename,'...'],'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

% read first line
tmpline = fgetl(fileID);
tmp_arr = sscanf(tmpline,'%d%d%d%s%s%s%s%s');

type = getbehavior(tmp_arr(3));

if type == -1
	errmsg = ['behavior not recognized at epoch ',num2str(0)];
	status = false;
	return
else
	behavior{type} = [behavior{type};tmp_arr(2)];
end
	


timestamp = char(tmp_arr(end-18:end)');


while ~feof(fileID)
	tmpline = fgetl(fileID);
	
	tmp_arr = sscanf(tmpline,'%d%d%d');
	
	if ~isempty(tmp_arr)
		k = k + 1;
		
		type = getbehavior(tmp_arr(3));
		
		if type == -1
			errmsg = ['behavior not recognized at epoch ',num2str(k-1)];
			status = false;
			return
		else
			behavior{type} = [behavior{type};tmp_arr(2)];
		end
		perc = floor((k/nlines)*100);
		
		if getappdata(h,'canceling')
			errmsg = 'SLP scan interrupted by user';
			status = true;
			delete(h);
			return
		end
		
		if perc ~= oldperc
			waitbar(perc/100,h,sprintf('Progress: %d%%',perc))
			oldperc = perc;
		end
	else
		errmsg = ['scan error at epoch ',num2str(k-1)];
		starus = true;
	end
end

errmsg = 'SLP scan OK';
status = true;
delete(h)
