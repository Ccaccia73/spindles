function varargout = FFT_analyzer(varargin)
% FFT_ANALYZER MATLAB code for FFT_analyzer.fig
%      FFT_ANALYZER, by itself, creates a new FFT_ANALYZER or raises the existing
%      singleton*.
%
%      H = FFT_ANALYZER returns the handle to a new FFT_ANALYZER or the handle to
%      the existing singleton*.
%
%      FFT_ANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FFT_ANALYZER.M with the given input arguments.
%
%      FFT_ANALYZER('Property','Value',...) creates a new FFT_ANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FFT_analyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FFT_analyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FFT_analyzer

% Last Modified by GUIDE v2.5 11-Mar-2013 13:57:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FFT_analyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @FFT_analyzer_OutputFcn, ...
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


% --- Executes just before FFT_analyzer is made visible.
function FFT_analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FFT_analyzer (see VARARGIN)

% Choose default command line output for FFT_analyzer
handles.output = hObject;

handles.spindles_data = struct;
handles.spindles_detect = cell(0,0);


handles.actBehavior = 0;

handles.x = 0;

handles.yscale = -1;
handles.ythresh = -1;

handles.fftminscale = 0;
handles.fftmaxscale = 64;
handles.sigmathresh = 0;

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


% UIWAIT makes FFT_analyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = FFT_analyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
updateRMSdata(handles);


% --- Executes during object creation, after setting all properties.
function selSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


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
				set(handles.FFTseconds,'Enable','on');
				set(handles.FFTwindow,'Enable','on');
				set(handles.calcFFT,'Enable','on');
			else
				set(handles.filterSelect,'Value',1);
				set(handles.status_text,'String','No filter in .mat file')
			end
		end
		
		set(handles.filterApply,'Enable','on');
		
		set(handles.selBehavior,'Enable','on');
		
		handles.x = 0:1/handles.spindles_data.freq:12-1/handles.spindles_data.freq;
        
        guidata(hObject,handles);
		
        
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
	handles.spindles_data.filtername = contents{val}(1:4);
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

if length(handles.spindles_data.filtername) > 4
	fn = handles.spindles_data.filtername(1:4);
else
	fn = handles.spindles_data.filtername;
end

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

set(handles.FFTseconds,'Enable','on');
set(handles.FFTwindow,'Enable','on');
set(handles.calcFFT,'Enable','on');
set(handles.MAsamples,'Enable','on');
set(handles.RMScalc,'Enable','on');


set(handles.status_text,'String',[handles.spindles_data.filtername,' has been applied to raw data'])

guidata(hObject, handles);



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
		set(handles.selSlider,'Visible','off');
		set(handles.minEpoch,'String','');
		set(handles.maxEpoch,'String','');
		axes(handles.rawaxes);
		cla;
		axes(handles.filteraxes);
		cla;
		axes(handles.rawfft);
		cla;
		axes(handles.filterfft);
		cla;
        axes(handles.rmsaxes);
        cla;
		set(handles.rawaxes,'Visible','off');
		set(handles.filteraxes,'Visible','off');
		set(handles.rawfft,'Visible','off');
		set(handles.filterfft,'Visible','off');
        set(handles.rmsaxes,'Visible','off');
		return
	end
	
	set(handles.status_text,'String','Behavior selected');
	
	sliderMin = 1;
	sliderMax = length(handles.spindles_data.behavior{handles.actBehavior});

	set(handles.rawaxes,'Visible','on');
	set(handles.filteraxes,'Visible','on');
	set(handles.rawfft,'Visible','on');
	set(handles.filterfft,'Visible','on');
    set(handles.rmsaxes,'Visible','on');
    
		
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
		set(handles.rawfft,'Visible','on');
		set(handles.filterfft,'Visible','on');
        set(handles.rmsaxes,'Visible','on');
	end
	
	[h1,m1,s1] = calcTime(handles.spindles_data.behavior{handles.actBehavior}(1));
	set(handles.epochText,'String',['current epoch: ',num2str(handles.spindles_data.behavior{handles.actBehavior}(1)),' at ',num2str(h1,'%02d'),':',num2str(m1,'%02d'),':',num2str(s1,'%02d'),' of acquisition']);
	
    handles.currIndex = 1;
    guidata(hObject,handles);
	updateGraphs(handles);
    updateRMSdata(handles);
	
else
    handles.actBehavior = 0;
	set(handles.status_text,'String','Wrong Behavior selection');
	set(handles.epochText,'String','Wrong Behavior selection');
    axes(handles.rawaxes);
    cla;
    axes(handles.filteraxes);
    cla;
    axes(handles.rawfft);
    cla;
    axes(handles.filterfft);
    cla;
    axes(handles.rmsaxes);
    cla;
	set(handles.rawaxes,'Visible','off');
	set(handles.filteraxes,'Visible','off');
	set(handles.rawfft,'Visible','off');
	set(handles.filterfft,'Visible','off');
    set(handles.rmsaxes,'Visible','off');
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



function matFileSpindles_Callback(hObject, eventdata, handles)
% hObject    handle to matFileSpindles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of matFileSpindles as text
%        str2double(get(hObject,'String')) returns contents of matFileSpindles as a double

filename = get(handles.matFilename,'String');

if isempty(filename)
	set(handles.status_text,'String','Please insert a valid name')
else
	fullname = strcat(get(handles.dirText,'String'),'/',filename,'.mat');
	spindles_data = handles.spindles_data;
	save(fullname,'spindles_data');
	set(handles.status_text,'String',['Data saved in ',fullname])
end


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


% --- Executes on button press in pickDir.
function pickDir_Callback(hObject, eventdata, handles)
% hObject    handle to pickDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

directoryname = uigetdir('./', 'Pick a Directory');

set(handles.dirText,'String',directoryname);

% --- Executes on button press in matSpindlesFilesave.
function matSpindlesFilesave_Callback(hObject, eventdata, handles)
% hObject    handle to matSpindlesFilesave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function [h,m,s]=calcTime(value)

totsec = value * 12;

h = floor(totsec / 3600);

sec1 = totsec - h * 3600;

m = floor(sec1 / 60);

s = sec1 - m * 60;




function updateGraphs(handles)

if handles.currIndex <= 0
    return
end

if (handles.actBehavior <=0 ) || (handles.actBehavior >8 )
    return
end

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

if isfield(handles.spindles_data, 'rawfft')
    axes(handles.rawfft)
    cla;
    x = handles.spindles_data.fft_freq;
    y = handles.spindles_data.rawfft(:,epoch+1);
    plot(x,y)
    
    hold on
    % 	% Plot single-sided amplitude spectrum.
    % 	plot(f,2*abs(Y(1:NFFT/2+1)))
    % 	title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|v_{raw}(f)|')
    
    if (get(handles.FFTlim,'Value') )
        xlim([handles.fftminscale handles.fftmaxscale])
    else
        xlim('auto')
    end
    
    hold off
end

if isfield(handles.spindles_data, 'filtfft')
    axes(handles.filterfft)
    cla;
    x = handles.spindles_data.fft_freq;
    y = handles.spindles_data.filtfft(:,epoch+1);
    plot(x,y)
    
    hold on
    % 	% Plot single-sided amplitude spectrum.
    % 	plot(f,2*abs(Y(1:NFFT/2+1)))
    % 	title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|v_{filt}(f)|')
    
    if (get(handles.FFTlim,'Value') )
        xlim([handles.fftminscale handles.fftmaxscale])
    else
        xlim('auto')
    end
    
    hold off
end

if isfield(handles.spindles_data, 'rms')
    axes(handles.rmsaxes)
    cla;
    y = handles.spindles_data.rms(1536*epoch + 1:1536*(epoch+1));
    plot(handles.x,y)
    
    hold on
    % 	% Plot single-sided amplitude spectrum.
    % 	plot(f,2*abs(Y(1:NFFT/2+1)))
    % 	title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('t [s]')
    ylabel('|v_{rms}(t)|')
    
    if (get(handles.showExpMean,'Value') )
        h1 = line([0 12],handles.spindles_data.rms_data.rms_mean_all*[1 1]);
        set(h1,'Color','y','LineStyle','--','LineWidth',1.2);
    end
    
    if (get(handles.showBehaviorMean,'Value') )
        h1 = line([0 12],handles.spindles_data.rms_data.rms_behavior(handles.actBehavior,1)*[1 1]);
        set(h1,'Color','m','LineStyle','--','LineWidth',1.2);
    end
    
    if (get(handles.showEpochMean,'Value') )
        h1 = line([0 12],handles.spindles_data.rms_data.rms_epoch(epoch+1,1)*[1 1]);
        set(h1,'Color','g','LineStyle','--','LineWidth',1.2);
    end

    if (get(handles.showExpThresh,'Value') && handles.sigmathresh > 0 )
        h1 = line([0 12],(handles.spindles_data.rms_data.rms_mean_all + handles.spindles_data.rms_data.rms_std_all*handles.sigmathresh)*[1 1]);
        set(h1,'Color','y','LineStyle','--','LineWidth',1.2);
    end
    
    if (get(handles.showBehaviorThresh,'Value') && handles.sigmathresh > 0 )
        h1 = line([0 12],(handles.spindles_data.rms_data.rms_behavior(handles.actBehavior,1) + handles.spindles_data.rms_data.rms_behavior(handles.actBehavior,2)*handles.sigmathresh)*[1 1]);
        set(h1,'Color','m','LineStyle','--','LineWidth',1.2);
    end
    
    if (get(handles.showEpochThresh,'Value') && handles.sigmathresh > 0 )
        h1 = line([0 12],(handles.spindles_data.rms_data.rms_epoch(epoch+1,1) + handles.spindles_data.rms_data.rms_epoch(epoch+1,2)*handles.sigmathresh)*[1 1]);
        set(h1,'Color','g','LineStyle','--','LineWidth',1.2);
    end
    
    
%     if (get(handles.FFTlim,'Value') )
%         xlim([handles.fftminscale handles.fftmaxscale])
%     else
%         xlim('auto')
%     end
    
    hold off
end

% --- Executes on selection change in FFTseconds.
function FFTseconds_Callback(hObject, eventdata, handles)
% hObject    handle to FFTseconds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FFTseconds contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FFTseconds


% --- Executes during object creation, after setting all properties.
function FFTseconds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FFTseconds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FFTwindow.
function FFTwindow_Callback(hObject, eventdata, handles)
% hObject    handle to FFTwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FFTwindow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FFTwindow


% --- Executes during object creation, after setting all properties.
function FFTwindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FFTwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calcFFT.
function calcFFT_Callback(hObject, eventdata, handles)
% hObject    handle to calcFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.FFTseconds,'String'));
val = str2double(contents{get(handles.FFTseconds,'Value')});


if(isnan(val))
	set(handles.status_text,'String','Please select a value for seconds')
else
    FFTwin = get(handles.FFTwindow,'Value');
    
    handles.spindles_data.rawfft = [];
    handles.spindles_data.filtfft = [];

	L = handles.spindles_data.freq * val;
	NFFT = 2^nextpow2(L);
    
    oldperc = -1;
    kl = 1;
    ntot = 3600;
    hwb = waitbar(0,'1','Name','Computing FFT...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
	
    for k1=1:length(handles.spindles_data.behavior)
        for k2=1:length(handles.spindles_data.behavior{k1})
            act_epoch = handles.spindles_data.behavior{k1}(k2);
            for k3=1:12/val
                winraw = handles.spindles_data.rawvolt(1536*act_epoch + L * (k3-1)+1:1536*act_epoch + L * k3 );
                winfilt = handles.spindles_data.filtervolt(1536*act_epoch + L * (k3-1)+1:1536*act_epoch + L * k3 );
                
                switch FFTwin
                    case 1
                        % none
                    case 2
                        % Hamming
                        winraw = winraw.*window(@hamming,L);
                        winfilt = winfilt.*window(@hamming,L);
                    case 3
                        % Bartlett
                        winraw = winraw.*window(@bartlett,L);
                        winfilt = winfilt.*window(@bartlett,L);
                    case 4
                        % Chebyshev
                        winraw = winraw.*window(@chebwin,L);
                        winfilt = winfilt.*window(@chebwin,L);
                    case 5
                        % Gaussian
                        winraw = winraw.*window(@gausswin,L);
                        winfilt = winfilt.*window(@gausswin,L);
                    case 6
                        % Hann
                        winraw = winraw.*window(@hann,L);
                        winfilt = winfilt.*window(@hann,L);
                    case 7
                        % Triangular
                        winraw = winraw.*window(@triang,L);
                        winfilt = winfilt.*window(@triang,L);
                    otherwise
                        % none
                end
                
                rawfft(:,k3) = fft(winraw,NFFT)/L;
                filtfft(:,k3) = fft(winfilt,NFFT)/L;
            end
            
            if getappdata(hwb,'canceling')
                delete(hwb)
                return
            end
            
            kl = kl + 1;
            perc = floor((kl/ntot)*100);
            
            if perc ~= oldperc
                waitbar(perc/100,hwb,sprintf('Progress: %d%%',perc))
                oldperc = perc;
            end
            
            handles.spindles_data.fft_freq = handles.spindles_data.freq/2*linspace(0,1,NFFT/2+1);
            tmprawfft = mean(2*abs(rawfft(1:NFFT/2+1,:)),2);
            tmpfiltfft = mean(2*abs(filtfft(1:NFFT/2+1,:)),2);
            % disp(['act epoch:',num2str(act_epoch)])
            handles.spindles_data.rawfft(:,act_epoch+1) = tmprawfft;
            handles.spindles_data.filtfft(:,act_epoch+1) = tmpfiltfft;
        end
    end
    
    delete(hwb)
    
    updateGraphs(handles);
        
    guidata(hObject,handles);
end


% --- Executes on button press in FFTlim.
function FFTlim_Callback(hObject, eventdata, handles)
% hObject    handle to FFTlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FFTlim
if get(hObject,'Value')
    set(handles.minFFTlim,'Enable','on');
    set(handles.maxFFTlim,'Enable','on');
else
    set(handles.minFFTlim,'Enable','off');
    set(handles.maxFFTlim,'Enable','off');
end

updateGraphs(handles);


function minFFTlim_Callback(hObject, eventdata, handles)
% hObject    handle to minFFTlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minFFTlim as text
%        str2double(get(hObject,'String')) returns contents of minFFTlim as a double


val = str2double(get(hObject,'String'));

if isnan(val)
    set(handles.status_text,'String','Please insert a valid numeric value');
    set(hObject,'String','');
    handles.fftminscale = 0;
else
    if ( val < 0 ) || ( val > 64 ) || ( val >= handles.fftmaxscale )
      set(handles.status_text,'String','Please set a correct value: 0 to 64Hz and < max');
      set(hObject,'String','');
      handles.fftminscale = 0;
    else
        set(handles.status_text,'String','Min FFT OK');
        handles.fftminscale = abs(val);
        updateGraphs(handles);
    end
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minFFTlim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minFFTlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxFFTlim_Callback(hObject, eventdata, handles)
% hObject    handle to maxFFTlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxFFTlim as text
%        str2double(get(hObject,'String')) returns contents of maxFFTlim as a double

val = str2double(get(hObject,'String'));

if isnan(val)
    set(handles.status_text,'String','Please insert a valid numeric value');
    set(hObject,'String','');
    handles.fftmaxscale = 64;
else
    if ( val < 0 ) || ( val > 64 ) || ( val <= handles.fftminscale )
      set(handles.status_text,'String','Please set a correct value: 0 to 64Hz and > min');
      set(hObject,'String','');
      handles.fftmaxscale = 64;
    else
        set(handles.status_text,'String','Max FFT OK');
        handles.fftmaxscale = abs(val);
        updateGraphs(handles);
    end
end


guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function maxFFTlim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxFFTlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MAsamples.
function MAsamples_Callback(hObject, eventdata, handles)
% hObject    handle to MAsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MAsamples contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MAsamples


% --- Executes during object creation, after setting all properties.
function MAsamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MAsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RMScalc.
function RMScalc_Callback(hObject, eventdata, handles)
% hObject    handle to RMScalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.MAsamples,'String'));
tmpstr = strtok(contents{get(handles.MAsamples,'Value')},'-');

val = str2double(tmpstr);

if isnan(val)
    set(handles.status_text,'String','Please select a valid Moving Average value');
    return
else
    if val>1
        bfilt = ones(val,1)/val;
        handles.spindles_data.rms = filter(bfilt,1,sqrt(handles.spindles_data.filtervolt.^2));
    else
        handles.spindles_data.rms = sqrt(handles.spindles_data.filtervolt.^2);
    end
        
    handles.spindles_data.rms_data.rms_mean_all = mean(handles.spindles_data.rms);
    handles.spindles_data.rms_data.rms_std_all = std(handles.spindles_data.rms);
    
    ntot = 0;
    
    for k1=1:length(handles.spindles_data.behavior)
        ntot = ntot + length(handles.spindles_data.behavior{k1});
    end
    
    handles.spindles_data.rms_data.rms_epoch = zeros(ntot,2);
    handles.spindles_data.rms_data.rms_behavior = zeros(length(handles.spindles_data.behavior),2);
    
    for k1=1:length(handles.spindles_data.behavior)
        
        
        tmp_rms_behavior = [];
        
        for k2=1:length(handles.spindles_data.behavior{k1})
            act_epoch = handles.spindles_data.behavior{k1}(k2);
            
            tmpdata = handles.spindles_data.rms(1536*act_epoch + 1:1536*(act_epoch+1));
            
            tmp_rms_behavior = vertcat(tmp_rms_behavior,tmpdata);
            
            handles.spindles_data.rms_data.rms_epoch(act_epoch+1,1) = mean(tmpdata);
            handles.spindles_data.rms_data.rms_epoch(act_epoch+1,2) = std(tmpdata);
            
        end
        
        handles.spindles_data.rms_data.rms_behavior(k1,1) = mean(tmp_rms_behavior);
        handles.spindles_data.rms_data.rms_behavior(k1,2) = std(tmp_rms_behavior);
        
    end
    
    updateGraphs(handles);
    
    set(handles.miExp,'Visible','on');
    set(handles.miBehav,'Visible','on');
    set(handles.miEpoch,'Visible','on');
    set(handles.sigmaExp,'Visible','on');
    set(handles.sigmaBehav,'Visible','on');
    set(handles.sigmaEpoch,'Visible','on');
    
    set(handles.showExpMean,'Enable','on');
    set(handles.showExpThresh,'Enable','on');
    set(handles.showBehaviorMean,'Enable','on');
    set(handles.showBehaviorThresh,'Enable','on');
    set(handles.showEpochMean,'Enable','on');
    set(handles.showEpochThresh,'Enable','on');
    
    guidata(hObject, handles);
    
    updateRMSdata(handles);
end

function updateRMSdata(handles)

if ( handles.currIndex <= 0 ) || (handles.actBehavior <=0 ) || (handles.actBehavior >8 ) || ~isfield(handles.spindles_data,'rms_data')
    return
end


set(handles.miExp,'String',num2str(handles.spindles_data.rms_data.rms_mean_all,3));
set(handles.miBehav,'String',num2str(handles.spindles_data.rms_data.rms_behavior(handles.actBehavior,1),3));
set(handles.miEpoch,'String',num2str(handles.spindles_data.rms_data.rms_epoch(handles.spindles_data.behavior{handles.actBehavior}(handles.currIndex)+1,1),3));
set(handles.sigmaExp,'String',num2str(handles.spindles_data.rms_data.rms_std_all,3));
set(handles.sigmaBehav,'String',num2str(handles.spindles_data.rms_data.rms_behavior(handles.actBehavior,2),3));
set(handles.sigmaEpoch,'String',num2str(handles.spindles_data.rms_data.rms_epoch(handles.spindles_data.behavior{handles.actBehavior}(handles.currIndex)+1,2),3));



function minSpindlesSpan_Callback(hObject, eventdata, handles)
% hObject    handle to minSpindlesSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minSpindlesSpan as text
%        str2double(get(hObject,'String')) returns contents of minSpindlesSpan as a double
val = str2double(get(hObject,'String'));

if isnan(val)
    set(handles.status_text,'String','Please insert a valid numeric value for Spindles span');
    set(hObject,'String','');
    handles.spindlesSpan = 0;
    set(handles.spindlesDetect,'Enable','off');
else
    set(handles.status_text,'String','Threshold for Spindles span OK');
    handles.spindlesSpan = abs(val);
    if (handles.sigmathresh > 0 )
        set(handles.spindlesDetect,'Enable','on');
    end 
    updateGraphs(handles);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minSpindlesSpan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minSpindlesSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spindlesThresh_Callback(hObject, eventdata, handles)
% hObject    handle to spindlesThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spindlesThresh as text
%        str2double(get(hObject,'String')) returns contents of spindlesThresh as a double
val = str2double(get(hObject,'String'));

if isnan(val)
    set(handles.status_text,'String','Please insert a valid numeric value for threshold');
    set(hObject,'String','');
    handles.sigmathresh = 0;
    set(handles.spindlesDetect,'Enable','off');
else
    set(handles.status_text,'String','Threshold for Spindles detect threshold ok');
    handles.sigmathresh = abs(val);
    if (handles.spindlesSpan > 0 )
        set(handles.spindlesDetect,'Enable','on');
    end
    updateGraphs(handles);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function spindlesThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spindlesThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in spindlesDetect.
function spindlesDetect_Callback(hObject, eventdata, handles)
% hObject    handle to spindlesDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 set(handles.spindlesSummary,'String','');

nb = length(handles.spindles_data.behavior);
handles.spindles_data.spindles_detect = cell(nb,1);

for k1=1:nb
    
    str =  get(handles.spindlesSummary,'String');
    
    nbx = length(handles.spindles_data.behavior{k1});
    handles.spindles_data.spindles_detect{k1} = zeros(nbx,3);
    sig = zeros(1536*nbx,1);
    for k2=1:length(handles.spindles_data.behavior{k1})
        actepoch = handles.spindles_data.behavior{k1}(k2);
        sig(1536*(k2-1)+1:1536*k2) = handles.spindles_data.rms(1536*actepoch + 1:1536*(actepoch+1));
    end
    
    tsig = (sig >= (handles.spindles_data.rms_data.rms_behavior(k1,1) + handles.spindles_data.rms_data.rms_behavior(k1,2)*handles.sigmathresh) );
    
    dsig = diff([0;tsig;0]);
    
    startIndex = find(dsig > 0);
    endIndex = find(dsig < 0) -1;
    tmpDuration = ( endIndex - startIndex + 1 ) / handles.spindles_data.freq;
    
    durationIndex = find(tmpDuration >= handles.spindlesSpan);
    
    for k3=1:length(durationIndex)
        startId = (floor(startIndex(k3)/1536) + 1);
        endId = (floor(endIndex(k3)/1536) + 1);
        startEpoch = handles.spindles_data.behavior{k1}(startId);
        endEpoch = handles.spindles_data.behavior{k1}(endId);
        
        
        if (startEpoch == endEpoch)
            handles.spindles_data.spindles_detect{k1}(startId,1) = handles.spindles_data.spindles_detect{k1}(startId,1) + 1;
            handles.spindles_data.spindles_detect{k1}(startId,2) = mod(startIndex(k3),1536)/handles.spindles_data.freq;
            handles.spindles_data.spindles_detect{k1}(startId,3) = mod(endIndex(k3),1536)/handles.spindles_data.freq;
        elseif ( endEpoch == startEpoch+1 )
            handles.spindles_data.spindles_detect{k1}(startId,1) = handles.spindles_data.spindles_detect{k1}(startId,1) + 0.5;
            handles.spindles_data.spindles_detect{k1}(startId,2) = mod(startIndex(k3),1536)/handles.spindles_data.freq;
            handles.spindles_data.spindles_detect{k1}(startId,3) = 13;
            handles.spindles_data.spindles_detect{k1}(endId,1) = handles.spindles_data.spindles_detect{k1}(endId,1) + 0.5;
            handles.spindles_data.spindles_detect{k1}(endId,2) = -1;
            handles.spindles_data.spindles_detect{k1}(endId,3) = mod(endIndex(k3),1536)/handles.spindles_data.freq;
        end
    end
    
     set(handles.spindlesSummary,'String',{str,['Behavior ',num2str(k1),' Spindles:',num2str(count(handles.spindles_data.spindles_detect{k1}(1,:)))]});
    
end

 guidata(hObject, handles);
 
 

 


% --- Executes on button press in spindlesShow.
function spindlesShow_Callback(hObject, eventdata, handles)
% hObject    handle to spindlesShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spindlesShow


% --- Executes on button press in showExpMean.
function showExpMean_Callback(hObject, eventdata, handles)
% hObject    handle to showExpMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showExpMean
updateGraphs(handles);

% --- Executes on button press in showEpochMean.
function showEpochMean_Callback(hObject, eventdata, handles)
% hObject    handle to showEpochMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showEpochMean
updateGraphs(handles);

% --- Executes on button press in showEpochThresh.
function showEpochThresh_Callback(hObject, eventdata, handles)
% hObject    handle to showEpochThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showEpochThresh
updateGraphs(handles);

% --- Executes on button press in showBehaviorMean.
function showBehaviorMean_Callback(hObject, eventdata, handles)
% hObject    handle to showBehaviorMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showBehaviorMean
updateGraphs(handles);

% --- Executes on button press in showBehaviorThresh.
function showBehaviorThresh_Callback(hObject, eventdata, handles)
% hObject    handle to showBehaviorThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showBehaviorThresh
updateGraphs(handles);

% --- Executes on button press in showExpThresh.
function showExpThresh_Callback(hObject, eventdata, handles)
% hObject    handle to showExpThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showExpThresh
updateGraphs(handles);
