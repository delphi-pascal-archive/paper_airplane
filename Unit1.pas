{$Q+,R+}

{$DEFINE LOGO}

unit Unit1;

interface

 uses
  Animation, PP, GTypes, FormulaV, Variable,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls, Grids, ExtCtrls, xmldom, XMLIntf, msxmldom, XMLDoc, Menus, Geometry, ToolWin, ImgList, ActnList, Printers, XPMan;

 const
  BetweenActionsDelay = 250;

 type
  TColorArray = array [0..MaxActions] of TColor;
  TForm1 = class(TForm)
    imgScreen: TImage;
    imgList: TImage;
    xmdMain: TXMLDocument;
    mnmMain: TMainMenu;
    mniFile: TMenuItem;
    mniOpen: TMenuItem;
    nmiNew: TMenuItem;
    nmiSave: TMenuItem;
    mniExit: TMenuItem;
    N1: TMenuItem;
    opdMain: TOpenDialog;
    svdMain: TSaveDialog;
    mniOptions: TMenuItem;
    mniShowMassCenter: TMenuItem;
    mniSaveAs: TMenuItem;
    mniStepByStepFolding: TMenuItem;
    mniShowBasePoints: TMenuItem;
    mniPrint: TMenuItem;
    N2: TMenuItem;
    mniShowPolygonIndex: TMenuItem;
    mniShowBasePointsIndex: TMenuItem;
    N3: TMenuItem;
    imlManu: TImageList;
    tlbMain: TToolBar;
    tlbNew: TToolButton;
    tlbOpen: TToolButton;
    tlbSave: TToolButton;
    ToolButton4: TToolButton;
    tlbPrint: TToolButton;
    ActionList1: TActionList;
    actFileNew: TAction;
    actFileOpen: TAction;
    actFileSave: TAction;
    actFileSaveAs: TAction;
    actFileExit: TAction;
    stbMain: TStatusBar;
    actFilePrint: TAction;
    pgcMain: TPageControl;
    tbsConstants: TTabSheet;
    tbsBasePoints: TTabSheet;
    tbsActions: TTabSheet;
    pnlSpeed: TPanel;
    trbSpeed: TTrackBar;
    lblSpeed: TLabel;
    CoolBar1: TCoolBar;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    prdMain: TPrintDialog;
    tlbPlay: TToolButton;
    ToolButton7: TToolButton;
    tlbPause: TToolButton;
    tlbStop: TToolButton;
    mniShowFoldingPoints: TMenuItem;
    XPManifest1: TXPManifest;
    mniShowSurface: TMenuItem;
    tbsMainSheet: TTabSheet;
    ToolButton1: TToolButton;
    tlbAdvanced: TToolButton;
    tbsAdvanced: TTabSheet;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edtP1: TEdit;
    edtP3: TEdit;
    edtP2: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    lblStart2: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtStart1: TEdit;
    edtStart2: TEdit;
    edtEnd1: TEdit;
    edtEnd2: TEdit;
    GroupBox3: TGroupBox;
    btnCalculate: TButton;
    Label7: TLabel;
    lblW: TLabel;
    lblD: TLabel;
    Label10: TLabel;
    lblS0: TLabel;
    Label12: TLabel;
    lblH: TLabel;
    Label14: TLabel;
    Label8: TLabel;
    lblL: TLabel;
    stgActions: TStringGrid;
    stgSheet: TStringGrid;
    stgPoints: TStringGrid;
    stgConstants: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure tlbPlayClick(Sender: TObject);
    procedure actFileOpenExecute(Sender: TObject);
    procedure actFileSaveExecute(Sender: TObject);
    procedure actFileExitExecute(Sender: TObject);
    procedure actFileNewExecute(Sender: TObject);
    procedure stgActionsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure imgListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure actFileSaveAsExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure imgScreenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgScreenMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgScreenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure actFilePrintExecute(Sender: TObject);
    procedure ShowHint(Sender: TObject);
    procedure tlbStopClick(Sender: TObject);
    procedure tlbPauseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tlbAdvancedClick(Sender: TObject);
    procedure btnCalculateClick(Sender: TObject);
    procedure trbSpeedChange(Sender: TObject);
  private
   ScreenMouseDown : Boolean;
   X0, Y0, StartStep : Integer;
   Paused, Playing : Boolean;
   procedure ClearAllStringGrids;
   procedure SaveToFile(FileName : TFileName);
   procedure LoadFromFile(FileName : TFileName);
   procedure ThreadDone(Sender: TObject);
  public
   AT : TAnimation;
   ListVA, ScreenVA : TVisualAirplane;
   function  ReadData : TAirplane;
   function  Options : TShowOptions;
   procedure ShowError(N : Integer);
   procedure ShowFoldError(N : Integer);
 end;

{$IFDEF LOGO}

 const
  LX0 = 10;
  LY0 = 10;
  d = 10;

{$ENDIF}

var
 Form1: TForm1;
 Polygon : TPolygon;

procedure PM;


implementation

{$R *.dfm}

procedure PM;
begin
 Application.ProcessMessages;
end;

procedure TForm1.FormCreate(Sender: TObject);
 begin
  opdMain.InitialDir := ExtractFilePath(ParamStr(0))+'\data';
  svdMain.InitialDir := ExtractFilePath(ParamStr(0))+'\data';
  opdMain.FileName := 'Untitled';
  Application.OnHint := ShowHint;
  imgScreen.Width := (imgScreen.Width + imgList.Width) div 2;
  ScreenMouseDown := false;
  Playing := false;
  Paused := false;
  X0 := 0;
  Y0 := 0;
  StartStep := 1;
  ListVA := TVisualAirplane.Create;
  ScreenVA := TVisualAirplane.Create;
  stgConstants.ColWidths[0] := 20;
  stgConstants.ColWidths[1] := 70;
  stgConstants.ColWidths[2] := 160;
  stgConstants.Cells[0, 0] := 'N';
  stgConstants.Cells[1, 0] := 'Name';
  stgConstants.Cells[2, 0] := 'Value';
  //
  stgPoints.ColWidths[0] := 20;
  stgPoints.ColWidths[1] := 100;
  stgPoints.ColWidths[2] := 100;
  stgPoints.Cells[0, 0] := 'N';
  stgPoints.Cells[1, 0] := 'X';
  stgPoints.Cells[2, 0] := 'Y';
  //
  stgActions.ColWidths[0] := 20;
  stgActions.ColWidths[1] := 35;
  stgActions.ColWidths[2] := 35;
  stgActions.ColWidths[3] := 80;
  stgActions.ColWidths[4] := 95;
  stgActions.Cells[0, 0] := 'N';
  stgActions.Cells[1, 0] := 'P1';
  stgActions.Cells[2, 0] := 'P2';
  stgActions.Cells[3, 0] := 'Targets';
  stgActions.Cells[4, 0] := 'Angle';
  //
  stgSheet.ColWidths[0] := 20;
  stgSheet.ColWidths[1] := 80;
  stgSheet.Cells[0, 0] := 'N';
  stgSheet.Cells[1, 0] := 'P';
  //
  LoadFromFile('default.xml');
 end;

procedure TForm1.ShowHint(Sender: TObject);
 begin
  if (Length(Application.Hint) > 0) then
   begin
    stbMain.SimplePanel := True;
    stbMain.SimpleText := Application.Hint;
   end
  else
   stbMain.SimplePanel := False;
 end;

function TForm1.ReadData : TAirplane;
 var
  A             : TAirPlane;
  CycRD1, CycP2 : Integer;
  Ac            : GTypes.TAction;
  Value         : Extended;
  P             : T3DPoint;
  VarList       : TVariableList;
  Frml          : TFormula;
  S             : String;
  Code          : Integer;
 begin
  VarList := TVariableList.Create('pi', 3.1415926536);
  for CycRD1 := 1 to stgConstants.RowCount - 1 - 1 do
   begin
    Frml := TFormula.Create(stgConstants.Cells[2, CycRD1]);
    Value := Frml.Caluclate(VarList);
    Frml.Destroy;
    VarList.SetVariableValue(stgConstants.Cells[1, CycRD1], Value);
   end;
{$IFDEF LOGO}
  if ((VarList.GetValueByName('Logo') = 1) or (VarList.GetValueByName('logo') = 1)) then
   begin
    imgScreen.Canvas.Rectangle(1, 1, 13 * d + 2 * LX0, 4 * d + 2 * LY0);
    imgScreen.Canvas.MoveTo(LX0 + 2  * d, LY0 + 4 * d);
    imgScreen.Canvas.LineTo(LX0 + 0     , LY0 + 0);
    imgScreen.Canvas.LineTo(LX0 + 13 * d, LY0 + 0);
    imgScreen.Canvas.MoveTo(LX0 + 3  * d, LY0 + 2 * d);
    imgScreen.Canvas.LineTo(LX0 + 4  * d, LY0 + 4 * d);
    imgScreen.Canvas.LineTo(LX0 + 11 * d, LY0 + 4 * d);
    imgScreen.Canvas.MoveTo(LX0 + 5  * d, LY0 + 2 * d);
    imgScreen.Canvas.LineTo(LX0 + 12 * d, LY0 + 2 * d);
    imgScreen.Canvas.TextOut(LX0 + 5 * d, LY0 + 0 * d + 5, 'Paper Airplane');
    imgScreen.Canvas.TextOut(LX0 + 5 * d - 5, LY0 + 2 * d + 5, 'Bycov D.');
    Application.ProcessMessages;
    Sleep(1000);
   end;
{$ENDIF}
  A := TAirPlane.Create;
  for CycRD1 := 1 to stgPoints.RowCount - 1 - 1 do
   begin
    Frml := TFormula.Create(stgPoints.Cells[1, CycRD1]);
    P.X := Frml.Caluclate(VarList);
    Frml.Destroy;
    Frml := TFormula.Create(stgPoints.Cells[2, CycRD1]);
    P.Y := Frml.Caluclate(VarList);
    Frml.Destroy;
    P.Z := 0;
    A.AddBasePoint(P.X, P.Y, CycRD1);
   end;
  for CycRD1 := 1 to stgSheet.RowCount - 1 - 1 do
   if (stgSheet.Cells[1, CycRD1] <> '') then
    A.AddMainSheetPoint(StrToInt(stgSheet.Cells[1, CycRD1]));
  for CycRD1 := 1 to stgActions.RowCount - 1 - 1 do
   begin
    Val(stgActions.Cells[1, CycRD1], Ac.P1, Code);
    if (Code <> 0) then
     Ac.P1 := 0;
    Val(stgActions.Cells[2, CycRD1], Ac.P2, Code);
    if (Code <> 0) then
     Ac.P2 := 0;
    Ac.NTargets := 0;
    S := stgActions.Cells[3, CycRD1];
    CycP2 := 1;
    while (CycP2 < Length(S)) do
     if ((S[CycP2] = ' ') and (S[CycP2 + 1] = ' ')) then
      Delete(S, CycP2, 1)
     else
      Inc(CycP2);
    while ((Length(S) > 0) and (S[1] = ' ')) do
     Delete(S, 1, 1);
    while ((Length(S) > 0) and (S[Length(S)] = ' ')) do
     Delete(S, Length(S), 1);
    if (Length(S) > 0) then
     S := S + ' ';
    while (Pos(' ', S) > 0) do
     begin
      Inc(Ac.NTargets);
      Ac.Targets[Ac.NTargets] := StrToInt(Copy(S, 1, Pos(' ', S) - 1));
      Delete(S, 1, Pos(' ', S));
     end;
    Frml := TFormula.Create(stgActions.Cells[4, CycRD1]);
    Ac.Angle := Frml.Caluclate(VarList);
    Frml.Destroy;
    A.AddAction(Ac);
   end;
  VarList.Destroy;
  Result := A;
 end;

procedure TForm1.tlbPlayClick(Sender: TObject);
 begin
  if (not(Playing)) then
   begin
    //stgActions.ClearColors;
    stbMain.Panels[0].Text := 'Playing';
    tlbPlay.Enabled := false;
    tlbPause.Enabled := true;
    tlbStop.Enabled := true;
    Playing := true;
    if (mniStepByStepFolding.Checked) then
     AT := TStepByStepAnimation.Create
    else
     AT := TSimpleAnimation.Create;
    AT.OnTerminate := ThreadDone;
   end
  else
   if (Paused) then
    begin
     stbMain.Panels[0].Text := 'Playing';
     Paused := false;
     AT.Suspended := false;
     tlbPlay.Enabled := false;
     tlbPause.Enabled := true;
     tlbStop.Enabled := true;
    end;
 end;

{procedure TForm1.ClearStringGrid(SG : TAdvancedStringGrid);
 var
  CycCSG1 : Integer;
 begin
  for CycCSG1 := 1 to SG.RowCount + 1 do
   SG.ClearRow(CycCSG1);
  SG.RowCount := 3;
  SG.UpdateIndex
   { SG.Refresh;}
 {end; }

procedure TForm1.ClearAllStringGrids;
var
 i,j: integer;
begin
 for i:=1 to stgConstants.RowCount-1 do
   for j:=1 to stgConstants.ColCount-1 do
    stgConstants.Cells[i,j]:='';
 for i:=1 to stgPoints.RowCount-1 do
   for j:=1 to stgPoints.ColCount-1 do
    stgPoints.Cells[i,j]:='';
 for i:=1 to stgSheet.RowCount-1 do
   for j:=1 to stgSheet.ColCount-1 do
    stgSheet.Cells[i,j]:='';
 for i:=1 to stgActions.RowCount-1 do
   for j:=1 to stgActions.ColCount-1 do
    stgActions.Cells[i,j]:='';
end;

procedure TForm1.SaveToFile(FileName : TFileName);
 var
  BaseNode, ConstantsNode, ConstantNode, BasePointsNode, PointNode, SheetNode, ActionsNode, TargetsNode : IXMLNode;
  CycS1, CycS2 : Integer;
  S : String;
 begin
  xmdMain.FileName := '';
  xmdMain.Active := true;
  xmdMain.DOMDocument.appendChild(xmdMain.DOMDocument.createProcessingInstruction('xml', 'version="1.0" standalone="yes"'));
  BaseNode := xmdMain.AddChild('airplane');
  ConstantsNode := BaseNode.AddChild('constants');
  for CycS1 := 1 to stgConstants.RowCount - 1 - 1 do
   begin
    ConstantNode := ConstantsNode.AddChild('constant');
    ConstantNode.AddChild('name').Text := stgConstants.Cells[1, CycS1];
    ConstantNode.AddChild('value').Text := stgConstants.Cells[2, CycS1];
   end;
  BasePointsNode := BaseNode.AddChild('basepoints');
  for CycS1 := 1 to stgPoints.RowCount - 1 - 1 do
   begin
    PointNode := BasePointsNode.AddChild('point');
    PointNode.AddChild('x').Text := stgPoints.Cells[1, CycS1];
    PointNode.AddChild('y').Text := stgPoints.Cells[2, CycS1];
   end;
  SheetNode := BaseNode.AddChild('sheet');
  for CycS1 := 1 to stgSheet.RowCount - 1 - 1 do
   SheetNode.AddChild('point').Text := stgSheet.Cells[1, CycS1];
  ActionsNode := BaseNode.AddChild('actions');
  for CycS1 := 1 to stgActions.RowCount - 1 - 1 do
   begin
    PointNode := ActionsNode.AddChild('action');
    PointNode.AddChild('p1').Text := stgActions.Cells[1, CycS1];
    PointNode.AddChild('p2').Text := stgActions.Cells[2, CycS1];
    TargetsNode := PointNode.AddChild('targets');
    S := stgActions.Cells[3, CycS1] + ' ';
    CycS2 := 1;
    while (CycS2 < Length(S)) do
     if ((S[CycS2] = ' ') and (S[CycS2 + 1] = ' ')) then
      Delete(S, CycS2, 1)
     else
      Inc(CycS2);
    while (Pos(' ', S) > 0) do
     begin
      TargetsNode.AddChild('target').Text := Copy(S, 1, Pos(' ', S) - 1);
      Delete(S, 1, Pos(' ', S));
     end;
    PointNode.AddChild('angle').Text := stgActions.Cells[4, CycS1];
   end;
  xmdMain.SaveToFile(FileName);
  xmdMain.Active := false;
 end;

procedure TForm1.LoadFromFile(FileName : TFileName);
 var
  BaseNode, ConstantsNode, BasePointsNode, SheetNode, ActionsNode, TargetsNode : IXMLNode;
  CycL1, CycL2 : Integer;
  S : String;
 begin
  ClearAllStringGrids;
  Form1.Caption := opdMain.FileName + ' - Paper Airplane';
  Application.Title := Form1.Caption;
  xmdMain.FileName := ExtractFilePath(ParamStr(0))+'data\'+ExtractFileName(FileName);
  xmdMain.Active := true;
  BaseNode := xmdMain.DocumentElement;
  ConstantsNode := BaseNode.ChildNodes['constants'];
  stgConstants.RowCount := ConstantsNode.ChildNodes.Count + 1 + 1;
  for CycL1 := 0 to ConstantsNode.ChildNodes.Count - 1 do
   if (ConstantsNode.ChildNodes.Get(CycL1).NodeName = 'constant') then
    begin
     stgConstants.Cells[1, CycL1 + 1] := ConstantsNode.ChildNodes.Get(CycL1).ChildNodes['name'].Text;
     stgConstants.Cells[2, CycL1 + 1] := ConstantsNode.ChildNodes.Get(CycL1).ChildNodes['value'].Text;
    end;
  //
  BasePointsNode := BaseNode.ChildNodes['basepoints'];
  stgPoints.RowCount := BasePointsNode.ChildNodes.Count + 1 + 1;
  for CycL1 := 0 to BasePointsNode.ChildNodes.Count - 1 do
   if (BasePointsNode.ChildNodes.Get(CycL1).NodeName = 'point') then
    begin
     stgPoints.Cells[1, CycL1 + 1] := BasePointsNode.ChildNodes.Get(CycL1).ChildNodes['x'].Text;
     stgPoints.Cells[2, CycL1 + 1] := BasePointsNode.ChildNodes.Get(CycL1).ChildNodes['y'].Text;
    end;
  //
  SheetNode := BaseNode.ChildNodes['sheet'];
  stgSheet.RowCount := SheetNode.ChildNodes.Count + 1 + 1;
  for CycL1 := 0 to SheetNode.ChildNodes.Count - 1 do
   stgSheet.Cells[1, CycL1 + 1] := SheetNode.ChildNodes.Get(CycL1).Text;
  //
  ActionsNode := BaseNode.ChildNodes['actions'];
  stgActions.RowCount := ActionsNode.ChildNodes.Count + 1 + 1;
  for CycL1 := 0 to ActionsNode.ChildNodes.Count - 1 do
   if (ActionsNode.ChildNodes.Get(CycL1).NodeName = 'action') then
    begin
     stgActions.Cells[1, CycL1 + 1] := ActionsNode.ChildNodes.Get(CycL1).ChildNodes['p1'].Text;
     stgActions.Cells[2, CycL1 + 1] := ActionsNode.ChildNodes.Get(CycL1).ChildNodes['p2'].Text;
     S := '';
     TargetsNode := ActionsNode.ChildNodes.Get(CycL1).ChildNodes['targets'];
     for CycL2 := 0 to TargetsNode.ChildNodes.Count - 1 do
      if (TargetsNode.ChildNodes.Get(CycL2).NodeName = 'target') then
       S := S + TargetsNode.ChildNodes.Get(CycL2).Text + ' ';
     if (S[Length(S)] = ' ') then
      Delete(S, Length(S), 1);
     stgActions.Cells[3, CycL1 + 1] := S;
     stgActions.Cells[4, CycL1 + 1] := ActionsNode.ChildNodes.Get(CycL1).ChildNodes['angle'].Text;
    end;
  //
  xmdMain.Active := false;
 end;

procedure TForm1.actFileNewExecute(Sender: TObject);
 begin
  ClearAllStringGrids;
 end;

procedure TForm1.actFileOpenExecute(Sender: TObject);
 begin
  stbMain.SimplePanel := False;
  if (opdMain.Execute) then
   begin
    ClearAllStringGrids;
    LoadFromFile(opdMain.FileName);
   end;
 end;

procedure TForm1.actFileSaveExecute(Sender: TObject);
 begin
  stbMain.SimplePanel := False;
  if ((svdMain.FileName <> '') or (svdMain.Execute)) then
   begin
    Form1.Caption := svdMain.FileName + ' - Paper Airplane';
    SaveToFile(svdMain.FileName);
   end;
 end;

procedure TForm1.actFileSaveAsExecute(Sender: TObject);
 begin
  stbMain.SimplePanel := False;
  if (svdMain.Execute) then
   begin
    Form1.Caption := svdMain.FileName + ' - Paper Airplane';
    SaveToFile(svdMain.FileName);
   end;
 end;

procedure TForm1.actFileExitExecute(Sender: TObject);
 begin
  Application.Terminate;
 end;

procedure TForm1.stgActionsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  A : TAirPlane;
begin
  if ((stgActions.RowCount > 3) or (stgActions.Cells[1, 1] <> '') or (stgActions.Cells[2, 1] <> '') or (stgActions.Cells[3, 1] <> '') or (stgActions.Cells[4, 1] <> '')) then
   begin
    A := ReadData;
    if (A.DoActions(ARow - 1)) then
     if (A.Check(ARow)) then
      begin
       A.Show(ListVA, ARow);
       ListVA.Show(imgList.Canvas, Options + [soShowTargets] - [soShowMassCenter] - [soShowSurface]);
       A.Fold(ARow - 1);
       A.Show(ScreenVA, ARow);
       ScreenVA.Show(imgScreen.Canvas, Options);
      end;
    ShowError(A.LastError);
    ShowFoldError(A.LastFoldError);
    A.Destroy;
   end;
 end;

procedure TForm1.imgListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
 var
  A : TAirPlane;
  I : Integer;
  S : String;
begin
  A := ReadData;
  if (A.DoActions(stgActions.Row - 1)) then
   if (A.Check(stgActions.Row)) then
    begin
     A.Show(ListVA, stgActions.Row);
     ListVA.Show(imgList.Canvas, Options + [soShowTargets] - [soShowMassCenter] - [soShowSurface]);
     I := A.GetTargetByPoint(X, Y);
     if (I <> 0) then
      if (Pos(' ' + IntToStr(I) + ' ', ' ' + stgActions.Cells[3, stgActions.Row] + ' ') = 0) then
       stgActions.Cells[3, stgActions.Row] := stgActions.Cells[3, stgActions.Row] + ' ' + IntToStr(I)
      else
       if (Pos(' ', stgActions.Cells[3, stgActions.Row]) > 0) then
        begin
         S := ' ' + stgActions.Cells[3, stgActions.Row] + ' ';
         Delete(S, Pos(' ' + IntToStr(I) + ' ', S), Length(IntToStr(I)) + 1);
         if (S[1] = ' ') then
          Delete(S, 1, 1);
         if ((Length(S) > 0) and (S[Length(S)] = ' ')) then
          Delete(S, Length(S), 1);
         stgActions.Cells[3, stgActions.Row] := S;
        end;
     A.Fold(stgActions.Row - 1);
     A.Show(ScreenVA, stgActions.Row);
     ScreenVA.Show(imgScreen.Canvas, Options + [soShowTargets]);
    end;
  ShowError(A.LastError);
  A.Destroy;
  A := ReadData;
  if (A.DoActions(stgActions.Row - 1)) then
   begin
    A.Show(ListVA, stgActions.Row);
    ListVA.Show(imgList.Canvas, Options + [soShowTargets] - [soShowMassCenter] - [soShowSurface]);
    A.Fold(stgActions.Row - 1);
    A.Show(ScreenVA, stgActions.Row);
    ScreenVA.Show(imgScreen.Canvas, Options + [soShowTargets]);
   end;
  ShowError(A.LastError);
  A.Destroy;
 end;

function TForm1.Options : TShowOptions;
 begin
  Result := [];
  if (mniShowBasePoints.Checked) then
   Include(Result, soShowBasePoints);
  if (mniShowBasePointsIndex.Checked) then
   Include(Result, soShowBasePointsIndex);
  if (mniShowPolygonIndex.Checked) then
   Include(Result, soShowPolygonIndex);
  if (mniShowMassCenter.Checked) then
   Include(Result, soShowMassCenter);
  if (mniShowFoldingPoints.Checked) then
   Include(Result, soShowFoldingPoints);
  if (mniShowSurface.Checked) then
   Include(Result, soShowSurface);
 end;

procedure TForm1.ShowError(N : Integer);
begin
 // if (N > 0) then
 //  stgActions.Colors[N] := clLightRed;
end;

procedure TForm1.ShowFoldError(N : Integer);
begin
 //if (N > 0) then
 // stgActions.Colors[N] := clLightGreen;
end;

procedure TForm1.FormDestroy(Sender: TObject);
 begin
  ListVA.Destroy;
  ScreenVA.Destroy;
 end;

procedure TForm1.imgScreenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
 begin
  ScreenMouseDown := true;
  X0 := X;
  Y0 := Y;
 end;

procedure TForm1.imgScreenMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
 begin
  if (ScreenMouseDown) then
   begin
    ScreenVA.Alpha := ScreenVA.Alpha + (Y - Y0) / 50;
    ScreenVA.Beta := ScreenVA.Beta + (X - X0) / 50;
    ScreenVA.Show(imgScreen.Canvas, Options);
    X0 := X;
    Y0 := Y;
   end;
 end;

procedure TForm1.imgScreenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
 begin
  ScreenMouseDown := false;
 end;

procedure TForm1.actFilePrintExecute(Sender: TObject);
 begin
  stbMain.SimplePanel := False;
  if (prdMain.Execute) then
   begin
    Printer.Copies := prdMain.Copies;
    Printer.BeginDoc;
    ListVA.ShowScaled(Printer.Canvas, Round(Printer.PageWidth * 0.95), Round(Printer.PageHeight * 0.95));
    Printer.EndDoc;
   end;
 end;

procedure TForm1.tlbStopClick(Sender: TObject);
 begin
  if (Playing) then
   AT.Terminate;
 end;

procedure TForm1.tlbPauseClick(Sender: TObject);
 begin
  if (Playing) then
   begin
    AT.Suspended := true;
    if (not(Paused)) then
     begin
      Paused := true;
      stbMain.Panels[0].Text := 'Paused';
     end;
    tlbPlay.Enabled := true;
    tlbPause.Enabled := false;
    tlbStop.Enabled := true;
   end;
 end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
 begin
  if (Playing) then
   AT.Terminate;
 end;

procedure TForm1.ThreadDone(Sender: TObject);
 begin
  Playing := false;
  stbMain.Panels[0].Text := '';
  tlbPlay.Enabled := true;
  tlbPause.Enabled := false;
  tlbStop.Enabled := false;
 end;

procedure TForm1.tlbAdvancedClick(Sender: TObject);
begin
 tbsAdvanced.TabVisible := tlbAdvanced.Down;
end;

procedure TForm1.btnCalculateClick(Sender: TObject);
var
 A : TAirplane;
begin
 A := ReadData;
 A.DoActions;
 A.Fold;
 lblL.Caption := FloatToStrF(A.GetL(StrToInt(edtStart1.Text), StrToInt(edtStart2.Text), StrToInt(edtEnd1.Text), StrToInt(edtEnd2.Text)), ffNumber, 10, 5);
 lblW.Caption := FloatToStrF(A.GetW, ffNumber, 10, 5);
 lblH.Caption := FloatToStrF(A.GetH, ffNumber, 10, 5);
 lblD.Caption := FloatToStrF(A.GetD, ffNumber, 10, 5);
 A.Destroy;
end;

procedure TForm1.trbSpeedChange(Sender: TObject);
begin
 lblSpeed.Caption:='Speed ('+IntTostr(TrbSpeed.Position)+'): ';
end;

end.
