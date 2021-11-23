program MagicCalc;
{Example of a demo program showing how to use WCL
 LICENSE: GPLv2
 PROGRAMMER: Burshtin Nikolay - amber8706@mail.ru
 OS: Windows
}
{$R *.res}

uses
 Windows, Messages, SysUtils,
  WLC in 'WLC.pas';


 var CalcForm:TWindow;
     Edit:TEdit;

Procedure RadioClick(Sender: TObject);
begin
  Edit.TextAlign:=TTextAlign( (Sender as TButton).Tag);
end;

var a,b,mem:Extended;
    d:Char;

Procedure ButtonClick(Sender: TObject);
begin
  If ((Sender as TButton).Caption='0') and (edit.Text='0') then
  begin
    edit.Text:=',';
    exit;
  end;

  If ((Sender as TButton).Caption='C') then
  begin
    a:=0;b:=0;d:=#0;
    edit.Text:='0';
    exit;
  end;

  If ((Sender as TButton).Caption='MC') then mem:=0;
  If ((Sender as TButton).Caption='M+') then mem:=mem+StrToFloat(Edit.Text);
  If ((Sender as TButton).Caption='M') then Edit.Text:=FloatToStr(mem);

  if (Sender as TButton).Caption[1] in ['0'..'9'] then
    If (edit.Text='0') then edit.Text:=(Sender as TButton).Caption[1] else
      If Edit.TextAlign=taRight then edit.Text:=edit.Text+(Sender as TButton).Caption[1] else
      If Edit.TextAlign=taLeft then edit.Text:=(Sender as TButton).Caption[1]+edit.Text else
      If Edit.TextAlign=taCenter then
      edit.Text:=Copy(edit.Text,1,Length(edit.Text)div 2)+(Sender as TButton).Caption[1]+Copy(edit.Text,Length(edit.Text)div 2+1,Length(edit.Text));

  if (Sender as TButton).Caption[1] in ['*','/','+','-']  then
  begin
   a:=StrToFloat(Edit.Text);
   b:=0;
   Edit.Text:='0';
    d:=(Sender as TButton).Caption[1];
   exit;
  end;

  if (Sender as TButton).Caption[1] ='=' then
  begin
    if b=0 then b:=StrToFloat(Edit.Text);
    case d of
      '+':a:=a+b;
      '-':a:=a-b;
      '*':a:=a*b;
      '/':if b=0 then a:=pi{;)} else a:=a/b;
    end;
    Edit.Text:=FloatToStr(a);
  end;
end;


  var Mask:TWindowMask;

FormTemplate:Array[0..6] of String =  //visual form layout
 ('.eeeeeee.',
  'rrrRRRrrr',
  '.bBbB.bb.',
  '.BbBb.BB.',
  '.bBbB.bb.',
  '.bbBb.BB.',
  '.sssssss.');


  var wins:TWindowsArray;
  var i,radioindex:Integer;
begin

  mem:=0;
  CreateMask(FormTemplate,Mask);

 CalcForm:=CreateWindow( 'MagicCalc',Mask,wins,['Left','0','7','4','1','0','Demo application!','8','5','2','Center','9','6','3','=','/','*','-','+','Right','C','MC','M+','M'],[]);


 with wins[6] do
 begin
   WindowStyle:=SS_CENTER or WindowStyle;
   Top:=Top+10;
 end;

 edit:=(wins[1] as TEdit);
 edit.ReadOnly:=true;

 radioindex:=0;
 for i:= 0 to CalcForm.ChildCount do
  if CalcForm.GetChild(i) is TButton then
    if (CalcForm.GetChild(i) as TButton).Style=bsButton then
     CalcForm.GetChild(i).OnClick:=ButtonClick else
    if (CalcForm.GetChild(i) as TButton).Style=bsRadioButton then
    begin
     CalcForm.GetChild(i).OnClick:=RadioClick;
     CalcForm.GetChild(i).Tag:=radioindex;
     Inc(radioindex);
     (CalcForm.GetChild(i) as TButton).Checked:=true;
    end;

 CalcForm.Visible:=true;
 CalcForm.WindowStyle:=WS_BORDER or WS_VISIBLE or WS_DLGFRAME or WS_SYSMENU;
 CalcForm.SetCenter;

 Run;

end.
