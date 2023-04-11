function brighnes_induction
global CRS maxlsY STATE;
vsgInit

%======inicializate constant=======
ViewDistance = 700; % mm
crsSetViewDistMM(ViewDistance);
cone_model = 6; % Boynton (L(498)+M(498)=S(498)) (1986)
maxlsY = calculate_monitor_extremes('lsY', cone_model);%miramos los extremos del monitor

WhiteRGB = lsY2CRSRGB([0.66 0.98 maxlsY(3)],cone_model); % encontramos el blanco
BlackRGB = lsY2CRSRGB([0.66 0.98 0],cone_model);%encontramos el negro
%tama?o de un degree
height = crsGetScreenHeightPixels;
Width = crsGetScreenWidthPixels;
ovalSize = [height/min(crsGetScreenSizeDegrees),height/min(crsGetScreenSizeDegrees)];
MinRGB = BlackRGB;
MaxRGB = WhiteRGB;
Background = lsY2CRSRGB([0.66 0.98 20],cone_model);
Angle     = 90;
Frequency = 4;
Size      = [ Width/2 , height/1.5 ];
All_buttons   = [1 2 3 4 5 6 7 8 9];
STATE.cone_model=cone_model;
STATE.ovalSize=	ovalSize;
STATE.Angle=Angle;
STATE.Frequency=Frequency;
STATE.Size=Size;
STATE.height=height;
STATE.Width=Width;
STATE.All_buttons=All_buttons;
STATE.Background=Background;

%======paginas=================%
BlankPage = 1;
Text_begin = 2;
Text_updating=3;
Text_finish = 4;
StimPage=5;
crsSetDrawPage(Text_begin);
crsClearPage(Text_begin,CRS.BACKGROUND);
palete_mid        = zeros(3,256);
palete_mid(1, 3:256)=Background(1);
palete_mid(2, 3:256 )=Background(2);
palete_mid(3, 3:256 )=Background(3);
crsPaletteSet(palete_mid)

crsSetDrawPage(Text_updating);
crsClearPage(Text_updating,CRS.BACKGROUND);

crsSetDrawPage(Text_finish);
crsClearPage(Text_finish,CRS.BACKGROUND);

crsSetPen1(1);
crsSetPen2(3);
crsSetDrawPage(CRS.VIDEOPAGE,Text_begin);
crsSetPen1(1);
crsSetPen2(3);
crsDrawString([0 -100],'Experiment starting...');
crsSetDrawPage(CRS.VIDEOPAGE,Text_updating);
crsSetPen1(1);
crsSetPen2(3);
crsDrawString([0 -100],'Experiment updating...');
crsSetDrawPage(CRS.VIDEOPAGE,Text_finish);
crsSetPen1(1);
crsSetPen2(3);
crsDrawString([0 -100],'Experiment finished...');




%=========promt=========
answer = {};
SubjectName='';
NumCase='1';
promptstr = {'Enter Subject?s name','Num Cases'};

if isempty(answer)
	inistr = {'Nobody',NumCase};
else
	inistr = {SubjectName,num2str(NumCase)};
end

titlestr = 'Experiment initialisation';
nlines = 1;
ok2 = false;

while ok2 == false
	answer = inputdlg(promptstr,titlestr,nlines,inistr);
	if isempty(answer)
		ButtonName = questdlg('You will lose data. Are u sure?', ...
			'Exit now?', 'Immediately!', 'No thanks','No thanks');
		if strcmp(ButtonName, 'Immediately!')
			error('Experiment cancelled');
		end
	else
		SubjectName = answer{1};
		NumCase = str2num(answer{2});
		ok2 = true;
	end
end

options.Interpreter = 'tex';
% Desired Default answer
options.Default = 'Both';
% Create a TeX string for the question
options.Interpreter = 'tex';
% Desired Default answer
options.Default = 'Test ring';
% Create a TeX string for the question
qstring = 'you are going to choose?';
choices = {  'Brightnes Induccion','Center Sorround'};
choice = bttnChoiseDialog(choices, ...
	'Boundary condition' ,'Center Sorround', qstring, [1,1]);
choice = char(choices(choice));
%pathname of
pathname = strcat('D:\Results\BrightnesInduccion Center Sorround','\',choice,'\',SubjectName,'\');
filename = strcat(SubjectName,'_', datestr(now,'yyyy-mm-dd_HH.MM.SS'));
%create directories if don't exist
if ~exist(char(pathname), 'dir')
	mkdir(char(pathname));
end
%create the excel
switch choice
	case 'Brightnes Induccion'
		s = xlswrite(char(strcat(pathname,filename,'.xls')), {'Index','First inductor', 'Second inductor','Test value','Comparison value(Initial)','Comparison value(results)','Hour initial','Hour final','Seconds'},...
			strcat('A',num2str(1),':I',num2str(1)));
	case 'Center Sorround'
		
		s=xlswrite(char(strcat(pathname,filename,'.xls')),{'Index' 'Max Y inductor',	'Min Y inductor',	'Amplitud',	'Inside amplitud'	,'Initial  max y', 'Initial min Y',	'Initial diff position',	'Final max',	'Final min',	'Result (final amplitude)',	'Hour initial'	,'Hour final'	'Seconds'},...		
			strcat('A',num2str(1),':N',num2str(1)));
		
end




%===============aleatorio===========

%rng(str2num(datestr(now,'mmdd'))+str2num(datestr(now,'HHMMSS')));
rng('shuffle')
diff=[0,5,10,15,20,-5,-10,-15,-20];
diffpos=[0,5,10,15,20];
index=[];
switch choice
	case 'Brightnes Induccion'
		NumCase=NumCase*9;
		index=mod(randsample(1:NumCase,NumCase),9)+1;
	case 'Center Sorround'
		NumCase=NumCase*5;
		index=mod(randsample(1:NumCase,NumCase),5)+1;
		
end

%==========clear the screen===========%
crsSetBackgroundColour(Background);
crsPresent;
crsSetDrawPage(BlankPage);
crsClearPage(BlankPage,CRS.BACKGROUND);
crsSetDisplayPage(Text_begin);

for iter=5:NumCase+5
	crsClearPage(iter,CRS.BACKGROUND);
end
pause(4)
crsSetDisplayPage(BlankPage);
crsSetDrawPage(StimPage);
crsClearPage(StimPage,CRS.BACKGROUND);
%===========start the experiment
	pause(180);

	switch choice
		case 'Brightnes Induccion'
			for iter=1:NumCase
	
				
				crsSetDisplayPage(Text_updating);
				 fprintf('%i\n', iter);
				pause(3)
				
				initial=(39-1).*rand(1,1) + 0;
				initial_time=datestr(now,'HH.MM.SS');
				[inside, result,time] = Brighines_in(diff(index(iter)),iter+4,initial);
				s = xlswrite(char(strcat(pathname,filename,'.xls')), {index(iter),20+diff(index(iter)), 20-diff(index(iter)),inside, initial,result,initial_time,datestr(now,'HH.MM.SS'),time},...
					strcat('A',num2str(iter+1),':I',num2str(iter+1)));
				
				
	
			end
		case 'Center Sorround'
			for iter=1:NumCase
				crsSetDisplayPage(Text_updating);
				fprintf('%i\n', iter);
				pause(3)
				initial=(20-0).*rand(1,1) + 0;
				
				%amply(iter)
				initial_time=datestr(now,'HH.MM.SS');
				
				[inside_amplitud,amplitud_result,time]=Center_sorround(iter+4,diffpos(index(iter)),initial);

				s=xlswrite(char(strcat(pathname,filename,'.xls')),{index(iter),20+diffpos(index(iter)), 20-diffpos(index(iter)),diffpos(index(iter)),inside_amplitud,20+initial,20-initial,initial,20+amplitud_result,20-amplitud_result,amplitud_result,initial_time,datestr(now,'HH.MM.SS'),time},...
				strcat('A',num2str(iter+1),':N',num2str(iter+1)));
	
			end
			
	end
	

 fprintf('FINISH \n');
crsSetDisplayPage(Text_finish);
%============drawing of first stimulus=============
function [test ,results,time]= Brighines_in(diff,StimPage,initial)
%==============inicializate the variables
global CRS STATE maxlsY
%clear the page
crsSetDrawPage(StimPage);
crsClearPage(StimPage,CRS.BACKGROUND);


brightness=20;
Width = crsGetScreenWidthPixels;
cone_model=STATE.cone_model;
Location=[ -Width/8,0];
All_buttons=STATE.All_buttons;
ovalSize=STATE.ovalSize;
Size=STATE.Size;
Angle=STATE.Angle;
Frequency=STATE.Frequency;
Background=STATE.Background;

MinYtimulus=brightness-diff;
MaxYStimulus=brightness+diff;
MinLevel   = 10;
MaxLevel   = 100;
degresize=14;
MinRGBStimulus=lsY2CRSRGB([0.66 0.98 MinYtimulus],cone_model);
MaxRGBStimulus=lsY2CRSRGB([0.66 0.98 MaxYStimulus],cone_model);
MidRGB=lsY2CRSRGB([0.66 0.98 20],cone_model);
%==============clear the palettes======================
palete_mid        = zeros(3,256);
palete_mid(1, 3:256)=MidRGB(1);
palete_mid(2, 3:256 )=MidRGB(2);
palete_mid(3, 3:256 )=MidRGB(3);
crsPaletteSet(palete_mid)

%draw the circle
crsSetDrawMode( CRS.COPYMODE+CRS.CENTREXY);
crsSetPen1(1)
crsDrawOval( Location ,ovalSize*degresize);
%make the grade

crsSetDrawMode(CRS.TRANSONLOWER+CRS.CENTREXY);
crsSetPen1(MinLevel);
crsSetPen2(MaxLevel);
ajuste =3*100/36;
NumLevels = crsDrawGrating([  -Width/8+ajuste,0],Size,Angle,Frequency);
MaxLevel  = (MinLevel + NumLevels) - 1;

%make a object
crsObjCreate;
crsObjSetPixelLevels(MinLevel,NumLevels);

crsObjSetColourVector(MinRGBStimulus,MaxRGBStimulus,MidRGB);%aqui puedes controlar el color maximo y minimo


%make the  square sinusoide
SWsize = crsObjGetMaximumTableSize(CRS.SWTABLE);
Theta  = linspace(0,2*pi,SWsize); % one cycle, in radians
Sqr = square(Theta);


%load the sinusoide in objeto
crsObjSetTableSize(CRS.SWTABLE,SWsize);
crsObjTableLoadVector(CRS.SWTABLE,Sqr);

%create a 1/4 degree wide rectangle as sampling
if diff==0
	test=15;
	midelsquare=lsY2CRSRGB([0.66 0.98 15],cone_model);
else
	test=20;
	midelsquare=lsY2CRSRGB([0.66 0.98 20],cone_model);
end

%draw the compare object
crsSetDrawMode(CRS.COPYMODE+CRS.CENTREXY);
crsPaletteSetPixelLevel(MaxLevel+1,midelsquare);
crsSetPen1(MaxLevel+1);
crsDrawRect([(-Width/8),0],[1/8*Width/max(crsGetScreenSizeDegrees),3*Width/max(crsGetScreenSizeDegrees)]);
crsPresent;

crsObjDestroyAll;%liberas espacio

waitforme = 1;
%draw the test object
brightness=initial;
	testcolor=lsY2CRSRGB([0.66 0.98 brightness],cone_model);
	crsSetDrawMode(CRS.COPYMODE+CRS.CENTREXY);
	crsPaletteSetPixelLevel(5,testcolor);
	crsSetPen1(5);
	crsDrawRect([(Width/8),0],[1/8*Width/max(crsGetScreenSizeDegrees),3*Width/max(crsGetScreenSizeDegrees)]);
	crsPresent;

clock=tic;%start the clock
joystick on; %activate the joystick

while waitforme
	
	[buttons stick_1 stick_2] = joystick('get', All_buttons);
	
	if buttons(8)
		if brightness >0.025
			brightness=brightness-0.025;
			
		end
		
	elseif buttons(6)
		if brightness < maxlsY(3)
			brightness=brightness+0.025;
		end
		
	end
	testcolor=lsY2CRSRGB([0.66 0.98 brightness],cone_model);
	crsPaletteSetPixelLevel(5,testcolor);
	brightness


	if buttons(9)
		joystick off;
		results=brightness;
		crsObjDestroyAll;
		crsClearPage(StimPage,CRS.BACKGROUND);
		time=toc(clock);
		waitforme=0;
	end
end




function [inside_amplitud,results,clock]= Center_sorround(StimPage,diff,initial)
%==========inicializate the variables ==================
global CRS STATE maxlsY
%height = crsGetScreenHeightPixels;
Width = crsGetScreenWidthPixels;
Height= crsGetScreenHeightPixels;
cone_model=STATE.cone_model;
Location=[ -Width/8,0];
All_buttons=STATE.All_buttons;
ovalSize=STATE.ovalSize;
Size=[Width/2,Height];
Angle=STATE.Angle;
Frequency=STATE.Frequency;

MinRGBStimulus=lsY2CRSRGB([0.66 0.98 20-diff],cone_model);
MaxRGBStimulus=lsY2CRSRGB([0.66 0.98 20+diff],cone_model);
MidRGB=lsY2CRSRGB([0.66 0.98 20],cone_model);


%=============clear the page==========
crsSetDrawPage(CRS.VIDEOPAGE ,StimPage);
crsClearPage(StimPage,CRS.BACKGROUND);



%=============clear the palete==========
palete_mid        = zeros(3,256);
palete_mid(1, 3:256)=MidRGB(1);
palete_mid(2, 3:256 )=MidRGB(2);
palete_mid(3, 3:256 )=MidRGB(3);
crsPaletteSet(palete_mid)

%==========draw the fist object ==========

MinLevel   = 120;
MaxLevel   = 180;
degresize=6*2;
degreesizein=3;


%%cicle out with 8 degree of diametre out circles 
crsSetDrawMode(CRS.COPYMODE+CRS.CENTREXY);
crsSetPen1(10)
crsDrawOval(Location,ovalSize*degresize);
crsSetDrawMode(CRS.TRANSONLOWER+CRS.CENTREXY);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%create the grating 
crsSetPen1(MinLevel);
crsSetPen2(MaxLevel);

NumLevels = crsDrawGrating([  -Width/8,0],Size,Angle,Frequency);
obj1=crsObjCreate;
crsObjSetPixelLevels(MinLevel,NumLevels);
crsObjSetColourVector(MinRGBStimulus,MaxRGBStimulus,MidRGB)


%crete the square sinusoide
SWsize = crsObjGetMaximumTableSize(CRS.SWTABLE);
Theta  = linspace(0,2*pi,SWsize); % one cycle, in radians
Sqr = sin(Theta);


%load the sinusoid
crsObjSetTableSize(CRS.SWTABLE,SWsize);
crsObjTableLoadVector(CRS.SWTABLE,Sqr);

crsPresent;
crsObjDestroy(obj1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%circle in 8degrees +10 min diametre 
crsSetDrawMode(CRS.COPYMODE+CRS.CENTREXY);
crsPaletteSetPixelLevel(245,MidRGB);
crsSetPen1(245);
crsDrawOval(Location,(ovalSize*(degreesizein+(10/60))));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 		Draw the Oval. circle 8 degrees
crsSetDrawMode(CRS.COPYMODE+CRS.CENTREXY);
crsSetPen1(4);
crsDrawOval(Location,ovalSize*degreesizein);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%circles inside color 

inside_amplitud=10;
MinRGBStimulus2=lsY2CRSRGB([0.66 0.98 10],cone_model);
MaxRGBStimulus2=lsY2CRSRGB([0.66 0.98 30],cone_model);
MidRGB=lsY2CRSRGB([0.66 0.98 20],cone_model);


crsSetDrawMode(CRS.TRANSONLOWER+CRS.CENTREXY);
% crsSetDrawMode(CRS.COPYMODE+CRS.CENTREXY);
MinLevel   = 10;
MaxLevel   = 70;


obj2=crsObjCreate;
Size=[Width/2,Height/2];
crsSetPen1(MinLevel);
crsSetPen2(MaxLevel);

NumLevels = crsDrawGrating([  -Width/8,0],Size,Angle,Frequency);


crsObjSetPixelLevels(MinLevel,NumLevels);
crsObjSetColourVector(MinRGBStimulus2,MaxRGBStimulus2,MidRGB);

crsObjSetTableSize(CRS.SWTABLE,SWsize);
crsObjTableLoadVector(CRS.SWTABLE,Sqr);





crsPresent;
crsObjDestroy(obj2)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%test oval
crsSetDrawMode(CRS.COPYMODE+CRS.CENTREXY);
crsSetPen1(7);
crsDrawOval([ Width/8,0],ovalSize*degreesizein);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
crsSetDrawMode(CRS.TRANSONLOWER+CRS.CENTREXY);

diff_test=initial;
%diff_test=10;
MinRGBStimulus3=lsY2CRSRGB([0.66 0.98 20-diff_test],cone_model);
MaxRGBStimulus3=lsY2CRSRGB([0.66 0.98 20+diff_test],cone_model);
MinLevel = 181;
MaxLevel= 241;

crsSetPen1(MinLevel);
crsSetPen2(MaxLevel);

Size=[Width/8,Height/8];

NumLevels = crsDrawGrating([  Width/8,0],Size,Angle,Frequency);
obj3=crsObjCreate;
crsObjSetPixelLevels(MinLevel,NumLevels);
crsObjSetColourVector(MinRGBStimulus3,MaxRGBStimulus3,MidRGB);
crsObjSetTableSize(CRS.SWTABLE,SWsize);
crsObjTableLoadVector(CRS.SWTABLE,Sqr);
crsPresent;


%%%%%%%%%controler%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitforme = 1;
joystick on; %activate the joystick
time=tic;
while waitforme
	[buttons stick_1 stick_2] = joystick('get', All_buttons);
	if buttons(6)
		if diff_test < maxlsY(3)-19.5
			diff_test=diff_test+0.025;
		end
	elseif buttons(8)
		if diff_test > 0.025
			diff_test=diff_test-0.025;
		end
	end
	diff_test
	MinRGBStimulus3=lsY2CRSRGB([0.66 0.98 20-diff_test],cone_model);
	MaxRGBStimulus3=lsY2CRSRGB([0.66 0.98 20+diff_test],cone_model);
	crsObjSetColourVector(MinRGBStimulus3,MaxRGBStimulus3,MidRGB);
	crsPresent;
	
	if buttons(9)
		joystick off;
		results=diff_test;
		crsObjDestroy(obj3);
		crsSetDrawPage(StimPage);
		crsClearPage(StimPage,CRS.BACKGROUND);
		clock=toc(time);
		waitforme=0;
	end
end








