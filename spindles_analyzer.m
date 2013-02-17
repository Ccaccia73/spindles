function varargout = spindles_analyzer(varargin)
% SPINDLES_ANALYZER MATLAB code for spindles_analyzer.fig
%      SPINDLES_ANALYZER, by itself, creates a new SPINDLES_ANALYZER or raises the existing
%      singleton*.
%
%      H = SPINDLES_ANALYZER returns the handle to a new SPINDLES_ANALYZER or the handle to
%      the existing singleton*.
%
%      SPINDLES_ANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPINDLES_ANALYZER.M with the given input arguments.
%
%      SPINDLES_ANALYZER('Property','Value',...) creates a new SPINDLES_ANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spindles_analyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spindles_analyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spindles_analyzer

% Last Modified by GUIDE v2.5 02-Feb-2013 18:49:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spindles_analyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @spindles_analyzer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before spindles_analyzer is made visible.
function spindles_analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spindles_analyzer (see VARARGIN)

% Choose default command line output for spindles_analyzer
handles.output = hObject;

handles.spindles_data = struct;
handles.spindles_detect = cell(0,0);


handles.actBehavior = 0;

handles.x = 0;

handles.yscale = -1;
handles.ythresh = -1;

handles.currIndex = 0;

% Update handles structure
guidata(hObject, handles);

%get your display size
screenSize = get(0, 'ScreenSize');

%calculate the center of the display
position = get( handles.figure1, 'Position' );
position(1) = (screenSize(3)-position(3))/2;
position(2) = (screenSize(4)-position(4))/2 + 20;

%center the window
set( handles.figure1,'Position', position );

% UIWAIT makes spindles_analyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spindles_analyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in eegselect.
function eegselect_Callback(hObject, eventdata, handles)
% hObject    handle to eegselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[eeg_file,eeg_path] = uigetfile('*.txt','Pick a EEG file');

if eeg_file ~= 0
	set(handles.status_text,'String',['Opening EEG file ',eeg_file]);
	
	[handles.spindles_data.rawvolt,handles.spindles_data.freq] = importEEG(eeg_path,eeg_file);
	
	set(handles.status_text,'String',{'EEG file Read'});
	
	set(handles.status_text,'String',[get(handles.status_text, 'String'); {['Sampling freq:',num2str(handles.spindles_data.freq),'Hz']}]);
	
	handles.spindles_data.acq_time = length(handles.spindles_data.rawvolt) / handles.spindles_data.freq / 3600;
	
	set(handles.status_text,'String',[get(handles.status_text, 'String'); {['Acquisition time:',num2str(handles.spindles_data.acq_time),'h']}]);
	
	set(handles.slp_select,'Enable','on');
	
	set(handles.filterSelect,'Enable','on');
	
	handles.spindles_data.filtername = '';
	
	handles.x = 0:1/handles.spindles_data.freq:12-1/handles.spindles_data.freq;
	
	set(handles.filterApply,'Enable','on');
    
    % spindles reset
    handles.spindles_detect = cell(0,0);
    
    set(handles.SDfilename,'String','No File loaded');
    
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in slp_select.
function slp_select_Callback(hObject, eventdata, handles)
% hObject    handle to slp_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[slp_file,slp_path] = uigetfile('*.slp','*.SLP','Pick a SLP file');

if slp_file ~= 0
	set(handles.status_text,'String',['Opening SLP file ',slp_file]);
		
	[handles.spindles_data.behavior,handles.spindles_data.timestamp,status,errmsg] = importSLP(slp_path,slp_file);
	
	if status
		set(handles.status_text,'String',{errmsg});
		
		set(handles.status_text,'String',[get(handles.status_text, 'String'); {['Acquisition start :',handles.spindles_data.timestamp]}]);
		
		samples = 0;
		
		for k1 = 1:length(handles.spindles_data.behavior)
			samples = samples + length(handles.spindles_data.behavior{k1});
		end
		
		handles.spindles_data.behave_acq_time = samples / 3600 * 12;
		
		set(handles.status_text,'String',[get(handles.status_text, 'String'); {['Behavior Acquisition time:',num2str(handles.spindles_data.behave_acq_time),'h']}]);
		
		set(handles.selBehavior,'Enable','on');
        
        genEmptySpindles(hObject,handles);
	else
		set(handles.status_text,'String',errmsg);
	end
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in open_matfile.
function open_matfile_Callback(hObject, eventdata, handles)
% hObject    handle to open_matfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[mat_file,mat_path] = uigetfile('*.mat','Pick a MAT file');

if mat_file ~= 0
	fullname = strcat(mat_path,mat_file);
	tmpstr = load(fullname);
	if isfield(tmpstr,'spindles_data')
		handles.spindles_data = deal(tmpstr.spindles_data);
		
		set(handles.filterSelect,'Enable','on');
		
		filters = cellstr(get(handles.filterSelect,'String'));
		
		val = find(strncmp(handles.spindles_data.filtername,filters,4),1);
		
		if isempty(val)
			set(handles.filterSelect,'Value',1);
			set(handles.status_text,'String','No filter in .mat file')
		else
			if val >1 && val <12
				set(handles.filterSelect,'Value',val);
			else
				set(handles.filterSelect,'Value',1);
				set(handles.status_text,'String','No filter in .mat file')
			end
		end
		
		set(handles.filterApply,'Enable','on');
		
		set(handles.selBehavior,'Enable','on');
		
		handles.x = 0:1/handles.spindles_data.freq:12-1/handles.spindles_data.freq;
        
        guidata(hObject,handles);
        
        % spindles reset
        genEmptySpindles(hObject,handles);
                
		
        
		set(handles.status_text,'String',['File ',fullname,' successfully loaded']);
	else
		set(handles.status_text,'String','Please select a valid Spindles struct file');
	end
else
	set(handles.status_text,'String','Please select a .mat file');
end


% --- Executes on selection change in filterSelect.
function filterSelect_Callback(hObject, eventdata, handles)
% hObject    handle to filterSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filterSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filterSelect

val = get(hObject,'value');

if val > 1 && val < 12
	contents = cellstr(get(hObject,'String'));
	handles.spindles_data.filtername = contents{val};
else
	handles.spindles_data.filtername = '';
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function filterSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in filterApply.
function filterApply_Callback(hObject, eventdata, handles)
% hObject    handle to filterApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


fn = handles.spindles_data.filtername;

switch fn
	case 'CH05'
		handles.spindles_data.filterTF = CH5;
	case 'CH10'
		handles.spindles_data.filterTF = CH10;
	case 'CH20'
		handles.spindles_data.filterTF = CH20;
	case 'CH25'
		handles.spindles_data.filterTF = CH25;
	case 'CH30'
		handles.spindles_data.filterTF = CH30;
	case 'CH35'
		handles.spindles_data.filterTF = CH35;
	case 'CH40'
		handles.spindles_data.filterTF = CH40;
	case 'BW03'
		handles.spindles_data.filterTF = BW3;
	case 'BW05'
		handles.spindles_data.filterTF = BW5;
	case 'BW20'
		handles.spindles_data.filterTF = BW20;
	otherwise
		set(handles.status_text,'String','You must select a valid filter')
		return
end

handles.spindles_data.filtervolt = filter(handles.spindles_data.filterTF,handles.spindles_data.rawvolt);

set(handles.status_text,'String',[handles.spindles_data.filtername,' has been applied to raw data'])

guidata(hObject, handles);


function matFilename_Callback(hObject, eventdata, handles)
% hObject    handle to matFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of matFilename as text
%        str2double(get(hObject,'String')) returns contents of matFilename as a double


% --- Executes during object creation, after setting all properties.
function matFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pickDir.
function pickDir_Callback(hObject, eventdata, handles)
% hObject    handle to pickDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

directoryname = uigetdir('./', 'Pick a Directory');

set(handles.dirText,'String',directoryname);

% --- Executes on button press in saveMatfile.
function saveMatfile_Callback(hObject, eventdata, handles)
% hObject    handle to saveMatfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filename = get(handles.matFilename,'String');

if isempty(filename)
	set(handles.status_text,'String','Please insert a valid name')
else
	fullname = strcat(get(handles.dirText,'String'),'/',filename,'.mat');
	spindles_data = handles.spindles_data;
	save(fullname,'spindles_data');
	set(handles.status_text,'String',['Data saved in ',fullname])
end


% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Close Spindles 2.0...'],...
                     ['Close'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1);


% --- Executes on slider movement.
function selSlider_Callback(hObject, eventdata, handles)
% hObject    handle to selSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = round(get(hObject,'Value'));

[h1,m1,s1] = calcTime(handles.spindles_data.behavior{handles.actBehavior}(val));
set(handles.epochText,'String',['current epoch: ',num2str(handles.spindles_data.behavior{handles.actBehavior}(val)),' at ',num2str(h1,'%02d'),':',num2str(m1,'%02d'),':',num2str(s1,'%02d'),' of acquisition']);

handles.currIndex = val;
guidata(hObject,handles);
updateGraphs(handles);
updateSpindles(handles);

% --- Executes during object creation, after setting all properties.
function selSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in selBehavior.
function selBehavior_Callback(hObject, eventdata, handles)
% hObject    handle to selBehavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selBehavior contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selBehavior

val = get(hObject,'value');

if val >= 2 && val <= 9
	handles.actBehavior = val-1;
	guidata(hObject, handles);
	
	if isempty(handles.spindles_data.behavior{handles.actBehavior})
		set(handles.status_text,'String','Behavior is empty');
		set(handles.epochText,'String','Behavior is empty');
		set(handles.rawaxes,'Visible','off');
		set(handles.filteraxes,'Visible','off');
		set(handles.selSlider,'Visible','off');
		set(handles.minEpoch,'String','');
		set(handles.maxEpoch,'String','');
		return
	end
	
	set(handles.status_text,'String','Behavior selected');
	
	sliderMin = 1;
	sliderMax = length(handles.spindles_data.behavior{handles.actBehavior});

	set(handles.rawaxes,'Visible','on');
	set(handles.filteraxes,'Visible','on');
		
	if (sliderMax - sliderMin) > 0
		
		set(handles.selSlider,'Min',sliderMin);
		set(handles.selSlider,'Max',sliderMax);
		set(handles.selSlider,'SliderStep',[1 1] / (sliderMax - sliderMin));
		set(handles.selSlider,'Value',sliderMin);
		set(handles.selSlider,'Visible','on');
		
		set(handles.minEpoch,'String',num2str(handles.spindles_data.behavior{handles.actBehavior}(1)));
		set(handles.maxEpoch,'String',num2str(handles.spindles_data.behavior{handles.actBehavior}(end)));
	else
		set(handles.minEpoch,'String','');
		set(handles.maxEpoch,'String','');
		set(handles.selSlider,'Visible','off');
		set(handles.rawaxes,'Visible','on');
		set(handles.filteraxes,'Visible','on');
	end
	
	[h1,m1,s1] = calcTime(handles.spindles_data.behavior{handles.actBehavior}(1));
	set(handles.epochText,'String',['current epoch: ',num2str(handles.spindles_data.behavior{handles.actBehavior}(1)),' at ',num2str(h1,'%02d'),':',num2str(m1,'%02d'),':',num2str(s1,'%02d'),' of acquisition']);
	
    handles.currIndex = 1;
    guidata(hObject,handles);
	updateGraphs(handles);
    updateSpindles(handles);
	
else
	set(handles.status_text,'String','Wrong Behavior selection');
	set(handles.epochText,'String','Wrong Behavior selection');
	set(handles.rawaxes,'Visible','off');
	set(handles.filteraxes,'Visible','off');
	set(handles.selSlider,'Visible','off');
	set(handles.minEpoch,'String','');
	set(handles.maxEpoch,'String','');	
end
	



% --- Executes during object creation, after setting all properties.
function selBehavior_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selBehavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [h,m,s]=calcTime(value)

totsec = value * 12;

h = floor(totsec / 3600);

sec1 = totsec - h * 3600;

m = floor(sec1 / 60);

s = sec1 - m * 60;




function updateGraphs(handles)

epoch = handles.spindles_data.behavior{handles.actBehavior}(handles.currIndex);

raw = handles.spindles_data.rawvolt(1536*epoch + 1:1536*(epoch+1));

axes(handles.rawaxes);
cla;

plot(handles.x,raw);

hold on

xlabel('t [s]')
ylabel('V [{\mu}V]')

if (get(handles.axesbox,'Value') && get(handles.rawaxesbox,'Value') && handles.yscale > 0)
    ylim([-handles.yscale handles.yscale])
else
    ylim('auto')
end

if (get(handles.threshbox,'Value') && handles.ythresh > 0)
    h1 = line([0 12],[handles.ythresh handles.ythresh]);
    h2 = line([0 12],[-handles.ythresh -handles.ythresh]);
    set(h1,'Color',[0.5 0.5 0.5],'LineStyle','--');
    set(h2,'Color',[0.5 0.5 0.5],'LineStyle','--');
end



hold off



filt = handles.spindles_data.filtervolt(1536*epoch + 1:1536*(epoch+1));

axes(handles.filteraxes);
cla;


plot(handles.x,filt);

hold on

xlabel('t [s]')
ylabel('V [{\mu}V]')

if (get(handles.axesbox,'Value') && handles.yscale > 0)
    ylim([-handles.yscale handles.yscale])
else
    ylim('auto')
end

if (get(handles.threshbox,'Value') && handles.ythresh > 0)
    h1 = line([0 12],[handles.ythresh handles.ythresh]);
    h2 = line([0 12],[-handles.ythresh -handles.ythresh]);
    set(h1,'Color',[0.5 0.5 0.5],'LineStyle','--');
    set(h2,'Color',[0.5 0.5 0.5],'LineStyle','--');
end


hold off


% --- Executes on button press in axesbox.
function axesbox_Callback(hObject, eventdata, handles)
% hObject    handle to axesbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axesbox

if get(hObject,'Value')
    set(handles.rawaxesbox,'Enable','on');
    set(handles.yaxes_text,'Enable','on');
else
    set(handles.rawaxesbox,'Enable','off');
    set(handles.yaxes_text,'Enable','off');
end

updateGraphs(handles);


% --- Executes on button press in rawaxesbox.
function rawaxesbox_Callback(hObject, eventdata, handles)
% hObject    handle to rawaxesbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rawaxesbox

updateGraphs(handles);

% --- Executes on button press in threshbox.
function threshbox_Callback(hObject, eventdata, handles)
% hObject    handle to threshbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of threshbox

if get(hObject,'Value')
    set(handles.thresh_text,'Enable','on');
else
    set(handles.thresh_text,'Enable','off');
end

updateGraphs(handles);


function yaxes_text_Callback(hObject, eventdata, handles)
% hObject    handle to yaxes_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yaxes_text as text
%        str2double(get(hObject,'String')) returns contents of yaxes_text as a double

val = str2double(get(hObject,'String'));

if isnan(val)
    set(handles.status_text,'String','Please insert a valid numeric value');
    set(hObject,'String','');
    handles.yscale = -1;
else
    set(handles.status_text,'String','Y scale value OK');
    handles.yscale = abs(val);
end

updateGraphs(handles);

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function yaxes_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yaxes_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thresh_text_Callback(hObject, eventdata, handles)
% hObject    handle to thresh_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresh_text as text
%        str2double(get(hObject,'String')) returns contents of thresh_text as a double

val = str2double(get(hObject,'String'));

if isnan(val)
    set(handles.status_text,'String','Please insert a valid numeric value');
    set(hObject,'String','');
    handles.ythresh = -1;
else
    set(handles.status_text,'String','Threshold value OK');
    handles.ythresh = abs(val);
end

updateGraphs(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function thresh_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function matFileSpindles_Callback(hObject, eventdata, handles)
% hObject    handle to matFileSpindles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of matFileSpindles as text
%        str2double(get(hObject,'String')) returns contents of matFileSpindles as a double


% --- Executes during object creation, after setting all properties.
function matFileSpindles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matFileSpindles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in matSpindlesFilesave.
function matSpindlesFilesave_Callback(hObject, eventdata, handles)
% hObject    handle to matSpindlesFilesave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filename = get(handles.matFileSpindles,'String');

if isempty(filename)
	set(handles.status_text,'String','Please insert a valid name')
else
	fullname = strcat(get(handles.dirText,'String'),'/',filename,'.mat');
	spindles_detect = handles.spindles_detect;
	save(fullname,'spindles_detect');
	set(handles.status_text,'String',['Spindles Data saved in ',fullname])
end

% --- Executes on button press in loadSpindlesMatfile.
function loadSpindlesMatfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadSpindlesMatfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[mat_file,mat_path] = uigetfile('*.mat','Pick a MAT file');

if mat_file ~= 0
	fullname = strcat(mat_path,mat_file);
	tmpstr = load(fullname);
	if isfield(tmpstr,'spindles_detect')
		handles.spindles_detect = deal(tmpstr.spindles_detect);
        
        if sum(size(handles.spindles_detect) == size(handles.spindles_data.behavior)) == 2
            % behavior and detect cells have same size
            if verifySizes(handles.spindles_detect, handles.spindles_data.behavior)
                % arrays have same size for each behavior
                set(handles.SDfilename,'String',['File ',fullname,' loaded']);
                
                guidata(hObject,handles);
                
                set(handles.status_text,'String',['File ',fullname,' successfully loaded']);
                updateSpindles(handles);
                
            else
                set(handles.status_text,'String','Some behavior and spindles size don''t match. Maybe trying to load a wrong file?');
            end
        else
            set(handles.status_text,'String','Cell sizes don''t match');
        end		        
	else
		set(handles.status_text,'String','Please select a valid Spindles detection struct file');
	end
else
	set(handles.status_text,'String','Please select a .mat file');
end

function status = verifySizes(detect, behavior)

status = true;

for k1=1:size(behavior,1)
    for k2=1:size(behavior,2)
        if(length(detect{k1,k2}) ~= length(behavior{k1,k2}))
            status = false;
            break;
        end
            
    end
end


function genEmptySpindles(hObject,handles)

handles.spindles_detect = cell(size(handles.spindles_data.behavior));

for k1 = 1:size(handles.spindles_data.behavior,1)
    for k2 = 1:size(handles.spindles_data.behavior,2)
        handles.spindles_detect{k1,k2} = zeros(size(handles.spindles_data.behavior{k1,k2}));
    end
end

guidata(hObject,handles);

set(handles.SDfilename,'String','Spindles reset to zero');

set(handles.currEpochCount,'String','0');
set(handles.currBehaviorCount,'String','0');


% --- Executes on selection change in spindlesCount.
function spindlesCount_Callback(hObject, eventdata, handles)
% hObject    handle to spindlesCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns spindlesCount contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spindlesCount

if (handles.actBehavior >= 1 && handles.actBehavior <= 8)
    
    contents = cellstr(get(hObject,'String'));
    val = str2double(contents{get(hObject,'Value')});
    
    if ~isempty(val)
        handles.spindles_detect{handles.actBehavior}(handles.currIndex) = val;
        guidata(hObject,handles);
        updateSpindles(handles);
    end
end


% --- Executes during object creation, after setting all properties.
function spindlesCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spindlesCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateSpindles(handles)

currVal = handles.spindles_detect{handles.actBehavior}(handles.currIndex);
totVal = sum(handles.spindles_detect{handles.actBehavior});

set(handles.currEpochCount,'String',num2str(currVal));
set(handles.currBehaviorCount,'String',num2str(totVal));

contents = cellstr(get(handles.spindlesCount,'String'));

val = find(strncmp(num2str(currVal),contents,1),1);

if isempty(val)
	disp('problema currVal')
else
	set(handles.spindlesCount,'Value',val)
end
