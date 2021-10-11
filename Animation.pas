unit Animation;

interface

uses
 PP,
 Classes,
 Graphics,
 GTypes,
 Windows,
 Geometry,
 Math,
 Types;

type
 TGraphicPointArray = array[1..NPointsMax] of Types.TPoint;

 TVisualAirplane = class
  private
   Lines : TLineSet;
   CMP : T3DPoint;
   Points, PolygonIndex : TIndexedPointSet;
   Regions : TRegionArray;
   HighLightedRegions : TBooleanArray;
   NRegions : Integer;
   V : TRotationVector;
   fP1, fP2 : T3DPoint;
   fHasFoldingLines : Boolean;
   MPS : TMainPointSet;
  public
   property Alpha : TFloat read V.Alpha write V.Alpha;
   property Beta : TFloat read V.Beta write V.Beta;
   property P1 : T3DPoint read fP1 write fP1;
   property P2 : T3DPoint read fP2 write fP2;
   property HasFoldingLines : Boolean read fHasFoldingLines write fHasFoldingLines;
   constructor Create;
   destructor Destroy; override;
   procedure Clear;
   procedure SetMPS(newMPS : TMainPointSet);
   procedure AddRegion(newRegion : TRegion; HighLighted : Boolean = false);
   procedure Show(C : TCanvas; Options : TShowOptions);
   procedure ShowScaled(C : TCanvas; Width, Height : Integer);
   procedure SetMassCenter(NewValue : T3DPoint);
   property  MassCenter : T3DPoint write SetMassCenter;
   property  BasePoints : TIndexedPointSet read Points;
   property  PolygonIndexPoints : TIndexedPointSet read PolygonIndex;
 end;

 TActionArray = array[1..MaxActions] of TAction;
 TEmptyProc = procedure of object;
 TAirPlane = class
  private
   MPS : TMainPointSet;
   Regions : TRegionArray;
   NRegions : Integer;
   Actions : TActionArray;
   fLastError, fLastFoldError : Integer;
   fNActions : Integer;
   procedure UpdateActions(Old, CurStep : Integer; New : TIntegerArray; N : Integer);
   procedure ReplaceActions(Old, CurStep : Integer; New : TIntegerArray; N : Integer);
   function  HasIndex(Index : Integer) : Boolean;
   function  GetPointByIndex(Index : Integer) : T3DPoint;
   procedure DoAction(Step : Integer);
   procedure UndoAction(Step : Integer);
   function  GetMassCenterPoint : T3DPoint;
  public
   constructor Create;
   destructor Destroy; override;
   procedure AddMainSheetPoint(Index : Integer); overload;
   procedure AddBasePoint(P : T3DPoint; Id : Integer); overload;
   procedure AddBasePoint(X, Y : TFloat; Id : Integer); overload;
   procedure AddAction(A : TAction);
   function  DoActions(N : Integer = NA_ALL_ACTIONS) : Boolean;
   procedure Fold(N : Integer = NA_ALL_ACTIONS);
   procedure UnFold(N : Integer = NA_ALL_ACTIONS);
   procedure Show(VA : TVisualAirplane; CurStep : Integer);
   function  GetTargetByPoint(X, Y : Integer) : Integer;
   function  GetL(PS1, PS2, PE1, PE2 : Integer) : TFloat;
   function  GetW : TFloat;
   function  GetH : TFloat;
   function  GetD : TFloat;
   function  Check(Step : Integer) : Boolean;
   property  NActions : Integer read fNActions;
   property  LastError : Integer read fLastError write fLastError;
   property  LastFoldError : Integer read fLastFoldError write fLastFoldError;
   procedure Chk;
   function  PointUsed(Id : Integer) : Boolean;
   procedure UpdateTargets(Old, New : Integer);
   procedure DeleteUnusedPoints;
   procedure DeleteUnusedRegionPoints(R : TRegion);
   procedure Simplify;
 end;


  TAnimation = class(TThread)
   private
    A : TAirPlane;
    CurStep, CurDelay, NSteps : Integer;
    ForbiddenOptions : TShowOptions;
    procedure ReadData;
    procedure HighLightRow;
    procedure UnHighLightRow;
    procedure GetList;
    procedure GetScreen;
    procedure ShowList;
    procedure ShowScreen;
    procedure GetDelay;
    procedure Delay;
    procedure GetNSteps;
    procedure ShowError;
    procedure Run(Step : Integer);
   public
    constructor Create(CreateSuspended : Boolean = false);
   protected
    procedure Execute; override; abstract;
  end;

  TStepByStepAnimation = class(TAnimation)
   protected
    procedure Execute; override;
  end;

  TSimpleAnimation = class(TAnimation)
   protected
    procedure Execute; override;
  end;

implementation

 uses
  Unit1;

function Cross21(P1, P2 : TPolygon) : Boolean;
 var
  P11, P12, P13, P21, P22, P23 : T3DPoint;
  V1, V2, V3                   : TFloat;
 begin
  P1.GetSurfacePoints(P11, P12, P13);
  P2.GetSurfacePoints(P21, P22, P23);
  V1 := PointBeforeSurface(P21, P11, P12, P13);
  V2 := PointBeforeSurface(P22, P11, P12, P13);
  V3 := PointBeforeSurface(P23, P11, P12, P13);
  Result := not((((V1 > 0) = (V2 > 0)) or (Eq(V1)) or (Eq(V2))) and
                (((V2 > 0) = (V3 > 0)) or (Eq(V2)) or (Eq(V3))) and
                (((V1 > 0) = (V3 > 0)) or (Eq(V1)) or (Eq(V3))));
 end;

{----------TVisualAirPlane----------}

constructor TVisualAirplane.Create;
 begin
  inherited Create;
  Lines := TLineSet.Create;
  Points := TIndexedPointSet.Create;
  PolygonIndex := TIndexedPointSet.Create;
  NRegions := 0;

  V.Alpha := 0;
  V.Beta := 0;
  V.C := Empty3DPoint;
  CMP := Empty3DPoint;
  fP1 := Empty3DPoint;
  fP2 := Empty3DPoint;

  MPS := TMainPointSet.Create;
 end;

destructor TVisualAirplane.Destroy;
 begin
  Lines.Destroy;
  Points.Destroy;
  PolygonIndex.Destroy;
  MPS.Destroy;
  inherited Destroy;
 end;

procedure TVisualAirplane.Clear;
 var
  CycC1 : Integer;
 begin
  Lines.Clear;
  Points.Clear;
  PolygonIndex.Clear;
  for CycC1 := 1 to NRegions do
   Regions[CycC1].Destroy;
  NRegions := 0;
  MPS.Clear;
 end;

procedure TVisualAirplane.SetMPS(newMPS : TMainPointSet);
 begin
  MPS.GetFrom(newMPS);
 end;

procedure TVisualAirplane.AddRegion(newRegion : TRegion; HighLighted : Boolean = false);
 begin
  Inc(NRegions);
  Regions[NRegions] := TRegion.Create(MPS);
  Regions[NRegions].GetFrom(newRegion);
  HighLightedRegions[NRegions] := HighLighted;
 end;

procedure TVisualAirplane.Show(C : TCanvas; Options : TShowOptions);
 const
  V0 : TVector = (X : 1; Y : 1; Z : 1);
 var
  CMP2 : T2DPoint;
  CycS1, CycS2 : Integer;
  SortedRegions : TIntegerArray;
  TmpVI : Integer;
  AR : TGraphicPointArray;
  VN : TVector;
  Angle : Real;
  RotatedMPS : TMainPointSet;
 begin
  if (soShowSurface in Options) then
   begin
    C.Rectangle(-1, -1, ScreenXMax, ScreenYMax);
    RotatedMPS := TMainPointSet.Create;
    RotatedMPS.GetFrom(MPS);
    RotatedMPS.Rotate(V);
    for CycS1 := 1 to NRegions do
     Regions[CycS1].MPS := RotatedMPS;
    for CycS1 := 1 to NRegions do
     SortedRegions[CycS1] := CycS1;
    for CycS1 := 1 to NRegions do
     for CycS2 := CycS1 + 1 to NRegions do
      if not((Cross21(Regions[SortedRegions[CycS1]], Regions[SortedRegions[CycS2]]))) then
       begin
        TmpVI := SortedRegions[CycS1];
        SortedRegions[CycS1] := SortedRegions[CycS2];
        SortedRegions[CycS2] := TmpVI;
       end;
    for CycS1 := 1 to NRegions do
     begin
      VN := Regions[SortedRegions[CycS1]].GetNormalVector;
      if (AbsV(VN) <> 0) then
       Angle := Abs(MulScal(V0, VN) / (AbsV(V0) * AbsV(VN)))
      else
       Angle := 0;
      C.Pen.Color := (Round(Angle * $ff) * $000001);
      C.Brush.Color := (Round(Angle * $ff) * $000001);
      for CycS2 := 1 to Regions[SortedRegions[CycS1]].NPoints do
       begin
        AR[CycS2].X := X0 + Round(Regions[SortedRegions[CycS1]].GetPoint(CycS2).X);
        AR[CycS2].Y := YMax - Round(Regions[SortedRegions[CycS1]].GetPoint(CycS2).Y);
       end;
      C.Polygon(Slice(AR, Regions[SortedRegions[CycS1]].NPoints));
      Regions[SortedRegions[CycS1]].Show(C, V, Options);
     end;
    for CycS1 := 1 to NRegions do
     Regions[CycS1].MPS := MPS;
    RotatedMPS.Destroy;
    C.Pen.Color := clBlack;
    C.Brush.Color := clWhite;
   end
  else
   begin
    C.Rectangle(-1, -1, ScreenXMax, ScreenYMax);
    if (soShowTargets in Options) then
     for CycS1 := 1 to NRegions do
      if (HighLightedRegions[CycS1]) then
       Regions[CycS1].ShowHighlited(C, V, [soShowTargets]);
    Lines.Show(C, V);
    Points.Show(C, V, Options);
    if (soShowPolygonIndex in Options) then
     PolygonIndex.Show(C, V, [soShowBasePointsIndex]);
    if (soShowMassCenter in Options) then
     begin
      CMP2 := Project(GetRotatedPoint(CMP, V));
      C.Pen.Color := clLime;
      C.Ellipse(X0 + Trunc(CMP2.X) - 6, YMax - (Trunc(CMP2.Y) - 6), X0 + Trunc(CMP2.X) + 6, YMax - (Trunc(CMP2.Y) + 6));
      C.Brush.Color := clLime;
      C.Ellipse(X0 + Trunc(CMP2.X) - 3, YMax - (Trunc(CMP2.Y) - 3), X0 + Trunc(CMP2.X) + 3, YMax - (Trunc(CMP2.Y) + 3));
      C.Brush.Color := clWhite;
      C.Pen.Color := clBlack;
     end;
    if ((fHasFoldingLines) and (soShowFoldingPoints in Options)) then
     begin
      C.Pen.Color := clRed;
      C.Brush.Color := clRed;
      CMP2 := Project(GetRotatedPoint(P1, V));
      C.Ellipse(X0 + Trunc(CMP2.X) - 3, YMax - (Trunc(CMP2.Y) - 3), X0 + Trunc(CMP2.X) + 3, YMax - (Trunc(CMP2.Y) + 3));
      CMP2 := Project(GetRotatedPoint(P2, V));
      C.Ellipse(X0 + Trunc(CMP2.X) - 3, YMax - (Trunc(CMP2.Y) - 3), X0 + Trunc(CMP2.X) + 3, YMax - (Trunc(CMP2.Y) + 3));
      C.Brush.Color := clWhite;
      C.Pen.Color := clBlack;
     end;
   end;
 end;

 procedure TVisualAirplane.ShowScaled(C : TCanvas; Width, Height : Integer);
  begin
   Lines.ShowScaled(C, Width, Height, V);
  end;

 procedure TVisualAirplane.SetMassCenter(NewValue : T3DPoint);
  begin
   CMP := NewValue;
   V.C := NewValue;
  end;

{----------TAirPlane----------}

 constructor TAirPlane.Create;
  begin
   MPS := TMainPointSet.Create;
   NRegions := 1;
   Regions[1] := TRegion.Create(MPS);
   fNActions := 0;
   fLastError := 0;
   fLastFoldError := 0;
  end;

 destructor TAirPlane.Destroy;
  var
   CycD1 : Integer;
  begin
   for CycD1 := 1 to NRegions do
    Regions[CycD1].Destroy;
   MPS.Destroy;
   inherited Destroy;
  end;

 procedure TAirPlane.UpdateActions(Old, CurStep : Integer; New : TIntegerArray; N : Integer);
  var
   CycUA1, CycUA2, CycUA2High, CycUA3 : Integer;
  begin
   for CycUA1 := 1 to CurStep - 1 do
    begin
     CycUA2High := Actions[CycUA1].NTargets;
     for CycUA2 := 1 to CycUA2High do
      if (Actions[CycUA1].Targets[CycUA2] = Old) then
       for CycUA3 := 1 to N do
        begin
         Inc(Actions[CycUA1].NTargets);
         Actions[CycUA1].Targets[Actions[CycUA1].NTargets] := New[CycUA3];
        end;
    end;
  end;

 procedure TAirPlane.ReplaceActions(Old, CurStep : Integer; New : TIntegerArray; N : Integer);
  var
   CycRA1, CycRA1High, CycRA2 : Integer;
  begin
   CycRA1High := Actions[CurStep].NTargets;
   for CycRA1 := 1 to CycRA1High do
    if (Actions[CurStep].Targets[CycRA1] = Old) then
     begin
      Actions[CurStep].Targets[CycRA1] := New[1];
      for CycRA2 := 2 to N do
       begin
        Inc(Actions[CurStep].NTargets);
        Actions[CurStep].Targets[Actions[CurStep].NTargets] := New[CycRA2];
       end;
     end;
  end;

 function TAirPlane.HasIndex(Index : Integer) : Boolean;
  var
   CycHI1 : Integer;
  begin
   Result := false;
   for CycHI1 := 1 to NRegions do
    Result := Result or (Regions[CycHI1].BasePoints.HasIndex(Index));
  end;

 function TAirPlane.GetPointByIndex(Index : Integer) : T3DPoint;
  var
   CycGP1 : Integer;
  begin
   for CycGP1 := 1 to NRegions do
    if (Regions[CycGP1].BasePoints.HasIndex(Index)) then
     Result := Regions[CycGP1].BasePoints.GetPointByIndex(Index);
  end;

 procedure TAirPlane.DoAction(Step : Integer);
  var
   CycDA1, CycDA2, N, N1, N2 : Integer;
   PL : TPointLine;
   TmpR : TRegion;
   A : TIntegerArray;
   R : TRegionArray;
  begin
   if ((Actions[Step].P1 > 0) and (Actions[Step].P2 > 0)) then
    begin
     PL[1] := GetPointByIndex(Actions[Step].P1);
     PL[2] := GetPointByIndex(Actions[Step].P2);
     for CycDA1 := 1 to Actions[Step].NTargets do
      begin
       Assert(Actions[Step].Targets[CycDA1] <= NRegions, 'Wrong Target Region Index');
       if (Regions[Actions[Step].Targets[CycDA1]].CrossLine(PL)) then
        begin
         Regions[Actions[Step].Targets[CycDA1]].GetCrossedRegions(PL, R, N);
         N1 := N;
         for CycDA2 := 1 to N do
          R[CycDA2].Simplify;
         CycDA2 := 1;
         while ((CycDA2 < N) and (Eq(R[CycDA2].GetSpace))) do
          begin
           R[CycDA2].Destroy;
           Inc(CycDA2);
           Dec(N1);
          end;
         TmpR := Regions[Actions[Step].Targets[CycDA1]];
         Regions[Actions[Step].Targets[CycDA1]] := R[CycDA2];
         while (CycDA2 < N) do
          begin
           Inc(CycDA2);
           while ((CycDA2 <= N) and (Eq(R[CycDA2].GetSpace))) do
            begin
             R[CycDA2].Destroy;
             Inc(CycDA2);
             Dec(N1);
            end;
           if (CycDA2 <= N) then
            begin
             Inc(NRegions);
             Regions[NRegions] := R[CycDA2];
            end;
          end;
         DeleteUnusedRegionPoints(TmpR);
         TmpR.Destroy;
         for CycDA2 := 1 to N - 1 do
          A[CycDA2] := NRegions - N + 1 + CycDA2;
         UpdateActions(Actions[Step].Targets[CycDA1], Step, A, N - 1);    
         if (Regions[Actions[Step].Targets[CycDA1]].GetPosition(PL) = sgLess) then
          begin
           N2 := 1;
           A[1] := Actions[Step].Targets[CycDA1];
          end
         else
          N2 := 0;
         for CycDA2 := NRegions - N1 + 2 to NRegions do
          if (Regions[CycDA2].GetPosition(PL) = sgLess) then
           begin
            Inc(N2);
            A[N2] := CycDA2;
           end;
         ReplaceActions(Actions[Step].Targets[CycDA1], Step, A, N2)
        end;
       if (Eq(Abs(Actions[Step].Angle), pi)) then
        begin
         if (Regions[Actions[Step].Targets[CycDA1]].GetPosition(PL) = sgLess) then
          Regions[Actions[Step].Targets[CycDA1]].Mirror(PL[1], PL[2]);
         for CycDA2 := NRegions - N + 2 to NRegions do
          if (Regions[CycDA2].GetPosition(PL) = sgLess) then
           Regions[CycDA2].Mirror(PL[1], PL[2]);
        end;
      end
    end;
   DeleteUnusedPoints;
  end;

procedure TAirPlane.UndoAction(Step : Integer);
 var
  CycUA1 : Integer;
 begin
  if ((Actions[Step].P1 > 0) and (Actions[Step].P2 > 0)) then
   if (Eq(Abs(Actions[Step].Angle), pi)) then
    for CycUA1 := 1 to Actions[Step].NTargets do
     Regions[Actions[Step].Targets[CycUA1]].Mirror(GetPointByIndex(Actions[Step].P1), GetPointByIndex(Actions[Step].P2));
 end;

function TAirPlane.GetMassCenterPoint : T3DPoint;
 var
  CycM1, CycM2 : Integer;
  S, STmp : TFloat;
  P : T3DPoint;
 begin
  Result.X := 0;
  Result.Y := 0;
  Result.Z := 0;
  S := 0;
  for CycM1 := 1 to NRegions do
   for CycM2 := 1 to Regions[CycM1].NPoints - 2 do
    begin
     P := GetTriangleCenterPoint(Regions[CycM1].GetPoint(1), Regions[CycM1].GetPoint(CycM2 + 1), Regions[CycM1].GetPoint(CycM2 + 2));
     STmp := GetTriangleSpace(Regions[CycM1].GetPoint(1), Regions[CycM1].GetPoint(CycM2 + 1), Regions[CycM1].GetPoint(CycM2 + 2));
     Result.X := Result.X + P.X * STmp;
     Result.Y := Result.Y + P.Y * STmp;
     Result.Z := Result.Z + P.Z * STmp;
     S := S + STmp;
    end;
  if (S > 0) then
   begin
    Result.X := Result.X / S;
    Result.Y := Result.Y / S;
    Result.Z := Result.Z / S;
   end;
 end;

 procedure TAirPlane.AddMainSheetPoint(Index : Integer);
  begin
   Assert(NRegions = 1, 'Can''t Initialise after dividing regions');
   Regions[1].AddPoint(Regions[1].BasePoints.GetPointByIndex(Index));
  end;

 procedure TAirPlane.AddBasePoint(P : T3DPoint; Id : Integer);
  begin
   Assert(NRegions = 1, 'Can''t Initialise after dividing regions');
   Regions[1].BasePoints.AddIndexedPoint(P, Id);
  end;

 procedure TAirPlane.AddBasePoint(X, Y : TFloat; Id : Integer);
  begin
   Assert(NRegions = 1, 'Can''t Initialise after dividing regions');
   Regions[1].BasePoints.AddIndexedPoint(X, Y, Id);
  end;

 procedure TAirPlane.AddAction(A : TAction);
  var
   CycAA1, CycAA2, TmpV : Integer;
  begin
   Inc(fNActions);
    Actions[fNActions] := A;
   for CycAA1 := 1 to Actions[fNActions].NTargets do
    for CycAA2 := 1 to Actions[fNActions].NTargets do
     if (Actions[fNActions].Targets[CycAA2] > Actions[fNActions].Targets[CycAA1]) then
      begin
       TmpV := Actions[fNActions].Targets[CycAA1];
       Actions[fNActions].Targets[CycAA1] := Actions[fNActions].Targets[CycAA2];
       Actions[fNActions].Targets[CycAA2] := TmpV;
      end;
  end;

function TAirPlane.DoActions(N : Integer = NA_ALL_ACTIONS) : Boolean;
 var
  CycDA1, G : Integer;
 begin
  if (N = NA_ALL_ACTIONS) then
   G := fNActions
  else
   G := Geometry.Min(N, fNActions);
  Result := true;
  for CycDA1 := 1 to G do
   if (Check(CycDA1)) then
    DoAction(CycDA1)
   else
    Result := false;
  if (Result) then
   for CycDA1 := G downto 1 do
    UndoAction(CycDA1);
  Simplify;
 end;

procedure TAirplane.Fold(N : Integer = NA_ALL_ACTIONS);
 var
  CycF1, CycF2, G : Integer;
  PL              : T3DPointLine;
  P               : TRegion;
 begin
  if (N = NA_ALL_ACTIONS) then
   G := fNActions
  else
   G := Geometry.Min(N, fNActions);
  for CycF1 := 1 to G do
   if ((Actions[CycF1].P1 > 0) and (Actions[CycF1].P2 > 0)) then
    begin
     PL[1] := GetPointByIndex(Actions[CycF1].P1);
     PL[2] := GetPointByIndex(Actions[CycF1].P2);
     P := TRegion.Create(MPS);
     for CycF2 := 1 to Actions[CycF1].NTargets do
      P.Copy(Regions[Actions[CycF1].Targets[CycF2]]);
     P.Rotate(PL, Actions[CycF1].Angle);
     for CycF2 := 1 to Actions[CycF1].NTargets do
      Regions[Actions[CycF1].Targets[CycF2]].BasePoints.Rotate(PL, Actions[CycF1].Angle);
     P.Destroy;
    end;
 end;

procedure TAirplane.UnFold(N : Integer = NA_ALL_ACTIONS);
 var
  CycUF1, CycUF2, G : Integer;
  PL                : T3DPointLine;
  P                 : TRegion;
 begin
  if (N = NA_ALL_ACTIONS) then
   G := fNActions
  else
   G := Geometry.Min(N, fNActions);
  for CycUF1 := G downto 1 do
   if ((Actions[CycUF1].P1 > 0) and (Actions[CycUF1].P2 > 0)) then
    begin
     PL[1] := GetPointByIndex(Actions[CycUF1].P1);
     PL[2] := GetPointByIndex(Actions[CycUF1].P2);
     P := TRegion.Create(MPS);
     for CycUF2 := 1 to Actions[CycUF1].NTargets do
      P.Copy(Regions[Actions[CycUF1].Targets[CycUF2]]);
     P.Rotate(PL, -Actions[CycUF1].Angle);
     for CycUF2 := Actions[CycUF1].NTargets downto 1 do
      Regions[Actions[CycUF1].Targets[CycUF2]].BasePoints.Rotate(PL, -Actions[CycUF1].Angle);
     P.Destroy;
    end;
 end;

procedure TAirPlane.Show(VA : TVisualAirplane; CurStep : Integer);
 var
  CycS1, CycS2 : Integer;
  HighLighted : Boolean;
 begin
  VA.Clear;
  VA.SetMPS(MPS);
  for CycS1 := 1 to NRegions do
   VA.Lines.AddPolygon(Regions[CycS1]);
  for CycS1 := 1 to NRegions do
   if (Regions[CycS1].BasePoints.NPoints > 0) then
    for CycS2 := 1 to Regions[CycS1].BasePoints.NPoints do
     VA.Points.AddIndexedPoint(Regions[CycS1].BasePoints.GetPoint(CycS2), Regions[CycS1].BasePoints.GetIndex(CycS2));
  for CycS1 := 1 to NRegions do
   VA.PolygonIndex.AddIndexedPoint(Regions[CycS1].GetCenterPoint, CycS1);
  VA.MassCenter := GetMassCenterPoint;
  if (CurStep <> 0) then
   for CycS1 := 1 to NRegions do
    begin
     HighLighted := false;
     for CycS2 := 1 to Actions[CurStep].NTargets do
      HighLighted := HighLighted or (Actions[CurStep].Targets[CycS2] = CycS1);
     VA.AddRegion(Regions[CycS1], HighLighted);
    end;
  if ((CurStep <> 0) and ((Actions[CurStep].P1 > 0) and (Actions[CurStep].P2 > 0))) then
   begin
    VA.HasFoldingLines := true;
    VA.P1 := GetPointByIndex(Actions[CurStep].P1);
    VA.P2 := GetPointByIndex(Actions[CurStep].P2);
   end
  else
   VA.HasFoldingLines := false;
 end;

function TAirPlane.GetTargetByPoint(X, Y : Integer) : Integer;
 var
  CycGP1 : Integer;
  P : T3DPoint;
 begin
  P.X := X - X0;
  P.Y := YMax - Y;
  P.Z := 0;
  CycGP1 := 1;
  while ((CycGP1 < NRegions) and (not(Regions[CycGP1].PointInPolygon(P)))) do
   Inc(CycGP1);
  if ((CycGP1 <= NRegions) and (Regions[CycGP1].PointInPolygon(P))) then
   Result := CycGP1
  else
   Result := 0;
 end;

function TAirplane.GetL(PS1, PS2, PE1, PE2 : Integer) : TFloat;
 var
  D, CurMin, CurMax : TFloat;
  PPS1, PPS2, PPE1, PPE2, P1, P1Tmp, P2, P : T3DPoint;
  CycGR1, CycGR2 : Integer;
 begin
  if ((HasIndex(PS1)) and (HasIndex(PS2)) and (HasIndex(PE1)) and (HasIndex(PE2))) then
   begin
    PPS1 := GetPointByIndex(PS1);
    PPS2 := GetPointByIndex(PS2);
    PPE1 := GetPointByIndex(PE1);
    PPE2 := GetPointByIndex(PE2);
    P1Tmp.X := (PPS1.X + PPS2.X) / 2;
    P1Tmp.Y := (PPS1.Y + PPS2.Y) / 2;
    P1Tmp.Z := (PPS1.Z + PPS2.Z) / 2;
    P2.X := (PPE1.X + PPE2.X) / 2;
    P2.Y := (PPE1.Y + PPE2.Y) / 2;
    P2.Z := (PPE1.Z + PPE2.Z) / 2;
    P1.X := P1Tmp.X + 1 * (P1Tmp.X - P2.X);
    P1.Y := P1Tmp.Y + 1 * (P1Tmp.Y - P2.Y);
    P1.Z := P1Tmp.Z + 1 * (P1Tmp.Z - P2.Z);
    CurMin := 10000;
    CurMax := 0;
    for CycGR1 := 1 to NRegions do
     for CycGR2 := 1 to Regions[CycGR1].NPoints do
      begin
       P := Regions[CycGR1].GetPoint(CycGR2);
       D := Sqrt(Sqr(GetPointToPointDist(P, P1)) - Sqr(2 * GetTriangleSpace(P1, P2, P) / GetPointToPointDist(P1, P2)));
       if (D < CurMin) then
        CurMin := D;
       if (D > CurMax) then
        CurMax := D;
      end;
    Result := CurMax - CurMin;
   end
  else
   Result := 0;
 end;

function TAirplane.GetW : TFloat;
 var
  CycG1, CycG2 : Integer;
  Max, Min : TFloat;
 begin
  Max := 0;
  Min := 0;
  for CycG1 := 1 to NRegions do
   for CycG2 := 1 to Regions[CycG1].NPoints do
    if (Regions[CycG1].GetPoint(CycG2).X > Max) then
     Max := Regions[CycG1].GetPoint(CycG2).X
    else
     if (Regions[CycG1].GetPoint(CycG2).X < Min) then
      Min := Regions[CycG1].GetPoint(CycG2).X;
  Result := Max - Min;
 end;

function TAirplane.GetH : TFloat;
 var
  CycG1, CycG2 : Integer;
  Max, Min : TFloat;
 begin
  Max := 0;
  Min := 0;
  for CycG1 := 1 to NRegions do
   for CycG2 := 1 to Regions[CycG1].NPoints do
    if (Regions[CycG1].GetPoint(CycG2).Y > Max) then
     Max := Regions[CycG1].GetPoint(CycG2).Y
    else
     if (Regions[CycG1].GetPoint(CycG2).Y < Min) then
      Min := Regions[CycG1].GetPoint(CycG2).Y;
  Result := Max - Min;
 end;

function TAirplane.GetD : TFloat;
 var
  CycG1, CycG2 : Integer;
  Max, Min : TFloat;
 begin
  Max := 0;
  Min := 0;
  for CycG1 := 1 to NRegions do
   for CycG2 := 1 to Regions[CycG1].NPoints do
    if (Regions[CycG1].GetPoint(CycG2).Z > Max) then
     Max := Regions[CycG1].GetPoint(CycG2).Z
    else
     if (Regions[CycG1].GetPoint(CycG2).Z < Min) then
      Min := Regions[CycG1].GetPoint(CycG2).Z;
  Result := Max - Min;
 end;

function TAirplane.Check(Step : Integer) : Boolean;
 var
  CycC1 : Integer;
 begin
  Result := true;
  for CycC1 := 1 to Actions[Step].NTargets do
   if (not(Actions[Step].Targets[CycC1] <= NRegions)) then
    begin
     Result := false;
     if (fLastError = 0) then
      fLastError := Step;
    end;
 end;

 procedure TAirplane.Chk;
  var
   CycC1, CycC2 : Integer;
  begin
   for CycC1 := 1 to NRegions do
    for CycC2 := 1 to Regions[CycC1].NPoints do
     Assert(Regions[CycC1].A[CycC2] <= MPS.NPoints);
  end;

 procedure TAirplane.DeleteUnusedRegionPoints(R : TRegion);
  var
   CycDU0, CycDU1, CycDU2 : Integer;
   Res                    : Boolean;
  begin
   for CycDU0 := 1 to R.NPoints do
    begin
     Res := true;
     for CycDU1 := 1 to NRegions do
      if (Regions[CycDU1] <> R) then {???}
       for CycDU2 := 1 to Regions[CycDU1].NPoints do
        Res := Res and (Regions[CycDU1].A[CycDU2] <> R.A[CycDU0]);
     Assert(Res, 'Point Used');
     MPS.DeletePoint(R.A[CycDU0]);
     for CycDU1 := 1 to NRegions do
      if (Regions[CycDU1] <> R) then {???}
       for CycDU2 := 1 to Regions[CycDU1].NPoints do
        if (Regions[CycDU1].A[CycDU2] > R.A[CycDU0]) then
         Dec(Regions[CycDU1].A[CycDU2]);
     for CycDU2 := 1 to R.NPoints do
      if (R.A[CycDU2] > R.A[CycDU0]) then
       Dec(R.A[CycDU2]);
    end;
   Chk;
  end;

 function TAirplane.PointUsed(Id : Integer) : Boolean;
  var
   CycPU1, CycPU2 : Integer;
  begin
   Result := false;
   for CycPU1 := 1 to NRegions do
    for CycPU2 := 1 to Regions[CycPU1].NPoints do
     Result := Result or (Regions[CycPU1].A[CycPU2] = Id);
  end;

 procedure TAirplane.UpdateTargets(Old, New : Integer);
  var
   CycUT1, CycUT2 : Integer;
  begin
   for CycUT1 := 1 to NRegions do
    for CycUT2 := 1 to Regions[CycUT1].NPoints do
     if (Regions[CycUT1].A[CycUT2] = Old) then
      Regions[CycUT1].A[CycUT2] := New;
  end;

 procedure TAirplane.DeleteUnusedPoints;
  var
   CycDU1, CycDU2 : Integer;
  begin
   CycDU1 := 0;
   while (CycDU1 < MPS.NPoints) do
    begin
     Inc(CycDU1);
     if (not(PointUsed(CycDU1))) then
      begin
       for CycDU2 := CycDU1 + 1 to MPS.NPoints do
        UpdateTargets(CycDU2, CycDU2 - 1);
       MPS.DeletePoint(CycDU1);
      end
    end;  
  end;

 procedure TAirplane.Simplify;
  var
   CycS1, CycS2, CycS3, CycS4 : Integer;
  begin
   CycS1 := 0;
   while (CycS1 < MPS.NPoints) do
    begin
     Inc(CycS1);
     CycS2 := CycS1 + 1;
     while (CycS2 <= MPS.NPoints) do
      if (PointsEq(MPS.GetPoint(CycS1), MPS.GetPoint(CycS2))) then
       begin
        MPS.DeletePoint(CycS2);
        for CycS3 := 1 to NRegions do
         for CycS4 := 1 to Regions[CycS3].NPoints do
          if (Regions[CycS3].A[CycS4] > CycS2) then
           Dec(Regions[CycS3].A[CycS4])
          else
           if (Regions[CycS3].A[CycS4] = CycS2) then
            Regions[CycS3].A[CycS4] := CycS1;
       end
      else
       Inc(CycS2);
    end;
  end;

{----TAnimation---}

procedure TAnimation.ReadData;
 begin
  A := Form1.ReadData;
 end;

procedure TAnimation.HighLightRow;
 begin
 // Form1.stgActions.Colors[CurStep] := clLightBlue;
  Form1.stgActions.Repaint;
 end;

procedure TAnimation.UnHighLightRow;
 begin
  //Form1.stgActions.Colors[CurStep] := clWhite;
  Form1.stgActions.Repaint;
 end;

procedure TAnimation.GetList;
 begin
  A.Show(Form1.ListVA, CurStep);
 end;

procedure TAnimation.GetScreen;
 begin
  A.Show(Form1.ScreenVA, CurStep);
 end;

procedure TAnimation.ShowList;
 begin
  Form1.ListVA.Show(Form1.imgList.Canvas, Form1.Options - ForbiddenOptions - [soShowSurface]);
 end;

procedure TAnimation.ShowScreen;
 begin
  Form1.ScreenVA.Show(Form1.imgScreen.Canvas, Form1.Options - ForbiddenOptions);
 end;

procedure TAnimation.GetDelay;
 begin
  CurDelay := Form1.trbSpeed.Position * 2;
 end;

procedure TAnimation.Delay;
 begin
  Synchronize(GetDelay);
  if (CurDelay > 0) then
   Sleep(CurDelay);
 end;

procedure TAnimation.GetNSteps;
 begin
  NSteps := Form1.stgActions.RowCount - 1
 end;

procedure TAnimation.ShowError;
 begin
  Form1.ShowError(A.LastError);
  Form1.ShowFoldError(A.LastFoldError);
 end;

procedure TAnimation.Run(Step : Integer);
 var
  CycR1, CycR2, CycR3, CycR4 : Integer;
  PL : T3DPointLine;
  S : Integer;
  P : TRegion;
  LA : TLengthArray;
  NoError : Boolean;
 begin
  for CycR3 := 1 to A.NRegions do
   for CycR4 := 1 to A.Regions[CycR3].NPoints do
    LA[CycR3, CycR4] := GetPointLineLength(A.Regions[CycR3].GetPointLine(CycR4));

  if ((A.Actions[Step].P1 > 0) and (A.Actions[Step].P2 > 0)) then
   begin
    PL[1] := A.GetPointByIndex(A.Actions[Step].P1);
    PL[2] := A.GetPointByIndex(A.Actions[Step].P2);
    P := TRegion.Create(A.MPS);
    for CycR1 := 1 to A.Actions[Step].NTargets do
     P.Copy(A.Regions[A.Actions[Step].Targets[CycR1]]);
    if (A.Actions[Step].Angle > 0) then
     S := 1
    else
     S := -1;
    CycR1 := 0;
    while ((CycR1 < Trunc(Abs(A.Actions[Step].Angle) * 10)) and (not(Terminated))) do
     begin
      Inc(CycR1);
      P.Rotate(PL, S * 0.1);

      NoError := true;
      for CycR3 := 1 to A.NRegions do
       for CycR4 := 1 to A.Regions[CycR3].NPoints do
        NoError := NoError and Eq(LA[CycR3, CycR4], GetPointLineLength(A.Regions[CycR3].GetPointLine(CycR4)));
      if (not(NoError)) then
       A.LastFoldError := Step;

      for CycR2 := 1 to A.Actions[Step].NTargets do
       A.Regions[A.Actions[Step].Targets[CycR2]].BasePoints.Rotate(PL, S * 0.1);
      if (A.Check(Step)) then
       begin
        CurStep := Step;
        Synchronize(GetScreen);
        ForbiddenOptions := [];
        Synchronize(ShowScreen);
       end;
      Synchronize(ShowError);
      Delay;
     end;
    P.Rotate(PL, A.Actions[Step].Angle - (Trunc(Abs(A.Actions[Step].Angle) * 10) * S * 0.1));
    for CycR2 := 1 to A.Actions[Step].NTargets do
     A.Regions[A.Actions[Step].Targets[CycR2]].BasePoints.Rotate(PL, A.Actions[Step].Angle - (Trunc(Abs(A.Actions[Step].Angle) * 10) * S * 0.1));
    if (A.Check(Step)) then
     begin
      CurStep := Step;
      Synchronize(GetScreen);
      Forbiddenoptions := [];
      Synchronize(ShowScreen);
     end;
    Synchronize(ShowError);
    P.Destroy;
    Delay;
   end;
 end;

constructor TAnimation.Create(CreateSuspended : Boolean = false);
 begin
  FreeOnTerminate := true;
  inherited Create(CreateSuspended);
 end;

{-----TStepByStepAnimation-----}

procedure TStepByStepAnimation.Execute;
 var
  CycE1 : Integer;
 begin
  Synchronize(GetNSteps);
  ForbiddenOptions := [soShowMassCenter];
  CycE1 := 0;
  while ((CycE1 < NSteps) and (not(Terminated))) do
   begin
    Inc(CycE1);
    CurStep := CycE1;
    Synchronize(HighLightRow);
    Synchronize(ReadData);
    if (A.DoActions(CycE1)) then
     if (A.Check(CycE1)) then
      begin
       Synchronize(GetList);
       Synchronize(ShowList);
       if ((CycE1 = 1) or (A.Check(CycE1 - 1))) then
        begin
         A.Fold(CycE1 - 1);
         if (A.Check(CycE1)) then
          Run(CycE1);
         Sleep(BetweenActionsDelay);
        end;
       Synchronize(ShowError);
      end;
    Synchronize(ShowError);
    A.Destroy;
    Synchronize(UnHighLightRow);
   end;
  ForbiddenOptions := [soShowMassCenter, soShowFoldingPoints];
  Synchronize(ShowList);
  Synchronize(ShowScreen);
 end;

{-----TSimpleAnimation-----}

procedure TSimpleAnimation.Execute;
 var
  CycE1 : Integer;
 begin
  Synchronize(ReadData);
  Synchronize(GetNSteps);
  ForbiddenOptions := [soShowMassCenter];
  if (A.DoActions) then
   begin
    CurStep := 0;
    Synchronize(GetList);
    Synchronize(ShowList);
    CycE1 := 0;
    while ((CycE1 < NSteps) and (not(Terminated))) do
     begin
      Inc(CycE1);
      CurStep := CycE1;
      Synchronize(HighLightRow);
      if (A.Check(CycE1)) then
       Run(CycE1);
      Synchronize(ShowError);
      Sleep(BetweenActionsDelay);
      Synchronize(UnHighLightRow);
     end;
    CurStep := 0;
    Synchronize(GetScreen);
    Synchronize(ShowScreen);
   end;
  Synchronize(ShowError);
  A.Destroy;
 end;

end.
