unit WLC;
{Window Library Controls
 LICENSE: GPLv2
 PROGRAMMER: Burshtin Nikolay - amber8706@mail.ru
 OS: Windows
}

{
 Minimal visual library that uses the principle of template layout of controls.

 Supported 5 "basic" controls type (the symbol for template is shown in brackets):

 EDIT (E, e) ( with(out) multiline )
 BUTTON (B, b)
 RADIOBUTTON (R, r)
 CHECKBOX (C, c)
 STATIC (S, s)
}

interface
uses Windows, Messages, SysUtils;

type TEvent=procedure(Sender: TObject);
     TEventClose=procedure(Sender: TObject; var Free:Boolean);
     TEventMessage=procedure(Sender: TObject; msg:UINT; wParam:WPARAM; lParam:LPARAM; var Result: LRESULT; var Handled: Boolean);
     TWndProc=function (hWnd:HWND; msg:UINT; wParam:WPARAM; lParam:LPARAM ):LRESULT;stdcall;

     TButtonStyle = (bsButton, bsCheckBox, bsRadioButton);
     TTextAlign = (taLeft, taCenter, taRight);

type TWindow=class
 private
   fwc:WNDCLASSEX;
   fwnd:HWND;
   FDefProc:TWndProc;
   FOnClick: TEvent;
   FOnClose: TEventClose;
   FOnMessage: TEventMessage;
   FStoreStyleEx: NativeInt;
   FTag: Integer;
   function GetVisible: Boolean;
   procedure SetVisible(const Value: Boolean);
   function GetCaption: String;
   procedure SetCaption(const Value: String);
   procedure AddToList;
   function GetParent: TWindow;
   procedure SetParent(const Value: TWindow);
   function GetRect(const Index: Integer): Integer;
   procedure SetRect(const Index, Value: Integer);
   function GetEnabled: Boolean;
   procedure SetEnabled(const Value: Boolean);
   procedure DoClick;virtual;
   function GetWindowProc: TWndProc;
   procedure SetWindowProc(const Value: TWndProc);
   function GetWindowStyle: NativeInt;
   procedure SetWindowStyle(const Value: NativeInt);
   function GetFocused: Boolean;
   procedure SetFocused(const Value: Boolean);
   function GetWindowStyleEx: NativeInt;
   procedure SetWindowStyleEx(const Value: NativeInt);
 public
   constructor Create(AClassName:String;ACaption:String='');
   destructor  Destroy; override;
   property Handle:HWND read fwnd;
   property WindowProc:TWndProc read GetWindowProc write SetWindowProc;
   property WindowStyle:NativeInt read GetWindowStyle write SetWindowStyle;
   property WindowStyleEx:NativeInt read GetWindowStyleEx write SetWindowStyleEx;
   property Caption:String read GetCaption write SetCaption;
   property Visible:Boolean read GetVisible write SetVisible default false;
   property Enabled:Boolean read GetEnabled write SetEnabled;
   property Parent:TWindow read GetParent write SetParent;
   property Left:Integer Index 1 read GetRect write SetRect;
   property Top:Integer Index 2 read GetRect write SetRect;
   property Width:Integer Index 3 read GetRect write SetRect;
   property Height:Integer Index 4 read GetRect write SetRect;
   property Focused:Boolean read GetFocused write SetFocused;

   property Tag:Integer read FTag write FTag default 0;

   function GetChild(Index:Integer):TWindow;
   function ChildCount:Integer;
   procedure Click;
   procedure SetCenter; virtual;
   procedure Minimize;
   procedure Maximize;
   procedure Restore;

   property OnClick:TEvent read FOnClick write FOnClick;
   property OnClose:TEventClose read FOnClose write FOnClose;
   property OnMessage:TEventMessage read FOnMessage write FOnMessage;
end;

     TWindowMask = array of array of char;
     TWindowsArray = array of TWindow;

type TStatic=class(TWindow)
 public
   constructor Create(AParent:TWindow=nil;ACaption:String='');
end;

type TButton=class(TWindow)
 private
    FAutoChecked: Boolean;
    FRadioGroup: Byte;
    function GetStyle: TButtonStyle;
    procedure SetStyle(const Value: TButtonStyle);
    function GetChecked: Boolean;
    procedure SetChecked(const Value: Boolean);
    procedure DoClick;override;
    procedure DoCheck;
 public
    property AutoChecked:Boolean read FAutoChecked write FAutoChecked;
    property RadioGroup:Byte read FRadioGroup write FRadioGroup;
    constructor Create(AParent:TWindow=nil;ACaption:String='');
    property Checked:Boolean read GetChecked write SetChecked;
    property Style:TButtonStyle read GetStyle write SetStyle;
end;

type TEdit=class(TWindow)
 private
   FOnChange:TEvent;
   FSaveReadOnly:Boolean;
   procedure DoChange;virtual;
   procedure SetReadOnly(const Value: Boolean);
   function GetMLine: Boolean;//inline;
   procedure SetMLine(const Value: Boolean);
   function GetLineIndex(LineNo: Integer): Integer;
   function GetLineLength(LineNo: Integer): Integer;
   function GetLineCount: Integer;
   function GetAlign: TTextAlign;
   procedure SetAlign(const Value: TTextAlign);
 public
   procedure RecreateWnd(NewStyle :nativeint);
   constructor Create(AParent:TWindow=nil;AText:String='');
   property OnChange:TEvent read FOnChange write FOnChange;
   property Text:String read GetCaption write SetCaption;
   property TextAlign:TTextAlign read GetAlign write SetAlign;
   property MultiLine:Boolean read GetMLine write SetMLine;
   property LineIndex[LineNo:Integer]:Integer read GetLineIndex;//Char no in text from begining line (zero-based)
   property LineLength[LineNo:Integer]:Integer read GetLineLength;
   property LineCount:Integer read GetLineCount;
   function InsertLine(LineNo:Integer;Line:String=''):boolean;
   function ReplaceLine(LineNo:Integer;Line:String=''):boolean;
   function GetLine(LineNo:Integer):String;
   function DeleteLine(LineNo:Integer):boolean;
   property ReadOnly:Boolean read FSaveReadOnly write SetReadOnly default false;
end;

type TWindowList=class
  private
    FList:array of TWindow;
    FMain:TWindow;
    function GetItem(Index: Integer): TWindow;
    Function Delete(Item:TWindow):Boolean;overload;
    {$IF CompilerVersion < 20}
    function GetWindow(ClassName:String):TWindow;
    {$IFEND}
  public
    constructor Create;
    function Find(wnd:HWND): TWindow;overload;
    function Find(ClassName:String): TWindow;overload;
    Function Add(Item:TWindow):Integer;
    Function Delete(Index:Integer;bDestroy:Boolean=false):Boolean;overload;
    Property Items[Index:Integer]:TWindow read GetItem;
    {$IF CompilerVersion < 20}
    Property Windows[ClassName:String]:TWindow read GetWindow;default;
    {$ELSE}
    Property Windows[ClassName:String]:TWindow read Find;default;
    {$IFEND}
    Property MainWindow:TWindow read FMain write FMain;
    Function Count:Integer;
end;

var WindowList:TWindowList;
    stdWidth:  Cardinal;
    stdHeight: Cardinal;


Function CreateWindow(ClassName:String;var Mask: TWindowMask;var Wnds: TWindowsArray;Captions: array of string;MainEvent: array of TEvent;CharSize:Word=22):TWindow;
Procedure CreateMask(Template:array of string; var Mask: TWindowMask);



Procedure Run(TerminateOnEnd:Boolean = true);
Procedure Terminate;
implementation

var AllList:TWindowList;


Function WndProc(hWnd:HWND; msg:UINT; wParam:WPARAM; lParam:LPARAM ):LRESULT;stdcall;
 var wnd:TWindow;
     free:boolean;
     msgRes:LRESULT;
     msgHandled:Boolean;
begin
  Result:=0;
  free:=true;
  wnd:=AllList.Find(hWnd);
  if wnd<>nil then
    if Assigned(wnd.FOnMessage) then
    begin
      msgHandled:=true;msgRes:=0;
      wnd.FOnMessage(wnd,msg,wParam,lParam,msgRes,msgHandled);
      if not msgHandled then
      begin
        Result:=msgRes;
        exit;
      end;
    end;

  if wnd<>nil then
  case msg of
    WM_CLOSE:
    begin
        if Assigned(wnd.FOnClose) then
        begin
          wnd.FOnClose(wnd,free);
          if free then Wnd.Destroy else Wnd.Visible:=false;
        end
        else
        begin
           Wnd.Visible:=false;
           if WindowList.MainWindow=Wnd then Wnd.Destroy;
        end;
    end;

    WM_DESTROY:
    begin
      wnd.Destroy;
    end;

    WM_LBUTTONUP:
    begin
      wnd.DoClick;
    end;

    WM_CHAR:
    begin
      if wnd<>nil then
      begin
        if @wnd.FDefProc<>nil then
        Result:=CallWindowProc(@wnd.FDefProc, hwnd,msg,wparam,lparam) else
        Result:=DefWindowProc(hwnd,msg,wparam,lparam);;
      end
      else
        Result:=DefWindowProc(hwnd,msg,wparam,lparam);

      if wnd is TEdit then
      begin
        if not (wnd as TEdit).ReadOnly then
         (wnd as TEdit).DoChange;
      end;
      exit;
    end;

    WM_SYSCOMMAND:
    begin
      if wnd<>nil then
      if wParam=SC_MINIMIZE then
      begin
        wnd.FStoreStyleEx:= wnd.WindowStyleEx;
        wnd.WindowStyleEx:=0;
      end;
      if wnd<>nil then
      if (wParam=SC_RESTORE)or(wParam=SC_MAXIMIZE) then
        wnd.WindowStyleEx:=wnd.FStoreStyleEx;
    end;
  end;


  if wnd<>nil then
  begin
    if @wnd.FDefProc<>nil then
      Result:=CallWindowProc(@wnd.FDefProc, hwnd,msg,wparam,lparam) else
      Result:=DefWindowProc(hwnd,msg,wparam,lparam);;
  end
  else
    Result:=DefWindowProc(hwnd,msg,wparam,lparam);

end;
{ TWindow }

procedure TWindow.AddToList;
begin
  AllList.Add(Self);
end;

procedure TWindow.Click;
begin
  DoClick;
end;

constructor TWindow.Create(AClassName:String;ACaption:String);
begin
   If ACaption='' then ACaption:=AClassName;

   fwc.cbSize:=sizeof(WNDCLASSEX);
   fwc.style:=CS_HREDRAW or CS_VREDRAW;
   fwc.cbClsExtra:=0;
   fwc.cbWndExtra:=0;
   {$IF CompilerVersion < 20}
   fwc.lpszClassName := PChar(AClassName);
   {$ELSE}
   fwc.lpszClassName := PWChar(AClassName);
   {$IFEND}
   fwc.lpfnWndProc := @WndProc;
 //  fwc.hCursor := LoadCursor(0, IDC_ARROW);
   fwc.hIcon:=LoadIcon(HInstance, 'MAINICON');
   fwc.hIconSm:=LoadIcon(HInstance, 'MAINICON');
   fwc.hbrBackground := HBRUSH(COLOR_WINDOW);
   fwc.hInstance := hInstance;

   If RegisterClassEx(fwc)<>0 then
     {$IF CompilerVersion < 20}
     fwnd:=CreateWindowEx(0,PChar(AClassName),PChar(ACaption),WS_OVERLAPPEDWINDOW,0,0,stdWidth,stdHeight,0,0,HInstance,nil)
     {$ELSE}
     fwnd:=CreateWindowExW(0,PWChar(AClassName),PWChar(ACaption),WS_OVERLAPPEDWINDOW,0,0,stdWidth,stdHeight,0,0,HInstance,nil)
     {$IFEND}
   else
     raise Exception.Create('Failed register class!');



   if fwnd=0 then Free
   else
   begin
     AllList.Add(Self);
     WindowList.Add(Self);
   end;
end;

destructor TWindow.Destroy;
begin
  WindowList.Delete(Self) ;
  AllList.Delete(Self);
  DestroyWindow(Handle);
  If (WindowList.Count=0)or(WindowList.MainWindow=Self) then Terminate;
  UnregisterClass(fwc.lpszClassName,HInstance);
  inherited;
end;

procedure TWindow.DoClick;
begin
  if Assigned(FOnClick) then OnClick(Self);
end;

{$IF CompilerVersion < 20}
function TWindow.GetCaption: String;
 var cap:PChar;
     len:Cardinal;
begin
  len:=GetWindowTextLength(Handle);
  cap:=StrAlloc(len+1);
  GetWindowText(Handle,cap,len+1);
  Result:=cap;
end;
{$ELSE}
function TWindow.GetCaption: String;
 var cap:PWChar;
     len:Cardinal;
begin
  len:=GetWindowTextLengthW(Handle);
  cap:=StrAlloc(len+1);
  GetWindowTextW(Handle,cap,len+1);
  Result:=cap;
end;
{$IFEND}

function TWindow.GetChild(Index: Integer): TWindow;
  var i,curindx:Integer;
begin
  curindx:=0;
  Result:=nil;
  for i:= 0 to AllList.Count-1 do
    if AllList.Items[i].Parent=Self then
    begin
      if curindx=Index then
      begin
        Result:=AllList.Items[i];
        exit;
      end;
      Inc(curindx);
    end;

end;

function TWindow.ChildCount: Integer;
  var i:Integer;
begin
  Result:=0;
  for i:= 0 to AllList.Count-1 do
    if AllList.Items[i].Parent=Self then Inc(Result);
end;

function TWindow.GetEnabled: Boolean;
begin
  Result:=IsWindowEnabled(Handle);
end;

function TWindow.GetFocused: Boolean;
begin
   Result:=GetFocus=Handle;
end;

function TWindow.GetParent: TWindow;
begin
  Result:= AllList.Find(Windows.GetParent(Handle)) ;
end;

function TWindow.GetRect(const Index: Integer): Integer;
 var rect:TRect;
begin
 Result:=0;
 GetWindowRect(Handle,Rect);
 if Parent<>nil then
 begin
  ScreenToClient(Parent.Handle,Rect.TopLeft);
  ScreenToClient(Parent.Handle,Rect.BottomRight);
 end;

 case Index of
  1:Result:=rect.Left;
  2:Result:=rect.Top;
  3:Result:=rect.Right-rect.Left;
  4:Result:=rect.Bottom-rect.Top;
 end;
end;

function TWindow.GetVisible: Boolean;
begin
  Result := GetWindowLong(Handle,GWL_STYLE) or WS_VISIBLE = GetWindowLong(Handle,GWL_STYLE);
end;

function TWindow.GetWindowProc: TWndProc;
begin
  Result:=Pointer(GetWindowLong(Handle,GWL_WNDPROC));
end;

function TWindow.GetWindowStyle: NativeInt;
begin
  Result:=GetWindowLong(Handle,GWL_STYLE);
end;

function TWindow.GetWindowStyleEx: NativeInt;
begin
  Result:=GetWindowLong(Handle,GWL_EXSTYLE);
end;

procedure TWindow.Maximize;
begin
  ShowWindow(Handle,SW_MAXIMIZE);
end;

procedure TWindow.Minimize;
begin
  ShowWindow(Handle,SW_MINIMIZE);
end;

procedure TWindow.Restore;
begin
  ShowWindow(Handle,SW_RESTORE);
end;

procedure TWindow.SetCaption(const Value: String);
begin
  {$IF CompilerVersion < 20}
  SetWindowText(Handle,PChar(Value));
  {$ELSE}
  SetWindowText(Handle,Value);
  {$IFEND}
end;

procedure TWindow.SetCenter;
  var r:TRect;
begin
  if Parent<>nil then
  begin
    GetClientRect(Parent.Handle,r);
    Left:=r.Right div 2 - Width div 2;
    Top:=r.Bottom div 2 - Height div 2;
  end
  else
  begin
    Left:=GetSystemMetrics(SM_CXSCREEN) div 2 - Width div 2;
    Top:=GetSystemMetrics(SM_CYSCREEN) div 2 - Height div 2;
  end;
end;

procedure TWindow.SetEnabled(const Value: Boolean);
begin
  EnableWindow(Handle, Value)  ;
end;

procedure TWindow.SetFocused(const Value: Boolean);
begin
  If Value then SetFocus(Handle) else SetFocus(0);
end;

procedure TWindow.SetParent(const Value: TWindow);
begin
  if Value=nil then
  Windows.SetParent(Handle,0) else
  Windows.SetParent(Handle,Value.Handle);
end;

procedure TWindow.SetRect(const Index, Value: Integer);
 var rect:TRect;
begin
 GetWindowRect(Handle,Rect);

 if Parent<>nil then
 case Index of
  1:Rect.Right:=Rect.Right+(Value+Parent.Left);
  2:Rect.Bottom:=Rect.Bottom+(Value+Parent.Top);
  3:Rect.Left:=Value+Parent.Left;
  4:Rect.Top:=Value+Parent.Top;
 end;


 case Index of
  1:SetWindowPos(Handle,0,Value,Top,Width,Height,0);
  2:SetWindowPos(Handle,0,Left,Value,Width,Height,0);
  3:SetWindowPos(Handle,0,Left,Top,Value,Height,0);
  4:SetWindowPos(Handle,0,Left,Top,Width,Value,0);
 end;
end;

procedure TWindow.SetVisible(const Value: Boolean);
begin
  if Value then
    ShowWindow(Handle,SW_NORMAL)
  else
    ShowWindow(Handle,SW_HIDE);
end;

procedure TWindow.SetWindowProc(const Value: TWndProc);
begin
  SetWindowLong(Handle,GWL_WNDPROC,UINT(@Value));
end;

procedure TWindow.SetWindowStyle(const Value: NativeInt);
begin
  SetWindowLong(Handle,GWL_STYLE,Value);
end;

procedure TWindow.SetWindowStyleEx(const Value: NativeInt);
begin
  SetWindowLong(Handle,GWL_EXSTYLE,Value);
end;

{ TWindowList }

function TWindowList.Add(Item: TWindow): Integer;
begin
  SetLength(FList,High(FList)+2);
  FList[High(FList)]:=Item;
  if FMain=nil then FMain:=Item;
  Result:=High(FList);
end;

function TWindowList.Count: Integer;
begin
  Result:=High(FList)+1;
end;

constructor TWindowList.Create;
begin
  SetLength(FList,0);
end;

function TWindowList.Delete(Item: TWindow): Boolean;
  var i:Integer;
begin
  Result:=false;
  for i := 0 to High(FList) do
    if FList[i]=Item then
    Result:=Delete(i);
end;

function TWindowList.Delete(Index: Integer; bDestroy: Boolean): Boolean;
 var i:Integer;
begin
  Result:=false;
  If bDestroy then FList[Index].Destroy;

  for i := Index to High(FList)-1 do
    FList[i]:=FList[i+1];

  SetLength(FList,High(FList));
  Result:=true;
end;

function TWindowList.Find(ClassName: String): TWindow;
 var i:Integer;
begin
  Result:=nil;
  for i := 0 to High(FList) do
    if FList[i].fwc.lpszClassName=ClassName then
    begin
      Result:=FList[i];
      exit
    end;
end;

function TWindowList.Find(wnd: HWND): TWindow;
 var i:Integer;
begin
  Result:=nil;
 for i := 0 to High(FList) do
   if FList[i].fwnd=wnd then
   begin
     Result:=FList[i];
     exit
   end;
end;

function TWindowList.GetItem(Index: Integer): TWindow;
begin
  Result:=nil;
  if (Index>=Low(FList))and(Index<=High(FList)) then
   Result:=FList[Index];
end;

{ Custom }

Procedure Run(TerminateOnEnd:Boolean);
 var msg:tagMSG;
begin

 while GetMessage(msg,0,0,0) do
 begin
  TranslateMessage(msg);
  DispatchMessage(msg);
 end;

 If TerminateOnEnd then Terminate;
end;

Procedure Terminate;
begin
 postquitmessage(0);
end;

Function CreateWindow(ClassName:String;var Mask: TWindowMask;var Wnds: TWindowsArray;Captions: array of string;MainEvent: array of TEvent; CharSize:Word):TWindow;
 var x,y, wIndex:Integer;
     width,height:Integer;

     Function RowLen(ax,ay:Integer):Integer;
       var def:Char;
     begin
       def:=Mask[ax,ay];
       result:=1;
       if High(Mask[ax])<ax+1 then exit;

       while Mask[ax+1,ay]=def do
       begin
         Inc(Result);
         Inc(ax);
         if ax>High(Mask) then exit;

       end;
     end;

     Function CalcHeight(ax,ay:Integer):Integer;
       var def:char;
           len:Integer;
     begin
       Result:=CharSize;

       def:=Mask[ax,ay];
       len:=RowLen(ax,ay);
       while (Mask[ax,ay+1]=def)and(RowLen(ax,ay+1)=len) do
       begin
        Result:=Result+CharSize;
        Inc(ay);
        if ay>High(Mask[ax]) then exit;
       end;
     end;

     Function CalcWidth(ax,ay:Integer):Integer;
       var def:char;
     begin
       Result:=CharSize;
       def:=Mask[ax,ay];
       if ax+1>High(Mask) then
         exit;


       while Mask[ax+1,ay]=def do
       begin
        Result:=Result+CharSize;
        Inc(ax);
        if ax+1>High(Mask) then exit;
       end;
     end;

     Procedure ClearMask(ax,ay,Width,Height:Integer);
       var i,j:Integer;
     begin
       for i := ax to ax+Width div CharSize-1 do
         for j := ay to ay+Height div CharSize-1 do
           Mask[i,j]:='.';
     end;
begin
 Width:=(High(Mask)-Low(Mask)+2)*CharSize;//window width
 Height:=(High(Mask[0])-Low(Mask[0])+3)*CharSize;//window height

 Result:=AllList.Find(ClassName);
 if Result=nil then
 begin
   Result:=TWindow.Create(ClassName);
   Result.Width:=Width;
   Result.Height:=Height;
 end
 else
 begin //if a window with the name ClassName exists, we use it (combine masks)
   if Result.Width<Width then Result.Width:=Width;
   if Result.Height<Height then Result.Height:=Height;
 end;
 wIndex:=0;


 for x:= Low(Mask) to High(Mask) do
  for y:= Low(Mask[x]) to High(Mask[x]) do
  begin
   if Mask[x,y]<>'.' then
   begin


     if (Mask[x,y]in ['b','r','c','B','R','C'])then
     begin
       SetLength(Wnds,High(Wnds)+2);
       Wnds[wIndex]:=TButton.Create(Result);
       case Mask[x,y] of
         'r','R': (Wnds[wIndex] as TButton).Style:=bsRadioButton;
         'c','C': (Wnds[wIndex] as TButton).Style:=bsCheckBox;
       end;

     end;

     if (Mask[x,y]in ['e','E'])then
     begin
       SetLength(Wnds,High(Wnds)+2);
       Wnds[wIndex]:=TEdit.Create(Result);
     end;

     if (Mask[x,y]in ['s','S'])then
     begin
       SetLength(Wnds,High(Wnds)+2);
       Wnds[wIndex]:=TStatic.Create(Result);
     end;

     Width :=CalcWidth(x,y);
     Height:=CalcHeight(x,y);
     ClearMask(x,y,Width,Height);

     Wnds[wIndex].Left:=x*CharSize;
     Wnds[wIndex].Top:=y*CharSize;
     Wnds[wIndex].Width:=width;
     Wnds[wIndex].Height:=height;

     if wIndex<=High(Captions) then
       Wnds[wIndex].Caption:=Captions[wIndex];

     if wIndex<=High(MainEvent) then
       if (Wnds[wIndex] is TEdit) then
          (Wnds[wIndex] as TEdit).OnChange:=MainEvent[wIndex] else
           Wnds[wIndex].OnClick:=MainEvent[wIndex];

     Inc(wIndex);
   end;

  end;
end;

Procedure CreateMask(Template:array of string; var Mask: TWindowMask);
  var i,j:Integer;
begin
  SetLength(Mask,Length(Template[Low(Template)]));
  for i :=0 to Length(Template[Low(Template)])-1 do
    SetLength(Mask[i],High(Template)+1);

  for i :=Low(Template) to High(Template) do
  begin

   for j:=0 to Length(Template[Low(Template)])-1  do
     Mask[j,i]:=Template[i][j+1];
  end;
end;

{$IF CompilerVersion < 20}
function TWindowList.GetWindow(ClassName: String): TWindow;
begin
  Result:=Find(ClassName);
end;
{$IFEND}

{ TButton }

constructor TButton.Create(AParent:TWindow;ACaption:String);
begin
  FAutoChecked:=true;

  if AParent<>nil then
  begin
    {$IF CompilerVersion < 20}
    fwnd:=CreateWindowEx(0,PChar('BUTTON'),PChar(ACaption),WS_CHILD or WS_TABSTOP,0,0,stdWidth,stdHeight,AParent.Handle,0,HInstance,nil);
    {$ELSE}
    fwnd:=CreateWindowExW(0,PWChar('BUTTON'),PWChar(ACaption),WS_CHILD or WS_TABSTOP,0,0,stdWidth,stdHeight,AParent.Handle,0,HInstance,nil);
    {$IFEND}
    Parent:=AParent;
  end
  else
    {$IF CompilerVersion < 20}
    fwnd:=CreateWindowEx(0,PChar('BUTTON'),PChar(ACaption),0,0,0,stdWidth,stdHeight,0,0,HInstance,nil);
    {$ELSE}
    fwnd:=CreateWindowExW(0,PWChar('BUTTON'),PWChar(ACaption),0,0,0,stdWidth,stdHeight,0,0,HInstance,nil);
    {$IFEND}

  @FDefProc:= Pointer(SetWindowLong(Handle,GWL_WNDPROC,UINT(@WndProc)));
  Visible:=true;
  AddToList;
end;

procedure TButton.DoCheck;
  var i:Integer;
      storeclick:TEvent;
begin
 if AutoChecked then
 begin
  if Style=bsRadioButton then
    if Parent<>nil then
      for i:=0 to AllList.Count-1 do
       If AllList.Items[i].Parent=Parent then
         if AllList.Items[i] is TButton then
           if (AllList.Items[i] as TButton).Style=bsRadioButton then
             if (AllList.Items[i]<>self)and((AllList.Items[i] as TButton).AutoChecked) then
               begin
                storeclick:=(AllList.Items[i] as TButton).OnClick;
                (AllList.Items[i] as TButton).OnClick:=nil;
                (AllList.Items[i] as TButton).AutoChecked:=false;
                (AllList.Items[i] as TButton).Checked:=false;
                (AllList.Items[i] as TButton).AutoChecked:=true;
                (AllList.Items[i] as TButton).OnClick:=storeclick;
               end;

  if (Style=bsRadioButton)or(Style=bsCheckBox) then
  begin
    storeclick:=OnClick;
    OnClick:=nil;
    AutoChecked:=false;
    If Style=bsCheckBox then
      Checked:=not Checked
    else
      Checked:=true;
    AutoChecked:=true;
    OnClick:=storeclick;
  end;

 end;

end;

procedure TButton.DoClick;
 var bef:Boolean;
begin

  if Style<>bsButton then
  begin
    bef:=Checked;
    DoCheck;
    if Checked<>bef then inherited DoClick;
  end
  else
    inherited DoClick;
end;

function TButton.GetChecked: Boolean;
begin
  if SendMessage(Handle,BM_GETCHECK,0,0)=BST_CHECKED then
    Result:=true;
  if SendMessage(Handle,BM_GETCHECK,0,0)=BST_UNCHECKED  then
    Result:=false;
end;


function TButton.GetStyle: TButtonStyle;
 var wl:NativeInt;
begin
 Result:=bsButton;
 wl:=GetWindowLong(Handle,GWL_STYLE);

 if wl or BS_CHECKBOX = wl then Result:=bsCheckBox;
 if wl or BS_RADIOBUTTON = wl then Result:=bsRadioButton;

end;

procedure TButton.SetChecked(const Value: Boolean);
 var bef:Boolean;
begin
 bef:=Checked;
 if Value then
  SendMessage(Handle,BM_SETCHECK,BST_CHECKED,0) else
  SendMessage(Handle,BM_SETCHECK,BST_UNCHECKED,0);

  If (Style<>bsCheckBox)and(bef<>Value) then DoCheck;
  If Value<>bef then inherited DoClick;

end;

procedure TButton.SetStyle(const Value: TButtonStyle);
 var
     vstyle:Cardinal;
begin

 if Parent<>nil then
  vstyle:=WS_CHILD or WS_TABSTOP else
  vstyle:=0;

 if Visible then
   vstyle:=vstyle or WS_VISIBLE;

 if Value=bsCheckBox then
 vstyle:=vstyle or BS_CHECKBOX;
 if Value=bsRadioButton then
 vstyle:=vstyle or BS_RADIOBUTTON;

 SetWindowLong(Handle,GWL_STYLE,vstyle);

 InvalidateRect(Handle,nil,true) ;
end;

{ TEdit }

constructor TEdit.Create(AParent: TWindow; AText: String);
begin
  if AParent<>nil then
  begin
    {$IF CompilerVersion < 20}
    fwnd:=CreateWindowEx(0,PChar('EDIT'),PChar(AText),WS_CHILD or WS_TABSTOP or WS_BORDER or ES_AUTOHSCROLL or ES_AUTOVSCROLL,0,0,stdWidth,stdHeight,AParent.Handle,0,HInstance,nil);
    {$ELSE}
    fwnd:=CreateWindowExW(0,PWChar('EDIT'),PWChar(AText),WS_CHILD or WS_TABSTOP or WS_BORDER or ES_AUTOHSCROLL or ES_AUTOVSCROLL,0,0,stdWidth,stdHeight,AParent.Handle,0,HInstance,nil);
    {$IFEND}
    Parent:=AParent;
  end
  else
    {$IF CompilerVersion < 20}
    fwnd:=CreateWindowEx(0,PChar('EDIT'),PChar(AText),ES_AUTOHSCROLL or ES_AUTOVSCROLL,0,0,stdWidth,stdHeight,0,0,HInstance,nil);
    {$ELSE}
    fwnd:=CreateWindowExW(0,PWChar('EDIT'),PWChar(AText),ES_AUTOHSCROLL or ES_AUTOVSCROLL,0,0,stdWidth,stdHeight,0,0,HInstance,nil);
    {$IFEND}
  AddToList;
  @FDefProc:=Pointer(GetWindowLong(Handle,GWL_WNDPROC));
  SetWindowLong(Handle,GWL_WNDPROC,UINT(@WndProc));
  Visible:=true;
end;

function TEdit.DeleteLine(LineNo: Integer): boolean;
  var i,j:Integer;
begin
  result:=false;


  i:=LineIndex[LineNo];

  if LineNo=LineCount-1 then
    i:=i-2;

  if LineNo<LineCount-1 then
   j:=LineIndex[LineNo+1] else
   j:=LineIndex[LineCount-1]+LineLength[LineCount-1]+1;

  if i<0 then exit;
  Text:=Copy(Text,0,i)+Copy(Text,j+1,Length(Text));
  result:=true;
end;

procedure TEdit.DoChange;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;


function TEdit.GetAlign: TTextAlign;
begin
  Result:=TTextAlign( WindowStyle-(WindowStyle shr 2 shl 2) );
end;

function TEdit.GetLine(LineNo: Integer): String;
begin
  Result:=Copy(Text,LineIndex[LineNo]+1,LineLength[LineNo]);
end;

function TEdit.GetLineCount: Integer;
begin
  Result := SendMessage(Handle,EM_GETLINECOUNT,0,0);
end;

function TEdit.GetLineIndex(LineNo: Integer): Integer;
begin
  Result := SendMessage(Handle,EM_LINEINDEX,LineNo,0);
end;

function TEdit.GetLineLength(LineNo: Integer): Integer;
begin
  Result := SendMessage(Handle,EM_LINELENGTH,GetLineIndex(LineNo),0);
end;

function TEdit.GetMLine: Boolean;
begin
  Result := GetWindowStyle or ES_MULTILINE = GetWindowStyle;
end;

function TEdit.InsertLine(LineNo: Integer; Line: String): boolean;
  var i:Integer;
begin
  result:=false;

  if LineNo=LineCount then
  begin
    Text:=Text+#13#10+Line;
    result:=true;
    exit;
  end;

  i:=LineIndex[LineNo];
  if i=-1 then exit;
  Text:=Copy(Text,0,i)+Line+#13#10+Copy(Text,i+1,Length(Text));
  result:=true;
end;

procedure TEdit.RecreateWnd(NewStyle: nativeint);
  var oldexstyle:nativeint;
      l,t,w,h:Integer;
      sParent:TWindow;
      se,sv,sro,sf:Boolean;
      sOnChange:TEvent;
      sText:String;
begin

 oldexstyle:=WindowStyleEx;
 l:=Left;t:=Top;w:=Width;h:=Height;

 sParent:=Parent;
 sText:=Text;
 se:=Enabled;sv:=Visible;sro:=ReadOnly;
 sOnChange:=OnChange;
 sf:=Focused;

 SetWindowLong(Handle,GWL_WNDPROC,UINT(@FDefProc));
 DestroyWindow(Handle) ;

 if sParent<>nil then
  begin
    {$IF CompilerVersion < 20}
    fwnd:=CreateWindowEx(oldexstyle, PChar('EDIT'),PChar(sText),WS_CHILD or WS_TABSTOP or WS_BORDER or ES_AUTOHSCROLL or ES_AUTOVSCROLL or NewStyle,0,0,stdWidth,stdHeight,sParent.Handle,0,HInstance,nil);
    {$ELSE}
    fwnd:=CreateWindowExW(oldexstyle, PWChar('EDIT'),PWChar(sText),WS_CHILD or WS_TABSTOP or WS_BORDER or ES_AUTOHSCROLL or ES_AUTOVSCROLL or NewStyle,0,0,stdWidth,stdHeight,sParent.Handle,0,HInstance,nil);
    {$IFEND}
  end
  else
    {$IF CompilerVersion < 20}
    fwnd:=CreateWindowEx(oldexstyle, PChar('EDIT'),PChar(sText),ES_AUTOHSCROLL or ES_AUTOVSCROLL or NewStyle,0,0,stdWidth,stdHeight,0,0,HInstance,nil);
    {$ELSE}
    fwnd:=CreateWindowExW(oldexstyle, PWChar('EDIT'),PWChar(sText),ES_AUTOHSCROLL or ES_AUTOVSCROLL or NewStyle,0,0,stdWidth,stdHeight,0,0,HInstance,nil);
    {$IFEND}

 Parent:=sParent;
 Left:=l;Top:=t;Width:=w;Height:=h;
 Enabled:=se;Visible:=sv;ReadOnly:=sro;
 If sf then Focused:=true;
 OnChange:=sOnChange;

 @FDefProc:=Pointer(GetWindowLong(Handle,GWL_WNDPROC));
 SetWindowLong(Handle,GWL_WNDPROC,UINT(@WndProc));
end;

function TEdit.ReplaceLine(LineNo: Integer; Line: String): boolean;
begin
  Result:=false;
  if (LineNo>-1)and(LineNo<LineCount) then
  begin
   InsertLine(LineNo,Line);
   DeleteLine(LineNo+1);
   Result:=true;
  end;
end;

procedure TEdit.SetAlign(const Value: TTextAlign);
begin
  RecreateWnd((WindowStyle shr 2) shl 2 + UInt(Value));
end;

procedure TEdit.SetMLine(const Value: Boolean);
begin
 If value then
  RecreateWnd(WindowStyle or ES_MULTILINE) else
  RecreateWnd((WindowStyle or ES_MULTILINE) - ES_MULTILINE);
end;

procedure TEdit.SetReadOnly(const Value: Boolean);
begin
  if Value then
   SendMessage(Handle,EM_SETREADONLY,1,0) else
   SendMessage(Handle,EM_SETREADONLY,0,0);
   FSaveReadOnly:=Value;
end;

{ TStatic }

constructor TStatic.Create(AParent: TWindow; ACaption: String);
begin

  if AParent<>nil then
  begin
    {$IF CompilerVersion < 20}
    fwnd:=CreateWindowEx(0,PChar('STATIC'),PChar(ACaption),SS_NOTIFY or WS_CHILD or WS_TABSTOP,0,0,stdWidth,stdHeight,AParent.Handle,0,HInstance,nil);
    {$ELSE}
    fwnd:=CreateWindowExW(0,PWChar('STATIC'),PWChar(ACaption),SS_NOTIFY or WS_CHILD or WS_TABSTOP,0,0,stdWidth,stdHeight,AParent.Handle,0,HInstance,nil);
    {$IFEND}
    Parent:=AParent;
  end
  else
    {$IF CompilerVersion < 20}
    fwnd:=CreateWindowEx(0,PChar('STATIC'),PChar(ACaption),SS_NOTIFY,0,0,stdWidth,stdHeight,0,0,HInstance,nil);
    {$ELSE}
    fwnd:=CreateWindowExW(0,PWChar('STATIC'),PWChar(ACaption),SS_NOTIFY,0,0,stdWidth,stdHeight,0,0,HInstance,nil);
    {$IFEND}
  @FDefProc:= Pointer(SetWindowLong(Handle,GWL_WNDPROC,UINT(@WndProc)));
  Visible:=true;

  AddToList;
end;

initialization
 WindowList:=TWindowList.Create;
 AllList:=TWindowList.Create;
 stdWidth:=200; //Default width and height
 stdHeight:=200;
end.
