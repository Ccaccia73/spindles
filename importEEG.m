function [volt,freq] = importEEG(pathname,filename)


fullname=strcat(pathname,filename);

nlines = str2num(perl('countlines.pl',fullname));

fileID = fopen(fullname,'r');

k = 1;
oldperc = -1;

volt = [];

if fileID == -1
	return
end

h = waitbar(0,'1','Name',['Reading EEG file ',filename,'...'],'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');



while ~feof(fileID)
	tmpline = fgetl(fileID);
	
	if ~isempty(strfind(tmpline,','))
		tmpline = strrep(tmpline,',','.');
	end
	
	% tmpline = strrep(tmpline,char(9),' ');
	
	
	tmp_arr = sscanf(tmpline,'%f');
	
	if ~isempty(tmp_arr)
		if k < 3
			if k == 1
				start_time = tmp_arr(1);
			else
				freq = 1 / (tmp_arr(1) - start_time);
			end
		end
		k = k + 1;
		
		volt = [volt;tmp_arr(2)];
		perc = floor((k/nlines)*100);
		
		if getappdata(h,'canceling')
			break
		end
		
		if perc ~= oldperc
			waitbar(perc/100,h,sprintf('Progress: %d%%',perc))
			oldperc = perc;
		end
	end
end

delete(h)
