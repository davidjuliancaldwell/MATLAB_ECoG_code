function [Answer, figfmen, AnsFlg1] =inpdlg(Prompt, Title, NumLines, ...
          DefAns, PromptDef, AnsFlg1, Resize, ListInit)
% Version 1.10       
%INPUT\OUTPUT:
%   Answer - cell array of in\output data, includes e.g.: 
%          N_Fsmp - # of randomly measured frequency samples.
%   AnsFlg - cell array of structures.
%            Each structure containes a frame of in\output flags e.g.: 
%          Frm_Name- Tag of frame e.g.('Measure method:').
%            The other fields are flag variables to be set by inpdlg e.g.:
%          CC_Flg  - Correlation Coefficients method used in Freq measurements.
%          AC_Flg  - AutoCorrelation method used in Freq measurements.
%
%INPUTDLG Input dialog box.
%  Answer = inpdlg(Prompt) creates a modal dialog box that returns
%  user input for multiple prompts in the cell array Answer.  Prompt
%  is a cell array containing the Prompt strings.
%
%  Answer = inpdlg(Prompt,Title) specifies the Title for the dialog.
%
%  Answer = inpdlg(Prompt,Title,LineNo) specifies the number of lines
%  for each answer in LineNo.  LineNo may be a constant value or a 
%  column vector having one element per Prompt that specifies how many
%  lines per input.  LineNo may also be a matrix where the first
%  column specifies how many rows for the input field and the second
%  column specifies how many columns wide the input field should be.
%
%  Answer = inpdlg(Prompt,Title,LineNo,DefAns) specifies the default
%  answer to display for each Prompt.  DefAns must contain the same
%  number of elements as Prompt and must be a cell array.
%
%  Answer = inpdlg(Prompt,Title,LineNo,DefAns,AddOpts) specifies whether
%  the dialog may be resized or not.  Acceptable values for AddOpts are 
%  'on' or 'off'.  If the dialog can be resized, then the dialog is
%  not modal.  
%
%  AddOpts may also be a data structure with fields Resize,
%  WindowStyle and Interpreter.  Resize may be 'on' or 'off'.
%  WindowStyle may be 'modal' or 'normal' and Interpreter may be
%  'tex' or 'none'.  The interpreter applies to the prompt strings.
%
%  Example:
%  prompt={'Enter the matrix size for x^2:','Enter the colormap name:'};
%  def={'20','hsv'};
%  dlgTitle='Input for Peaks function';
%  lineNo=1;
%  answer=inpdlg(prompt,dlgTitle,lineNo,def);
%
%  or
%
%  AddOpts.Resize='on';
%  AddOpts.WindowStyle='normal';
%  AddOpts.Interpreter='tex';
%  answer=inpdlg(prompt,dlgTitle,lineNo,def,AddOpts);
%
%  See also TEXTWRAP, QUESTDLG.

%  Loren Dean   May 24, 1995.
%  Copyright (c) 1984-98 by The MathWorks, Inc.
%  $Revision: 1.48 $

% This specific input dialog was designed with the aid of GUIDE and the 
% machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
% This problem is solved by saving the output as a FIG-file.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.
% 
% NOTE: certain newer features in MATLAB may not have been saved in this
% M-file due to limitations of this format, which has been superseded by
% FIG-files.  Figures which have been annotated using the plot editor tools
% are incompatible with the M-file/MAT-file format, and should be saved as
% FIG-files.

%  Example:
% Program simulating Frequency measurments
%
%  N_FDat = 1024;
%  [CCflg,ACflg] = deal(1);
%  logical(CCflg);logical(ACflg);
%  [AAA_FMflg,AA_AMflg] = deal(0);

%  prompt={'Enter number of frequency measurements:','Enter 3 numbers:'};
%  DefAns={num2str(N_FDat), {'12','345','6'}};
%  dlgTitle='Random frequency measurements Input';
%  NumLines=[1 8; 3 8];

%%  	PromptDef(1,:) = [ 0 0 N 0 ...] 0 - edit box, 
%%                                  N - Popup menu(N is the initial selection)
%%                                 -N for ListBox(ListInit{N} is the initial selection)    
%%  	PromptDef(2,:) = [ 0 1 0 0 ...] 1 - initially disabled Quests 
%%      						for ListBox:	1  initially disabled ListBox
%%                  							2  Single item selection ListBox
%%							                  3  Single item selection + initially disabled ListBox
%  PromptDef = [0 0 ; 0 0]; 
%  Resize = 'on';
%%    ListInit{N} is the initial selection for ListBox(N) - see PromptDef(1,:)
%  ListInit = {[1,2,4]; [3]; };
%  
%  MesMet = struct('Frm_Nam',{'Mesure Method:'}, 'typ', 'rad', ...
%                  'ACflg',{{ACflg; 'Auto Correl'; L}}, ...
%                  'CCflg',{{CCflg; 'Cross Corr'}}, ...
%                  'En_Quest',{{[401 402];[1 2 3]}});
%%  ACflg - {{ACflg; 			% Initial Value for AnsFlg1{1}.ACflg
%%            'Auto Correl';	% Name Tag for AnsFlg1{1}.ACflg
%%            L}} 				% L=1 AnsFlg1{1}.ACflg initially disabled
%%                            %  =0 AnsFlg1{1}.ACflg initially enabled
%%  En_Quest - {{[401 402]; % checking ACflg will enable items 1 2 of Frame 4 (AnsFlg1(4))
%%                          % unchecking ACflg will disable them
%%               [1 2 3];}} % checking CCflg will enable Prompts 1 2 3
%%                          % unchecking CCflg will disable them
%  AnsFlg1(1)={MesMet};

%  MesMet = struct('Frm_Nam',{'Mesure MetMes Method:'}, 'typ', 'rad', ...
%                  'AAA_FMflg', {{AAA_FMflg}}, 'AA_AMflg',{{AA_AMflg}}, ...
%                  'En_Quest',{{[];[1 3];}});
%  AnsFlg1(2)={MesMet};
%
%   for inpdlg containing only flags (no numeric data i.e. Answer) enter
%  the following input: 
%%                      prompt = {};
%%                      DefAns = {};
%%                      NumLines = 1;
%  
%  [Answer, figfmen, AnsFlg1] =inpdlg(prompt, dlgTitle, NumLines, ...
%            DefAns, AnsFlg1, Resize)
%  
%  if isempty(figfmen), 
%     disp('Random Frequency measurements Stage skipped.'); 
%     return;
%  else,
%     if isempty(Answer),
%        disp(['Random Frequency measurements input dialog didn`t pro',...
%              'vide any output']); 
%        disp('Random Frequency measurements Stage skipped.'); 
%        return;
%     else,
%        [N_FDat, count] = sscanf(Answer{1},'%d',1);
%     end;
%  end;
%
% Line command:    Answer =inp<ut>dlg(prompt,dlgTitle,NumLines,DefAns)
%  is valid for both inpdlg.m and the original inputdlg.m
%
%  Joshua Malina   October 29, 1999.
%  Copyright (c) ELTA, Inc.
%  $Revision: 1.04 $ $Date 04-Nov-1999 13:12:41 $
%  $Revision: 1.10 $ $Date 18-Nov-1999 16:47:04 $
%             radio buttons frames option added.
%             popup menus option added.
%             horizontal spread of UIControls.
%  $Revision: 1.22 $ $Date 04-Dec-1999 16:30:04 $
%             Bug related to single frame fixed.
%             Option for disabled Quests added.
%             Option for disabling Quests by changing checkboxes\radiobuttons status added.
%  $Revision: 1.24 $ $Date 10-Dec-1999 14:32:17 $
%             String tags for checkboxes\radiobuttons added.
%  $Revision: 1.25 $ $Date 16-Dec-1999 09:43:44 $
%             Check for wrong En_Quest values.
%  $Revision: 1.30 $ $Date 10-Jan-2000 16:41:04 $
%             listbox option added.
%             Option for disabling checkboxes\radiobuttons by changing checkboxes\radiobuttons status added.

%%%%%%%%%%%%%%%%%%%%%
%%% General Info. %%%
%%%%%%%%%%%%%%%%%%%%%
Black      =[0       0        0      ]/255;
LightGray  =[192     192      192    ]/255;
LightGray2 =[160     160      164    ]/255;
MediumGray =[128     128      128    ]/255;
White      =[255     255      255    ]/255;
OnOff = {'on','off'};
FigWidth=160;FigHeight=100;
%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%

if nargout>3,error('Wrong number of output arguments for INPUTDLG');end
if nargin<1,error('Too few arguments for INPUTDLG');end

if iscell(Prompt)		% see else on line(933) for uicontrol callbacks
   
if nargin==1,
  Title=' ';
end

if nargin<=2, NumLines=1;end

if ~iscell(Prompt),
  Prompt={Prompt};
end

NumQuest=prod(size(Prompt));    
QperC = ceil(NumQuest/3);
if(QperC < 3),
   FigWidth=192;
   QperC = ceil(NumQuest/2);
   if(QperC < 3),
      QperC = NumQuest;
   end
end
NumQC = ceil(NumQuest/max(QperC,1));

if nargin<=3, 
  DefAns=cell(NumQuest,1);
  for lp=1:NumQuest, DefAns{lp}=''; end
end

if nargin<=4, PromptDef = zeros(2,NumQuest); end
if isempty(PromptDef), PromptDef = zeros(2,NumQuest); end
if (size(PromptDef,1)<2), PromptDef(2,1:NumQuest) = 0; end
if size(PromptDef,2)~=NumQuest,
  error('PopFlg must be of the same length as Prompt.');  
end

if nargin<=5, 
   AnsFlg1 = [];
   NumFrms = 0;
else,
   NumFrms = prod(size(AnsFlg1));
end
FperC = ceil(NumFrms/2);
if(NumFrms < 4),
   FigWidth=192;
   FperC = NumFrms;
end
NumFC = ceil(NumFrms/max(FperC,1));

WindowStyle='modal';
Interpreter='none';
if nargin<=6,
  Resize = 'off';
end

if nargin==7 & isstruct(Resize),
  Interpreter=Resize.Interpreter;
  WindowStyle=Resize.WindowStyle;
  Resize=Resize.Resize;
end

if strcmp(Resize,'on'),
  WindowStyle='normal';
end

LBNum = length(find(PromptDef(1,:) < 0));
if (nargin<8),
   ListInit = num2cell(ones(1,LBNum));
elseif(LBNum>length(ListInit)),
   [ListInit{length(ListInit)+1:LBNum}] = deal(1);
end

if nargin>8,error('Too many input arguments');end

% Backwards Compatibility
if isstr(NumLines),
  warning(['Please see the INPUTDLG help for correct input syntax.' 10 ...
           '         OKCallback no longer supported.' ]);
  NumLines=1;
end

[rw,cl]=size(NumLines);
OneVect = ones(NumQuest,1);
if (rw == 1 & cl == 2)
  NumLines=NumLines(OneVect,:);
elseif (rw == 1 & cl == 1)
  NumLines=NumLines(OneVect);
elseif (rw == 1 & cl == NumQuest)
  NumLines = NumLines'
elseif rw ~= NumQuest | cl > 2,
  error('NumLines size is incorrect.')
end

if ~iscell(DefAns),
  error('Default Answer must be a cell array in INPUTDLG.');  
end
if length(DefAns)~=NumQuest,
  error('Default Answer must be of the same length as Prompt.');  
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% Create InputFig %%%
%%%%%%%%%%%%%%%%%%%%%%%
FigPos(3:4)=[FigWidth FigHeight];
FigColor=get(0,'Defaultuicontrolbackgroundcolor');
InpFig=dialog(                               ...
               'Visible'         ,'off'      , ...
               'Name'            ,Title      , ...
               'Pointer'         ,'arrow'    , ...
               'Units'           ,'points'   , ...
               'UserData'        ,''         , ...
               'Tag'             ,Title      , ...
               'HandleVisibility','on'       , ...
               'Color'           ,FigColor   , ...
               'NextPlot'        ,'add'      , ...
               'WindowStyle'     ,WindowStyle, ...
               'Resize'          ,Resize       ...
               );
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Default UIControl properties %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DefOffset=5;
SmallOffset=2;

DefBtnWidth=50;
BtnHeight=20;
BtnYOffset=DefOffset;
BtnFontSize=get(0,'FactoryUIControlFontSize');
BtnWidth=DefBtnWidth;
TxtBackClr=FigColor;
TxtForeClr=Black;

TextInfo.Units              ='points'   ;   
TextInfo.FontSize           =BtnFontSize;
TextInfo.HorizontalAlignment='left'     ;
TextInfo.HandleVisibility   ='callback' ;

StInfo=TextInfo;
StInfo.Style              ='text'     ;
StInfo.BackgroundColor    =TxtBackClr ;
StInfo.ForegroundColor    =TxtForeClr ;

TextInfo.VerticalAlignment='bottom';

EdInfo=StInfo;
EdInfo.Style='edit';
EdInfo.HorizontalAlignment='left';
EdInfo.BackgroundColor=White;

BtnInfo=StInfo;
BtnInfo.Style='pushbutton';
BtnInfo.HorizontalAlignment='center';

ChkInfo=StInfo;
ChkInfo.Style='checkbox';

RadInfo=StInfo;
RadInfo.Style='radio';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Quest properties %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine # of lines for all Prompts
ExtControl=uicontrol(StInfo, ...
              'String'   ,''         , ...    
              'Position' ,[DefOffset                  DefOffset   ...
                          0.96*(FigWidth-2*DefOffset) BtnHeight], ...
              'Visible'  ,'off'         ...
                     );
ExtEdtControl=uicontrol(EdInfo,   ...
              'Position' ,[DefOffset                  DefOffset   ...
                          0.96*(FigWidth-2*DefOffset) BtnHeight], ...
              'String'	, '',	...    
              'Max'		, 1, 	...
              'Visible'	,'off');
                     
WrapQuest=cell(NumQuest,1);
QuestPos=zeros(NumQuest,4);
EditPos=zeros(NumQuest,4);
QuestHeight=zeros(NumQuest,1);
QuestWidth=zeros(NumQuest,1);

for ExtLp=1:NumQuest,
   [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
      textwrap(ExtControl,Prompt(ExtLp));
%  if size(NumLines,2)==2
%    [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
%        textwrap(ExtControl,Prompt(ExtLp),NumLines(ExtLp,2));
%  end

   if ((size(NumLines,2)==2)&(NumLines(ExtLp,2))),
      set(ExtEdtControl, ...
          'String'	,char(ones(NumLines(ExtLp,:))*'x'),  ...    
          'Max'		,NumLines(ExtLp,1));
   else,
      tmpExtEdt =[];
      if(ischar(DefAns{ExtLp}))
         nmlin = length(findstr(DefAns{ExtLp},'|'));
         if(nmlin)
            tmpExtEdt = cell(1,nmlin+1);
            token = DefAns{ExtLp};
         	for it1=1:nmlin+1,
            	[tmpExtEdt{it1},token] = strtok(token,'|');
         	end
     		end
      end
      if(isempty(tmpExtEdt))
      	tmpExtEdt = DefAns{ExtLp};
      end
      if(PromptDef(1,ExtLp) ~= 0),
         tmpExtEdt{1} = char(repmat(88,1,1+size(char(tmpExtEdt),2)));
      end
      if(NumLines(ExtLp,1)>1 & NumLines(ExtLp,1)<length(tmpExtEdt)+2), 
         tmpExtEdt(NumLines(ExtLp,1)+2:end) = [];
      end
      set(ExtEdtControl, ...
          'String'	,tmpExtEdt,  ...    
          'Max'		,NumLines(ExtLp,1));
   end
   EditPos(ExtLp,1:4) = get(ExtEdtControl,'Extent');

end % for ExtLp
delete(ExtEdtControl);

TxtHeight = 0;
QuestHeight=QuestPos(:,4);
QuestWidth=QuestPos(:,3);
TxtForeClr=Black;
TxtBackClr=get(InpFig,'Color');
MaxQuestWidth = zeros(1,3);
ColHeight = zeros(1,3);
TxtXOffset = zeros(1,3);
if(NumQuest),
   MaxQuestWidth(1,1) = min(FigWidth-2*DefOffset, ...
      max(QuestWidth(1:QperC)));
   if(NumQuest>4),
      MaxQuestWidth(1,2) = min(FigWidth-2*DefOffset, ...
         max(QuestWidth(QperC+1:min(2*QperC,NumQuest))));
      if(NumQuest>6),
         MaxQuestWidth(1,3) = min(FigWidth-2*DefOffset, ...
            max(QuestWidth(2*QperC+1:NumQuest)));
      end
   end
   MaxQuestHeight(1,1:3) = max(QuestHeight./cellfun('size',WrapQuest,1));

   EdWidth=EditPos(:,3) + 9;

   EdHeight=EditPos(:,4);
   Not1Liners = find(NumLines(:,1)~=1);
   EdHeight(Not1Liners)=EdHeight(Not1Liners)+SmallOffset;

   MaxQuestWidth(1,1) = max(MaxQuestWidth(1,1),max(EdWidth(1:QperC)));
   if(NumQuest>4),
      MaxQuestWidth(1,2) = max(MaxQuestWidth(1,2), ...
         max(EdWidth(QperC+1:min(2*QperC,NumQuest))));
      if(NumQuest>6),
         MaxQuestWidth(1,3) = max(MaxQuestWidth(1,3), ...
            max(EdWidth(2*QperC+1:NumQuest)));
      end
   end

   MaxEditHeight=max(EdHeight./NumLines(:,1));
   TxtHeight=max(MaxEditHeight, MaxQuestHeight);

   TxtXOffset(1,1)=DefOffset;
   if(NumQuest>4), 
      TxtXOffset(1,2)=TxtXOffset(1,1)+2*DefOffset+MaxQuestWidth(1,1); 
   end
   if(NumQuest>6), 
      TxtXOffset(1,3)=TxtXOffset(1,2)+2*DefOffset+MaxQuestWidth(1,2); 
   end

   ColHeight(1,1)= (1+QperC)*(DefOffset+SmallOffset) + ...
       sum(EdHeight(1:QperC)) + sum(QuestHeight(1:QperC));
   if(NumQuest>4),
      ColHeight(1,2)=(1+min(QperC,NumQuest-QperC))*(DefOffset+SmallOffset) + ...
         sum(EdHeight(QperC+1:min(2*QperC,NumQuest))) + ...
         sum(QuestHeight(QperC+1:min(2*QperC,NumQuest)));
      if(NumQuest>6),
         ColHeight(1,3)=(1+NumQuest-2*QperC)*(DefOffset+SmallOffset) + ...
            sum(EdHeight(2*QperC+1:NumQuest)) + ...
            sum(QuestHeight(2*QperC+1:NumQuest));
      end
   end
end

FigWidth=max(FigWidth, sum(MaxQuestWidth) + ...
             2*NumQC*DefOffset); 
FigHeight= DefOffset+BtnHeight+max(ColHeight);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Frames properties %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(NumFrms),
   MaxChkInFrm = 10;
   ChkWidth=128;
   set(ExtControl, ...
              'Position' ,[DefOffset	DefOffset  ...
                          ChkWidth 		BtnHeight] ...
      );
                  
   ExtChkControl=uicontrol(ChkInfo,   ...
              'Position' ,[DefOffset                  DefOffset   ...
                          0.96*(FigWidth-2*DefOffset) BtnHeight], ...
              'String'	, '',	...    
              'Max'		, 1, 	...
              'Value'	, 1, 	...
              'Visible'	,'off');
                     
   WrapChk  = cell(NumFrms,1);
   FrmTags  = cell(NumFrms,1);
   VarFlg   = cell(NumFrms,1);
   VarTag   = cell(NumFrms,1);
   VarEna   = cell(NumFrms,1);
   ChkPos   = cell(NumFrms,1);
   EnQdat   = cell(NumFrms,1);
   FrmTagsPos = zeros(NumFrms,4);
   FrmsPos   = zeros(NumFrms,4);
   NumChks = zeros(NumFrms,1);
   
   for ExtLp=1:NumFrms,
      if(isempty(AnsFlg1{ExtLp})),
         error(['AnsFlg1{',num2str(ExtLp),'} is empty.']); 
      end
      tmpVarFlg = fieldnames(AnsFlg1{ExtLp});
      FrmTags{ExtLp} = getfield(AnsFlg1{ExtLp},'Frm_Nam');
      
      if(strcmp(tmpVarFlg{end},'En_Quest')),
         EnQdat{ExtLp} = getfield(AnsFlg1{ExtLp},'En_Quest');
         VarFlg{ExtLp} =  {tmpVarFlg{3:end-1}}';
         VarTag{ExtLp} =  VarFlg{ExtLp};
      else,
         VarFlg{ExtLp} =  {tmpVarFlg{3:end}}';
         VarTag{ExtLp} =  VarFlg{ExtLp};
      end
      
      [WrapChk{ExtLp},FrmTagsPos(ExtLp,1:4)]= ...
         textwrap(ExtControl,FrmTags(ExtLp));
   
      NumChks(ExtLp) = length(VarFlg{ExtLp});
      [VarEna{ExtLp}(1:NumChks(ExtLp))] =  deal(cellstr('on'));
      if(~isempty(EnQdat{ExtLp}))
         tmp = length(EnQdat{ExtLp});
         if(tmp < NumChks(ExtLp))
            EnQdat{ExtLp}{NumChks(ExtLp),1} = [];
         elseif(tmp > NumChks(ExtLp))
         	error(['AnsFlg1{',num2str(ExtLp),'}.EnQdat has more En\Disable Defs than checks.']); 
         end
         tmpvec = [EnQdat{ExtLp}{:}];
         if(max(tmpvec(find(tmpvec<100))) > NumQuest )
            error(['AnsFlg1{',num2str(ExtLp),'}.EnQdat has Quest values greater than Num of Quests.']); 
         end 
         if(max(tmpvec(find(tmpvec>100))) > (NumFrms+1)*100 )
            error(['AnsFlg1{',num2str(ExtLp),'}.EnQdat has Frame values greater than Num of Frames.']); 
         end 
      end
      
      if(strcmp(AnsFlg1{ExtLp}.typ,'rad')),
         radchk = 0;
         for ChkLp=1:NumChks(ExtLp),
         	VarTmp23 = [];
            eval(strcat('if (length(AnsFlg1{ExtLp}.', VarFlg{ExtLp}{ChkLp}, ')>1),', ...
               'VarTmp23 = AnsFlg1{ExtLp}.', VarFlg{ExtLp}{ChkLp}, '(2:end);end'));
            if(~isempty(VarTmp23)),
               if(ischar(VarTmp23{1})),
                  VarTag{ExtLp}{ChkLp} = VarTmp23{1};
               else
				      VarEna{ExtLp}{ChkLp} =  OnOff{VarTmp23{1}+1};
               end
               if(length(VarTmp23)>1),
                  if(ischar(VarTmp23{2})),
                  	VarTag{ExtLp}{ChkLp} = VarTmp23{2};
               	else
				      	VarEna{ExtLp}{ChkLp} =  OnOff{VarTmp23{2}+1};
	               end
               end
            end
            eval(strcat('if (iscell(AnsFlg1{ExtLp}.', VarFlg{ExtLp}{ChkLp}, ')),', ...
               'VarFlg{ExtLp}{ChkLp}=[VarFlg{ExtLp}{ChkLp} ''{1}''];end'));
            								% for compatibility with ver < 1.22
            radchk = radchk + eval(['AnsFlg1{ExtLp}.' VarFlg{ExtLp}{ChkLp}]);
            set(ExtChkControl, 'String', VarTag{ExtLp}{ChkLp});
   	      ChkPos{ExtLp}(ChkLp,1:4) = get(ExtChkControl,'Extent');
         end % for ChkLp
        	if(radchk ~= 1),
           	warning(['1 and only 1 radio button must be on!', 10, ...
              	'         ', VarFlg{ExtLp}{1}, ' set on.' ]);
           	expr = strcat('AnsFlg1{ExtLp}.', VarFlg{ExtLp}(2:end),'{1}=0;');
           	eval(strcat(expr{:}));
           	expr = strcat('AnsFlg1{ExtLp}.', VarFlg{ExtLp}(1),'{1}=1;');
           	eval(strcat(expr{:}));
        	end
      else			% chkboxes     
         for ChkLp=1:NumChks(ExtLp),
            VarTmp23 = [];
            eval(strcat('if (length(AnsFlg1{ExtLp}.', VarFlg{ExtLp}{ChkLp}, ')>1),', ...
               'VarTmp23 = AnsFlg1{ExtLp}.', VarFlg{ExtLp}{ChkLp}, '(2:end);end'));
            if(~isempty(VarTmp23)),
               if(ischar(VarTmp23{1})),
                  VarTag{ExtLp}{ChkLp} = VarTmp23{1};
               else
				      VarEna{ExtLp}{ChkLp} =  OnOff{VarTmp23{1}+1};
               end
               if(length(VarTmp23)>1),
                  if(ischar(VarTmp23{2})),
                  	VarTag{ExtLp}{ChkLp} = VarTmp23{2};
               	else
				      	VarEna{ExtLp}{ChkLp} =  OnOff{VarTmp23{2}+1};
	               end
               end
            end
            eval(strcat('if (iscell(AnsFlg1{ExtLp}.', VarFlg{ExtLp}{ChkLp}, ')),', ...
               'VarFlg{ExtLp}{ChkLp}=[VarFlg{ExtLp}{ChkLp} ''{1}''];end'));
            								% for compatibility with ver < 1.22
	         set(ExtChkControl, 'String', VarTag{ExtLp}{ChkLp});
  		      ChkPos{ExtLp}(ChkLp,1:4) = get(ExtChkControl,'Extent');
   	   end % for ChkLp
		end
         
      ChkPos{ExtLp}(:,3) = ChkPos{ExtLp}(:,3) + 16;
      FrmsPos(ExtLp,4) = sum(ChkPos{ExtLp}(:,4)) + ...
         (NumChks(ExtLp)+1)*SmallOffset;
      FrmsPos(ExtLp,3) = max(ChkPos{ExtLp}(:,3)) + 2*DefOffset;
   end % for ExtLp
   
   delete(ExtChkControl);
   
   FrmsPos(1:FperC,3) = deal(max(FrmsPos(1:FperC,3)));
   FrmsPos((1+FperC):NumFrms,3) = deal(max(FrmsPos((1+FperC):NumFrms,3)));
   
   MaxFrmWidth  = zeros(1,2);
   SumFrmHeight = zeros(1,2);
   MaxFrmWidth(1,1) = max(max(FrmTagsPos(1:FperC,3)), ...
      max(FrmsPos(1:FperC,3)));
   SumFrmHeight(1,1) = sum(FrmsPos(1:FperC,4))+sum(FrmTagsPos(1:FperC,4))+...
                      +(FperC-1)*(DefOffset+SmallOffset);
   if(NumFrms>FperC),
      MaxFrmWidth(1,2) = max(max(FrmTagsPos((FperC+1):NumFrms,3)), ...
         max(FrmsPos((FperC+1):NumFrms,3)));
      SumFrmHeight(1,2)= sum(FrmsPos((FperC+1):NumFrms,4)) ...
                        + sum(FrmTagsPos((FperC+1):NumFrms,4))+...
                        +(NumFrms-FperC-1)*(DefOffset+SmallOffset);
   end
   SumFrmHgt=max(SumFrmHeight);
   FigHeight = FigHeight-BtnHeight+SumFrmHgt;
   FigWidth=max(FigWidth, sum(MaxFrmWidth)+6*DefOffset+BtnWidth);
end % for Frames
   
delete(ExtControl);

Temp=get(0,'Units');
set(0,'Units','points');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',Temp);

FigPos(1)=(ScreenSize(3)-FigWidth)/2;
FigPos(2)=(ScreenSize(4)-FigHeight)/2;
FigPos(3)=FigWidth;
FigPos(4)=FigHeight;
set(InpFig,'Position',FigPos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Quest positions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(NumQuest),
   QuestYOffset=zeros(NumQuest,1);
   EditYOffset=zeros(NumQuest,1);
   
   for YOffLp=1:NumQuest,
      if((mod(YOffLp,QperC)==1)|(NumQuest==1)),
         QuestYOffset(YOffLp)=FigHeight-SmallOffset-QuestHeight(YOffLp);
         EditYOffset(YOffLp) =QuestYOffset(YOffLp)-EdHeight(YOffLp)-SmallOffset;
      else
         QuestYOffset(YOffLp)=EditYOffset(YOffLp-1)-QuestHeight(YOffLp)-DefOffset;
         EditYOffset(YOffLp)=QuestYOffset(YOffLp)-EdHeight(YOffLp)-SmallOffset;
      end
   end % for YOffLp
   EditYEdg = FigHeight - max(ColHeight);
   BtnSep = max(DefOffset, (FigWidth-2*BtnWidth)/3);
   CancPos = [ BtnSep DefOffset BtnWidth BtnHeight];
   OKPos   = [ FigWidth-BtnWidth-BtnSep DefOffset BtnWidth BtnHeight];
else,
   EditYEdg = FigHeight-SmallOffset;
end % for NumQuest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Frames positions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(NumFrms),
   FrmsYOffset=zeros(NumFrms,1);
   
   FrmsSep = max(DefOffset, ...
      (FigWidth-sum(MaxFrmWidth)-BtnWidth)/(NumFC+2));
   FrmsC1Wid = 2*FrmsSep+MaxFrmWidth(:,1);
   if(NumFC+1==NumQC),
      FrmsSep = DefOffset;
      FrmsC1Wid = TxtXOffset(1,2);
   end
         
   for YOffLp=1:NumFrms,
      if(YOffLp>FperC),
         ChkPos{YOffLp}(:,1) = FrmsC1Wid+DefOffset;
      else
         ChkPos{YOffLp}(:,1) = FrmsSep+DefOffset;
      end
      if(mod(YOffLp,FperC)==1 | YOffLp==1),
         FrmsYOffset(YOffLp)=EditYEdg - FrmsPos(YOffLp,4) ...
                                      - FrmTagsPos(YOffLp,4);
         ChkPos{YOffLp}(1,2) = FrmsYOffset(YOffLp)+ FrmsPos(YOffLp,4) ...
            - ChkPos{YOffLp}(1,4) - SmallOffset;
         for ChkLp=2:NumChks(YOffLp),
            ChkPos{YOffLp}(ChkLp,2) = ChkPos{YOffLp}(ChkLp-1,2) ...
               - ChkPos{YOffLp}(ChkLp,4) - SmallOffset;
         end % for ChkLp
      else
         FrmsYOffset(YOffLp)=FrmsYOffset(YOffLp-1)-FrmsPos(YOffLp,4) ...
            - FrmTagsPos(YOffLp,4) - DefOffset - SmallOffset;
         ChkPos{YOffLp}(1,2) = FrmsYOffset(YOffLp)+ FrmsPos(YOffLp,4) ...
            - ChkPos{YOffLp}(1,4) - SmallOffset;
         for ChkLp=2:NumChks(YOffLp),
            ChkPos{YOffLp}(ChkLp,2) = ChkPos{YOffLp}(ChkLp-1,2) ...
               - ChkPos{YOffLp}(ChkLp,4) - SmallOffset;
         end % for ChkLp
      end
   end % for YOffLp
   
   FrmsPos(:,2) = FrmsYOffset;
   
   FrmsPos(1:FperC,1) = deal(FrmsSep);
   FrmsPos((1+FperC):NumFrms,1) = FrmsC1Wid;
   
   FrmTagsPos(:,1:2) = [FrmTagsPos(:,1)+FrmsPos(:,1)-SmallOffset ...
         FrmsPos(:,2)+FrmsPos(:,4)+SmallOffset];
   BtnYOffset = (EditYEdg-2*BtnHeight)/3;
   
   ButtXOffset = (FigWidth+sum(MaxFrmWidth)+(NumFC+1)*FrmsSep-BtnWidth)/2;
   if(NumFC+1==NumQC),
      ButtXOffset = TxtXOffset(1,NumQC)+4*DefOffset;
   end
   CancPos = [ButtXOffset BtnHeight+2*BtnYOffset BtnWidth BtnHeight];
   OKPos   = [ButtXOffset BtnYOffset BtnWidth BtnHeight];
end % for Frames

%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup Quests     %%%
%%%%%%%%%%%%%%%%%%%%%%%%
QuestHandle=[];
EditHandle=[];

AxesHandle=axes('Parent',InpFig,'Position',[0 0 1 1],'Visible','off');
for lp=1:NumQuest,
  QuestTag=['Prompt' num2str(lp)];
  EditTag=['Edit' num2str(lp)];
  if (~ischar(DefAns{lp})&~iscell(DefAns{lp})),
    delete(InpFig);
    error('Default answers must be strings in INPUTDLG.');
  end
  QuestHandle(lp)=text('Parent',AxesHandle, ...
                        TextInfo     , ...
                        'Position'   ,[ TxtXOffset(1,ceil(lp/QperC)) ...
                                        QuestYOffset(lp)], ...
                        'String'     ,WrapQuest{lp}                 , ...
                        'Interpreter',Interpreter                   , ...
                        'Tag'        ,QuestTag                        ...
                        );

  EditHandle(lp)=uicontrol(InpFig   ,EdInfo     , ...
                          'Max'       ,NumLines(lp,1)       , ...
                          'Position'  ,[ TxtXOffset(1,ceil(lp/QperC)) ...
                                         EditYOffset(lp) ...
                                         EdWidth(lp)   EdHeight(lp) ], ...
                          'String'    ,DefAns{lp}           , ...
                          'UserData'  ,'En_Quests', ...            
                          'Tag'       ,EditTag );
  if(PromptDef(1,lp) > 0),
     set(EditHandle(lp), 'style', 'popup', 'value', PromptDef(1,lp) );
  elseif(PromptDef(1,lp) < 0),
	  if(PromptDef(2,lp) > +1),
        set(EditHandle(lp), 'Min', NumLines(lp,1)-1);
        if(length(ListInit{abs(PromptDef(1,lp))})>1),
           warning(['Prompt{', num2str(lp), '} - Multiple initial selection for ', ...
                 'single selection ListBox!', 10, blanks(9),'only first selection taken.' ]);
           ListInit{abs(PromptDef(1,lp))} = ListInit{abs(PromptDef(1,lp))}(1);
        end
        if(PromptDef(2,lp) > +2),
   		  set(EditHandle(lp), 'Enable', 'off', 'BackgroundColor',LightGray);
		  end
	  end
     set(EditHandle(lp), 'style', 'list', 'value', ListInit{abs(PromptDef(1,lp))} );
  end   
  if(PromptDef(2,lp) == +1),
     set(EditHandle(lp), 'Enable', 'off', 'BackgroundColor',LightGray);
  end
                    
end % for lp

%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup Frames     %%%
%%%%%%%%%%%%%%%%%%%%%%%%
if(NumFrms),
   FrmsHandle    = zeros(NumFrms,1);
   FrmsTagHandle = zeros(NumFrms,1);
   SerChkNum = 1;
   TotNumChk = sum(NumChks);
   FrmChkHandle=zeros(TotNumChk,1);
   
   for lp=1:NumFrms,
     FSTTag=['FrameTag' num2str(lp)];
     FrmsHandle(lp)=uicontrol(InpFig, ...
                        'Style', 'frame'  , ...
                        'Units', 'points'  , ...
                        'Position'   , FrmsPos(lp,1:4), ...
                        'ForegroundColor'	,MediumGray, ...
                        'Tag'        ,FSTTag ...
                         );
                         
     FrmsTagHandle(lp)=text('Parent', 		AxesHandle,  ...
                           TextInfo, ...
                           'Position', 	FrmTagsPos(lp,1:2), ...
                           'String',		WrapChk{lp}, ... 
                           'Interpreter',	Interpreter, ...
                           'Tag',			FSTTag       ...
                           );
     for ChkLp=1:NumChks(lp),
        ChkVar = ['AnsFlg1{' num2str(lp) '}.' VarFlg{lp}{ChkLp}];
        EnQ = []; EnF = [];
        if(~isempty(EnQdat{lp}) & length(EnQdat{lp}{ChkLp}))
           EnQ = EnQdat{lp}{ChkLp}(find(EnQdat{lp}{ChkLp}<100));
           EnF = EnQdat{lp}{ChkLp}(find(EnQdat{lp}{ChkLp}>100));
           for it3=1:length(EnF),
              if(mod(EnF(it3),100) > NumChks(floor(EnF(it3)./100))),
                 error([9 'AnsFlg1{',num2str(lp) '}.EnQdat{' num2str(ChkLp) ...
                       '} = ' num2str(EnF(it3)) 10 9 'Frame{' mod(EnF(it3),100) '} has only ' ...
                       num2str(NumChks(floor(EnF(it3)./100))) ' items.']); 
              end
           end
        end
        N_EnQ = length(EnQ);
        N_EnF = length(EnF);
        userdat = zeros(max([N_EnQ,N_EnF]),2);
        userdat(1:N_EnF,1) = EnF';
        userdat(1:N_EnQ,2) = EditHandle(EnQ)';
        if(strcmp(AnsFlg1{lp}.typ,'chk')),
           FrmChkHandle(SerChkNum) = ...
              uicontrol(InpFig, ChkInfo,   ...
                     'Position' ,ChkPos{lp}(ChkLp,1:4), ...
                     'String'	, VarTag{lp}{ChkLp},	... 
                     'Value'	, eval(ChkVar), 	...
                     'Enable'	, VarEna{lp}{ChkLp},	... 
                     'UserData', userdat, 	...
                     'Callback', 'inpdlg(1)'    , ...
                     'Tag'	   , ChkVar 	...
                  );
        elseif(strcmp(AnsFlg1{lp}.typ,'rad')),
           FrmChkHandle(SerChkNum) = ...
              uicontrol(InpFig, RadInfo,   ...
                     'Position' ,ChkPos{lp}(ChkLp,1:4), ...
                     'String'	, VarTag{lp}{ChkLp},	... 
                     'Value'	, eval(ChkVar), 	...
                     'Enable'	, VarEna{lp}{ChkLp},	... 
                     'UserData', userdat, 	...
                     'Callback'  ,'inpdlg(0)'    , ...
                     'Tag'	   , ChkVar 	...
                  );
        else
           error('AnsFlg1{lp}.typ must be ''rad''\''chk''.');  
        end            
        SerChkNum = SerChkNum+1;     
     end % for ChkLp
     FrmUserDat = [FrmChkHandle(SerChkNum-NumChks(lp):SerChkNum-1)]';
     set(FrmsHandle(lp),'UserData',FrmUserDat);
     
  end % for lp
end % for Frames

CBString='set(gcbf,''UserData'',''Cancel'');uiresume';
CancelHandle=uicontrol(InpFig   ,              ...
                      BtnInfo     , ...
                      'Position'  ,CancPos     , ...
                      'String'    ,'Cancel'    , ...
                      'Callback'  ,CBString    , ...
                      'Tag'       ,'Cancel'      ...
                      );
                                   
CBString='set(gcbf,''UserData'',''OK'');uiresume';
OKHandle=uicontrol(InpFig    ,              ...
                   BtnInfo     , ...
                   'Position'  ,OKPos       , ...
                   'String'     ,'OK'        , ...
                   'Callback'   ,CBString    , ...
                   'Tag'        ,'OK'          ...
                  );
    
Data.OKHandle = OKHandle;
Data.CancelHandle = CancelHandle;
Data.EditHandles = EditHandle;
Data.QuestHandles = QuestHandle;
Data.LineInfo = NumLines;
Data.ButtonWidth = BtnWidth;
Data.ButtonHeight = BtnHeight;
Data.EditHeight = TxtHeight+4;
Data.Offset = DefOffset;
set(InpFig ,'Visible','on','UserData',Data);
% This drawnow is a hack to work around a bug
drawnow
set(findall(InpFig),'Units','normalized','HandleVisibility','callback');
set(InpFig,'Units','points')
uiwait(InpFig);

TempHide=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

if any(get(0,'Children')==InpFig),
  figfmen = []; 
  Answer={};
  if strcmp(get(InpFig,'UserData'),'OK'),
    if(NumQuest), 
       Answer=cell(NumQuest,1);
       Answer(:)=get(EditHandle(:),{'String'});
       for PopsInd = [find(PromptDef(1,:) > 0)],			% PopUp Box
          Answer(PopsInd)=cellstr(Answer{PopsInd}...
             (get(EditHandle(PopsInd),'Value'),:));
       end
       for PopsInd = [find(PromptDef(1,:) < 0)],			% List Box
          Answer{PopsInd}=cellstr(Answer{PopsInd}...
             (get(EditHandle(PopsInd),'Value'),:));
       end
    end % NumQuest
                                        
    if(NumFrms), 
       [eqw{1:TotNumChk,1}] = deal(' = 0;');
       chkval = get(FrmChkHandle(:),'Value') ;
       if(iscell(chkval)), chkval=cat(1,chkval{:});end
       if (any(chkval)),
          [eqw{find(chkval==1),1}] = deal(' = 1;');
       end
       expr = strcat(get(FrmChkHandle(:),'Tag'), eqw);
       eval(strcat(expr{:}));
    end % NumFrms
    figfmen = InpFig;
  end % if strcmp
  delete(InpFig);
else,
  figfmen = -1;
  Answer={};
end % if any

set(0,'ShowHiddenHandles',TempHide);
return;

else		% for line(177): if iscell(Prompt)
   
   tmpEnstr = 'off';
   BGColor = LightGray;
   switch Prompt

   case 0  % Radio buttons callback
      dat = get(gcbo,{'tag','userdata'});
      [tag,usdat] = deal(dat{:});
      N_Frm = findstr(tag,'{');
      [N_Frm, count]  = sscanf(tag,[tag(1:N_Frm) '%d'],1);
      if(count==1),
         H_Frm = findobj(get(gcbo,'parent'), 'style', 'frame', ...
            'Tag', ['FrameTag' num2str(N_Frm)]);
         usdat6 = get(H_Frm, 'userdata');
			usdat6(find(usdat6==gcbo )) = [];	% Handles of neighboring radio buttons 
	      set(usdat6,'value',0);
         
         usdat4 = get(usdat6,'userdata');
   	   if(~iscell(usdat4)), usdat4={usdat4}; end
         usdat5 = cat(1,usdat4{:});
  	      usdat5F = usdat5(find(usdat5(:,1)>0),1);
  	      usdat5Q = usdat5(find(usdat5(:,2)>0),2);
         set(usdat5Q, 'Enable', 'Off', 'BackgroundColor',BGColor);       
	      if(~isempty(usdat5F)),
   	   	tmpus = zeros(length(usdat5F),2);
      		tmpus(:,1) = mod(usdat5F,100);
      		tmpus(:,2) = (usdat5F-tmpus(:,1))*0.01;
	         H_Frms = findobj(get(gcbo,'parent'),'style','frame');
   	      for it4 = 1:length(usdat5F),
      	      H_Frm = findobj(H_Frms, 'Tag', ['FrameTag' num2str(tmpus(it4,2))]);
         	   usdat7 = get(H_Frm, 'userdata');
	   	   	set(usdat7(tmpus(it4,1)), 'Enable', 'Off');
		      end
   	   end
         
         set(gcbo,'value',1);
         set(usdat(find(usdat(:,2)>0),2),'Enable','On','BackgroundColor',White);       
  	      usdat5F = usdat(find(usdat(:,1)>0),1);
         if(~isempty(usdat5F)),
   	   	tmpus = zeros(length(usdat5F),2);
      		tmpus(:,1) = mod(usdat5F,100);
      		tmpus(:,2) = (usdat5F-tmpus(:,1))*0.01;
	         H_Frms = findobj(get(gcbo,'parent'),'style','frame');
   	      for it4 = 1:length(usdat5F),
      	      H_Frm = findobj(H_Frms, 'Tag', ['FrameTag' num2str(tmpus(it4,2))]);
         	   usdat7 = get(H_Frm, 'userdata');
	   	   	set(usdat7(tmpus(it4,1)), 'Enable', 'On');
		      end
   	   end
      else
			error([tag ': callback failed.']);
      end
      
   case 1  % Check Box callback
      usdat = get(gcbo,'userdata');
      itm = get(gcbo,'value');
      if(itm),
         tmpEnstr = 'on';
 		   BGColor = White;
      end
      usdat2 = usdat(find(usdat(:,2)>0),2);
      set(usdat2, 'Enable', tmpEnstr, 'BackgroundColor', BGColor);
      usdat2 = usdat(find(usdat(:,1)>0),1);
      if(~isempty(usdat2)),
      	tmpus = zeros(length(usdat2),2);
      	tmpus(:,1) = mod(usdat2,100);
      	tmpus(:,2) = (usdat2-tmpus(:,1))*0.01;
         H_Frms = findobj(get(gcbo,'parent'),'style','frame');
         for it4 = 1:length(usdat2),
            H_Frm = findobj(H_Frms, 'Tag', ['FrameTag' num2str(tmpus(it4,2))]);
            usdat6 = get(H_Frm, 'userdata');
	   	   set(usdat6(tmpus(it4,1)), 'Enable', OnOff{2-itm});
	      end
      end
       
   otherwise  
      error('Implemented only for inpdlg callbacks 0-1');
       
   end

end
