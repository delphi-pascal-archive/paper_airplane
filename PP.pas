{$Q+,R+}

unit PP;

interface
 uses
  GTypes,
  Graphics,
  Geometry;
 type
  TPointSet = class
   private
    fNPoints : Integer;
    fRotated : Boolean;
    function  GetRealIndex(N : Integer) : Integer;
    procedure ShiftLeft(Pos : Integer; Offset : Integer = 1); virtual; abstract;
    procedure ShiftRight(Pos : Integer; Offset : Integer = 1); virtual; abstract;
   public
    property  NPoints : Integer read fNPoints;
    procedure AddPoint(P : T3DPoint); overload; virtual; abstract;
    procedure AddPoint(X, Y : TFloat); overload; virtual; abstract;
    procedure DeletePoint(Pos : Integer; N : Integer = 1); virtual; abstract;
    function  GetPoint(Pos : Integer) : T3DPoint; virtual; abstract;
    procedure Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []); virtual; abstract;
    procedure Clear; virtual;
  end;

  TMainPointSet = class(TPointSet)
   private
    A : T3DPointArray;
    procedure ShiftLeft(Pos : Integer; Offset : Integer = 1); override;
    procedure ShiftRight(Pos : Integer; Offset : Integer = 1); override;
   public
    constructor Create;
    procedure AddPoint(P : T3DPoint); override;
    procedure DeletePoint(Pos : Integer; N : Integer = 1); override;
    function  GetPoint(Pos : Integer) : T3DPoint; override;
    procedure Rotate(L : TPointLine; Alpha : TFloat); overload; virtual;
    procedure Rotate(V : TRotationVector); overload;
    procedure Mirror(L : TLine); overload; virtual;
    procedure Mirror(PL : TPointLine); overload; virtual;
    procedure GetFrom(Source : TMainPointSet);
    procedure Copy(Source : TMainPointSet);
    procedure RestoreIfNotEqual(Base, Old : TMainPointSet);  {Base[i] = Old[i] ? Self[i] : Old[i]}
    procedure Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []); override;
  end;

  TVirtualPointSet = class(TPointSet)
   private
    fMPS : TMainPointSet;
    procedure ShiftLeft(Pos : Integer; Offset : Integer = 1); override;
    procedure ShiftRight(Pos : Integer; Offset : Integer = 1); override;
    function  GetRotated : Boolean;
   public
    A : TIntegerArray;
    constructor Create(MPSNew : TMainPointSet);
    property  Rotated : Boolean read GetRotated;
    property  MPS : TMainPointSet read fMPS write fMPS;
    procedure AddPoint(P : T3DPoint); overload; override;
    procedure AddPoint(X, Y : TFloat); overload; override;
    procedure DeletePoint(Pos : Integer; N : Integer = 1); override;
    function  GetPoint(Pos : Integer) : T3DPoint; override;
    procedure Rotate(L : TPointLine; Alpha : TFloat); virtual;
    procedure Mirror(L : TLine); overload; virtual;
    procedure Mirror(PL : TPointLine); overload; virtual;
    procedure Mirror(P1, P2 : T3DPoint); overload; virtual;
    procedure GetSurfacePoints(var P1, P2, P3 : T3DPoint);
    procedure Simplify; virtual;
    procedure Clear; override;
    procedure GetFrom(Source : TVirtualPointSet);
    procedure Copy(Source : TVirtualPointSet);
    procedure Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []); override;
  end;

  TIndexedPointSet = class(TMainPointSet)
   private
    I : TIntegerArray;
    procedure ShiftLeft(Pos : Integer; Offset : Integer = 1); override;
    procedure ShiftRight(Pos : Integer; Offset : Integer = 1); override;
   public
    procedure AddPoint(P : T3DPoint); override;
    procedure AddIndexedPoint(P : T3DPoint; Index : Integer); overload;
    procedure AddIndexedPoint(X, Y : TFloat; Index : Integer); overload;
    function  HasIndex(Index : Integer) : Boolean;
    function  GetPointByIndex(Index : Integer) : T3DPoint;
    function  GetIndex(Pos : Integer) : Integer;
    procedure Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []); override;
  end;

 TPolygon = class(TVirtualPointSet)
  public
   function  GetPointLine(Index : Word) : TPointLine;
   function  CrossLine(L : TLine) : Boolean; overload;
   function  CrossLine(PL : TPointLine) : Boolean; overload;
   function  GetCrossedPolygon(L : TLine; Sign : TSign) : TPolygon; overload; virtual;
   function  GetCrossedPolygon(PL : TPointLine; Sign : TSign) : TPolygon; overload; virtual;
   function  GetSpace : TFloat;
   function  PointInPolygon(P : T3DPoint) : Boolean;
   function  GetToPointDist(P : T3DPoint) : TFloat;
   procedure Simplify; override;
   function  GetCenterPoint : T3DPoint;
   function  GetNormalVector : TVector;
   procedure Copy(Source : TPolygon);
   procedure Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []); override;
 end;

 TRegion = class;
 TRegionArray = array[1..NRegionMax] of TRegion;
 TRegion = class(TPolygon)
  private
   IPS : TIndexedPointSet;
  public
   constructor Create(MPSNew : TMainPointSet);
   destructor  Destroy; override;
   property  BasePoints : TIndexedPointSet read IPS;
   function  GetCrossedRegion(L : TLine; Sign : TSign) : TRegion; overload;
   function  GetCrossedRegion(PL : TPointLine; Sign : TSign) : TRegion; overload;
   procedure GetCrossedRegions(L : TLine; var R : TRegionArray; var N : Integer); overload;
   procedure GetCrossedRegions(PL : TPointLine; var R : TRegionArray; var N : Integer); overload;
   function  GetPosition(L : TLine) : TSign; overload;
   function  GetPosition(PL : TPointLine) : TSign; overload;
   procedure Rotate(L : TPointLine; Alpha : TFloat); override;
   procedure Mirror(L : TLine); overload; override;
   procedure Mirror(PL : TPointLine); overload; override;
   procedure Mirror(P1, P2 : T3DPoint); overload; override;
   procedure GetFrom(Source : TRegion);
   procedure Copy(Source : TRegion);
   procedure Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []); override;
   procedure ShowHighlited(C : TCanvas; V : TRotationVector; Options : TShowOptions = []);
 end;

 TIdLine = record
  P1, P2 : Word;
 end;
 TIdLineArray = array[1..MaxLines] of TIdLine;

 TLineSet = class(TMainPointSet)
  private
   LA : TIdLineArray;
   fNLines : Word;
  public
   constructor Create;
   procedure AddLine(P1, P2 : T3DPoint); overload;
   procedure AddLine(PL : TPointLine); overload;
   procedure AddPolygon(P : TPolygon);
   procedure Clear; override;
   procedure Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []); override;
   procedure ShowScaled(C : TCanvas; Width, Height : Integer; V : TRotationVector);
 end;


implementation
 uses
  SysUtils,
  Types;

{-----TPointSet-----}

function TPointSet.GetRealIndex(N : Integer) : Integer;
 begin
  Result := ((NPoints + N - 1) mod NPoints) + 1
 end;

procedure TPointSet.Clear;
 begin
  fNPoints := 0;
 end;

{-----TMainPointSet-----}

 procedure TMainPointSet.ShiftLeft(Pos : Integer; Offset : Integer = 1);
  var
   CycSL1 : Integer;
  begin
   Assert(Pos >= Offset);
   for CycSL1 := Pos to fNPoints do
    A[CycSL1 - Offset] := A[CycSL1];
   Dec(fNPoints, Offset);
  end;

 procedure TMainPointSet.ShiftRight(Pos : Integer; Offset : Integer = 1);
  var
   CycSR1 : Integer;
  begin
   for CycSR1 := fNPoints downto Pos do
    A[CycSR1 + Offset] := A[CycSR1];
   Inc(fNPoints, Offset);
  end;

 constructor TMainPointSet.Create;
  begin
   fNPoints := 0;
   fRotated := false;
  end;

 procedure TMainPointSet.AddPoint(P : T3DPoint);
  begin
   if (fNPoints >= NPointsMax) then
    Beep;
   Assert(fNPoints < NPointsMax, 'Too Many Points' + IntToStr(fNPoints));
   Inc(fNPoints);
   A[fNpoints] := P;
  end;

 procedure TMainPointSet.DeletePoint(Pos : Integer; N : Integer = 1);
  begin
   Assert(((Pos + N - 1) <= fNPoints) and (Pos > 0));
   ShiftLeft(Pos + N, N);
  end;

 function TMainPointSet.GetPoint(Pos : Integer) : T3DPoint;
  begin
   Assert((Pos > 0) and (Pos <= fNPoints));
   Result := A[Pos];
  end;

 procedure TMainPointSet.Rotate(L : TPointLine; Alpha : TFloat);
  var
   CycR1 : Integer;
  begin
   fRotated := true;
   for CycR1 := 1 to NPoints do
    A[CycR1] := GetRotatedPoint(A[CycR1], L, Alpha);
  end;

 procedure TMainPointSet.Rotate(V : TRotationVector);
  var
   CycR1 : Integer;
  begin
   fRotated := true;
   for CycR1 := 1 to NPoints do
    A[CycR1] := GetRotatedPoint(A[CycR1], V);
  end;

 procedure TMainPointSet.Mirror(L : TLine);
  var
   CycM1 : Integer;
  begin
   for CycM1 := 1 to fNPoints do
    A[CycM1] := GetMirroredPoint(L, A[CycM1]);
  end;

 procedure TMainPointSet.Mirror(PL : TPointLine);
  begin
   Mirror(GetLineBypointLine(PL));
  end;

 procedure TMainPointSet.GetFrom(Source : TMainPointSet);
  var
   CycG1 : Integer;
  begin
   Clear;
   for CycG1 := 1 to Source.NPoints do
    begin
     Inc(fNPoints);
     A[NPoints] := Source.A[CycG1];
    end;
  end;

 procedure TMainPointSet.Copy(Source : TMainPointSet);
  var
   CycC1, CycC2 : Integer;
   Exists       : Boolean;
  begin
   for CycC1 := 1 to Source.NPoints do
    begin
     Exists := false;
     for CycC2 := 1 to fNPoints do
      Exists := Exists or (PointsEq(A[CycC2], Source.A[CycC1]));
     if (not(Exists)) then
      begin
       Inc(fNPoints);
       A[NPoints] := Source.A[CycC1];
      end;
    end;
  end;

 procedure TMainPointSet.RestoreIfNotEqual(Base, Old : TMainPointSet);  {Base[i] = Old[i] ? Self[i] : Old[i]}
  var
   CycR1 : Integer;
  begin
   Assert((NPoints = Base.NPoints) and (NPoints = Old.NPoints));
   for CycR1 := 1 to NPoints do
    if (not(PointsEq(Base.A[CycR1], Old.A[CycR1]))) then
     A[CycR1] := Old.A[CycR1];
  end;

 procedure TMainPointSet.Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []);
  var
   CycS1 : Word;
   P : T2DPoint;
  begin
   if (soShowBasePoints in Options) then
    for CycS1 := 1 to fNPoints do
     begin
      P := Project(GetRotatedPoint(GetPoint(CycS1), V));
      C.Ellipse(X0 + Trunc(P.X) - 5, YMax - Trunc(P.Y) - 5, X0 +  Trunc(P.X) + 5, YMax - Trunc(P.Y) + 5);
     end;
  end;

{-----TVisualPointSet-----}

 procedure TVirtualPointSet.ShiftLeft(Pos : Integer; Offset : Integer = 1);
  var
   CycSL1 : Integer;
  begin
   Assert(Pos >= Offset);
   for CycSL1 := Pos to fNPoints do
    A[CycSL1 - Offset] := A[CycSL1];
   Dec(fNPoints, Offset);
  end;

 procedure TVirtualPointSet.ShiftRight(Pos : Integer; Offset : Integer = 1);
  var
   CycSR1 : Integer;
  begin
   for CycSR1 := fNPoints downto Pos do
    A[CycSR1 + Offset] := A[CycSR1];
   Inc(fNPoints, Offset);
  end;

 function TVirtualPointSet.GetRotated : Boolean;
  begin
   Result := fRotated;
  end;

 constructor TVirtualPointSet.Create(MPSNew : TMainPointSet);
  begin
   fNPoints := 0;
   fMPS := MPSNew;
   fRotated := false;
  end;

 procedure TVirtualPointSet.AddPoint(P : T3DPoint);
  begin
   Assert(fNPoints < NPointsMax, 'Too Many Points');
   fMPS.AddPoint(P);
   Inc(fNPoints);
   A[fNPoints] := fMPS.NPoints
  end;

 procedure TVirtualPointSet.AddPoint(X, Y : TFloat);
  var
   P : T3DPoint;
  begin
   P.X := X;
   P.Y := Y;
   P.Z := 0;
   AddPoint(P);
  end;

 procedure TVirtualPointSet.DeletePoint(Pos : Integer; N : Integer = 1);
  begin
   Assert(((Pos + N) <= fNPoints + 1) and (Pos > 0));
   ShiftLeft(Pos + N, N);
  end;

 function  TVirtualPointSet.GetPoint(Pos : Integer) : T3DPoint;
  begin
   Assert((Pos > 0) and (Pos <= fNPoints) and (A[Pos] <= fMPS.NPoints));
   Result := fMPS.GetPoint(A[Pos]);
  end;

 procedure TVirtualPointSet.Rotate(L : TPointLine; Alpha : TFloat);
  var
   CycR1 : Integer;
  begin
   fRotated := true;
   for CycR1 := 1 to NPoints do
    fMPS.A[A[CycR1]] := GetRotatedPoint(fMPS.A[A[CycR1]], L, Alpha);
  end;

 procedure TVirtualPointSet.Mirror(L : TLine);
  var
   CycM1 : Integer;
  begin
   for CycM1 := 1 to fNPoints do
    fMPS.A[A[CycM1]] := GetMirroredPoint(L, fMPS.A[A[CycM1]]);
  end;

 procedure TVirtualPointSet.Mirror(PL : TPointLine);
  begin
   Mirror(GetLineBypointLine(PL));
  end;

 procedure TVirtualpointSet.Mirror(P1, P2 : T3DPoint);
  var
   PL : T3DPointLine;
  begin
   PL[1] := P1;
   PL[2] := P2;
   Mirror(GetLineByPointLine(PL));
  end;

 procedure TVirtualPointSet.GetSurfacePoints(var P1, P2, P3 : T3DPoint);
  var
   CycS1 : Integer;
  begin
   P1 := GetPoint(1);
   CycS1 := 2;
   while ((CycS1 <= NPoints) and (PointsEq(GetPoint(CycS1), P1))) do
    Inc(CycS1);
   P2 := GetPoint(CycS1);
   CycS1 := CycS1 + 1;
   while ((CycS1 <= NPoints) and (PointsEq(GetPoint(CycS1), P1)) and (PointsEq(GetPoint(CycS1), P2))) do
    Inc(CycS1);
   P3 := GetPoint(CycS1);
  end;

 procedure TVirtualPointSet.Simplify;
  var
   CycS1 : Integer;
  begin
   CycS1 := 1;
   while (CycS1 <= fNPoints) do
    if (PointsEq(GetPoint(CycS1),  GetPoint(GetRealIndex(CycS1 + 1)))) then
     DeletePoint(CycS1)
    else
     Inc(CycS1);
  end;

 procedure TVirtualPointSet.Clear;
  begin
   inherited Clear;
   fRotated := false;
  end;

 procedure TVirtualPointSet.GetFrom(Source : TVirtualPointSet);
  var
   CycG1 : Integer;
  begin
   Clear;
   for CycG1 := 1 to Source.NPoints do
    begin
     Inc(fNPoints);
     A[NPoints] := Source.A[CycG1];
    end;
  end;

 procedure TVirtualPointSet.Copy(Source : TVirtualPointSet);
  var
   CycC1, CycC2 : Integer;
   Exists       : Boolean;
  begin
   for CycC1 := 1 to Source.NPoints do
    begin
     Exists := false;
     for CycC2 := 1 to fNPoints do
      Exists := Exists or (A[CycC2] = Source.A[CycC1]);
     if (not(Exists)) then
      begin
       Inc(fNPoints);
       A[NPoints] := Source.A[CycC1];
      end;
    end;
  end;

 procedure TVirtualPointSet.Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []);
  var
   CycS1 : Word;
   P : T2DPoint;
  begin
   if (soShowBasePoints in Options) then
    for CycS1 := 1 to fNPoints do
     begin
      P := Project(GetRotatedPoint(GetPoint(CycS1), V));
      C.Ellipse(X0 + Trunc(P.X) - 5, YMax - Trunc(P.Y) - 5, X0 +  Trunc(P.X) + 5, YMax - Trunc(P.Y) + 5);
     end;
  end;

{-----TIndexedPointSet-----}             

 procedure TIndexedPointSet.ShiftLeft(Pos : Integer; Offset : Integer = 1);
  var
   CycSL1 : Integer;
  begin
   Assert(Pos >= Offset);
   for CycSL1 := Pos to fNPoints do
    I[CycSL1 - Offset] := I[CycSL1];
   inherited ShiftLeft(Pos, Offset);
  end;

 procedure TIndexedPointSet.ShiftRight(Pos : Integer; Offset : Integer = 1);
  var
   CycSR1 : Integer;
  begin
   for CycSR1 := fNPoints downto Pos do
    I[CycSR1 + Offset] := I[CycSR1];
   inherited ShiftRight(Pos, Offset);
  end;

 procedure TIndexedPointSet.AddPoint(P : T3DPoint);
  begin
   AddIndexedPoint(P, 0);
  end;

 procedure TIndexedPointSet.AddIndexedPoint(P : T3DPoint; Index : Integer);
  begin
   inherited AddPoint(P);
   I[NPoints] := Index;
  end;

 procedure TIndexedPointSet.AddIndexedPoint(X, Y : TFloat; Index : Integer);
  var
   P3D : T3DPoint;
  begin
   P3D.X := X;
   P3D.Y := Y;
   P3D.Z := 0;
   AddIndexedPoint(P3D, Index);
  end;

 function TIndexedPointSet.HasIndex(Index : Integer) : Boolean;
  var
   CycHI1 : Integer;
  begin
   Result := false;
   for CycHI1 := 1 to NPoints do
    Result := Result or (I[CycHI1] = Index);
  end;

 function TIndexedPointSet.GetPointByIndex(Index : Integer) : T3DPoint;
  var
   CycGP1 : Integer;
  begin
   Assert(HasIndex(Index));
   for CycGP1 := 1 to NPoints do
    if (I[CycGP1] = Index) then
     Result := GetPoint(CycGP1);
  end;

 function TIndexedPointSet.GetIndex(Pos : Integer) : Integer;
  begin
   Assert((Pos > 0) and (Pos <= NPoints));
   Result := I[Pos];
  end;

 procedure TIndexedPointSet.Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []);
  var
   CycS1 : Word;
   P     : T2DPoint;
  begin
   inherited Show(C, V, Options);
   if (soShowBasePointsIndex in Options) then
    begin
     C.Font.Color := clRed;
     for CycS1 := 1 to NPoints do
      begin
       P := Project(GetRotatedPoint(GetPoint(CycS1), V));
       C.TextOut(X0 + Trunc(P.X) - C.TextWidth(IntToStr(I[CycS1])) div 2, YMax - Trunc(P.Y) -  C.TextHeight(IntToStr(I[CycS1])) div 2 , IntToStr(I[CycS1]));
      end;
     C.Font.Color := clBlack;
    end;
  end;

{-----TPolygon-----}

 function TPolygon.GetPointLine(Index : Word) : TPointLine;
  begin
   Result[1] := GetPoint(GetRealIndex(Index));
   Result[2] := GetPoint(GetRealIndex(Index + 1));
  end;

 function TPolygon.CrossLine(L : TLine) : Boolean;
  var
   CycCL1 : Word;
  begin
   Assert(not(Rotated), 'Can''t divide rotated polygon');
   Result := false;
   for CycCL1 := 1 to NPoints do
    Result := Result or (LineCrossPointLine(L, GetPointLine(CycCL1)));
  end;

 function TPolygon.CrossLine(PL : TPointLine) : Boolean;
  begin
   Result := CrossLine(GetLineByPointLine(PL));
  end;

 function TPolygon.GetCrossedPolygon(L : TLine; Sign : TSign) : TPolygon;
  var
   CycGC1 : Word;
  begin
   Assert(not(Rotated), 'Can''t divide rotated polygon');
   if (CrossLine(L)) then
    begin
     Result := TPolygon.Create(fMPS);
     CycGC1 := 0;
     while (CycGC1 < NPoints) do
      begin
       Inc(CycGC1);
       if ((GetPointToLineDist(GetPoint(CycGC1), L) > 0) xor (Sign = sgLess)) then
        Result.AddPoint(GetPoint(CycGC1));
       if (LineCrossPointLine(L, GetPointLine(CycGC1))) then
        Result.AddPoint(GetLinePointLineIntersection(L, GetPointLine(CycGC1)));
      end;
    end
   else
    Result := NIL
  end;

 function TPolygon.GetCrossedPolygon(PL : TPointLine; Sign : TSign) : TPolygon;
  begin
   Result := GetCrossedPolygon(GetLineByPointLine(PL), Sign);
  end;

 function TPolygon.GetSpace : TFloat;
  var
   CycGS1 : Integer;
   PL : TPointLine;
  begin
   Result := 0;
   for CycGS1 := 1 to NPoints do
    begin
     PL := GetPointLine(CycGS1);
     Result := Result + (PL[2].X - PL[1].X) * (PL[1].Y + PL[2].Y) / 2;
    end;
   Result := Abs(Result); 
  end;

 function TPolygon.PointInPolygon(P : T3DPoint) : Boolean;
  var
   CycPIP1, Cnt : Integer;
   L : TLine;
   PL, PLOld : TPointLine;
   P0 : T3DPoint;
   Res : Boolean;
  begin
   L.A := 0;
   L.B := 1;
   L.C := -P.Y;
   Cnt := 0;
   Res := false;
   for CycPIP1 := 1 to NPoints do
    if (LineCrossPointLine(L, GetPointLine(CycPIP1))) then
     begin
      PL := GetPointLine(CycPIP1);
      PLOld := GetPointLine(CycPIP1 - 1);
      P0 := GetLinePointLineIntersection(L, GetPointLine(CycPIP1));
      if (Eq(P0.X, P.X)) then
       Res := true;
      if ((not((Eq(P0.Y, PL[1].Y)) and (Eq(P0.Y, PL[2].Y)))) and
          ((not((PointsEq(P0, PL[1])) or (PointsEq(P0, PL[2])))) or
           (((PL[2].Y > PL[1].Y) and (PointsEq(P0, PL[2]))) or
            ((PL[1].Y > PL[2].Y) and (PointsEq(P0, PL[1]))))) and
          (P0.X > P.X)) then
       Inc(Cnt);
     end;
   Result := Odd(Cnt) or Res;
  end;

 function TPolygon.GetToPointDist(P : T3DPoint) : TFloat;
  var
   CycGT1 : Integer;
  begin
   if (PointInPolygon(P)) then
    Result := 0
   else
    begin
     Result := GetPointToPointLineDist(P, GetPointLine(1));
     for CycGT1 := 2 to NPoints do
      if (GetPointToPointLineDist(P, GetPointLine(CycGT1)) < Result) then
       Result := GetPointToPointLineDist(P, GetPointLine(CycGT1));
    end;
  end;

 procedure TPolygon.Simplify;
  var
   CycS1 : Integer;
   PL : TPointLine;
  begin
   inherited Simplify;
   CycS1 := 1;
   while (CycS1 <= fNPoints) do
    begin
     PL[1] := GetPoint(CycS1);
     PL[2] := GetPoint(GetRealIndex(CycS1 + 2));
     if (Eq(GetPointToLineDist(GetPoint(GetRealIndex(CycS1 + 1)), GetLineByPointLine(PL)))) then
      DeletePoint(GetRealIndex(CycS1 + 1))
     else
      Inc(CycS1);
    end;
  end;                         

 function TPolygon.GetCenterPoint : T3DPoint;
  var
   CycGCP1 : Word;
  begin
   Result.X := 0;
   Result.Y := 0;
   Result.Z := 0;
   if (NPoints > 0) then
    begin
     for CycGCP1 := 1 to NPoints do
      begin
       Result.X := Result.X + GetPoint(CycGCP1).X;
       Result.Y := Result.Y + GetPoint(CycGCP1).Y;
       Result.Z := Result.Z + GetPoint(CycGCP1).Z;
      end;
     Result.X := Result.X / NPoints;
     Result.Y := Result.Y / NPoints;
     Result.Z := Result.Z / NPoints;
    end;
  end;

 function TPolygon.GetNormalVector : TVector;
  var
   CycN1, CycN2 : Integer;
  begin
   CycN1 := 0;
   repeat
    Inc(CycN1);
    CycN2 := CycN1 - 1;
    repeat
     Inc(CycN2);
    until ((CycN2 = NPoints) or ((CycN1 <> CycN2) and (not(Eq(GetPointLineLength(GetPointLine(CycN1))))) and (not(Eq(GetPointLineLength(GetPointLine(CycN2))))) and (not(Eq(AbsV(MulVec(GetVectorByPointLine(GetPointLine(CycN1)), GetVectorByPointLine(GetPointLine(CycN2)))))))));
   until ((CycN1 = NPoints) or ((CycN1 <> CycN2) and (not(Eq(GetPointLineLength(GetPointLine(CycN1))))) and (not(Eq(GetPointLineLength(GetPointLine(CycN2))))) and (not(Eq(AbsV(MulVec(GetVectorByPointLine(GetPointLine(CycN1)), GetVectorByPointLine(GetPointLine(CycN2)))))))));
   Result := MulVec(GetVectorByPointLine(GetPointLine(CycN1)), GetVectorByPointLine(GetPointLine(CycN2)))
  end;

 procedure TPolygon.Copy(Source : TPolygon);
  var
   CycC1, CycC2 : Integer;
   Exists       : Boolean;
  begin
   for CycC1 := 1 to Source.NPoints do
    begin
     Exists := false;
     for CycC2 := 1 to fNPoints do
      Exists := Exists or (A[CycC2] = Source.A[CycC1]);
     if (not(Exists)) then
      begin
       Inc(fNPoints);
       A[NPoints] := Source.A[CycC1];
      end;
    end;
  end;

 procedure TPolygon.Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []);
  var
   CycS1 : Word;
   P : T2DPoint;
  begin
   P := Project(Getpoint(NPoints));
   C.MoveTo(X0 + Trunc(P.X), YMax - Trunc(P.Y));
   for CycS1 := 1 to NPoints do
    begin
     P := Project(Getpoint(CycS1));
     C.LineTo(X0 + Trunc(P.X), YMax - Trunc(P.Y));
    end;
  end;


{-----TRegion-----}

 constructor TRegion.Create(MPSNew : TMainPointSet);
  begin
   inherited Create(MPSNew);
   IPS := TIndexedPointSet.Create;
  end;

 destructor TRegion.Destroy;
  begin
   IPS.Destroy;
   inherited Destroy;
  end;

 function TRegion.GetCrossedRegion(L : TLine; Sign : TSign) : TRegion;
  var
   P : TPolygon;
   CycGC1 : Word;
  begin
   Assert(not(Rotated), 'Can''t divide rotated region');
   if (CrossLine(L)) then
    begin
     Result := TRegion.Create(fMPS);
     P := GetCrossedPolygon(L, Sign);
     Result.fNPoints := P.fNPoints;
     Result.A := P.A;
     for CycGC1 := 1 to BasePoints.fNPoints do
      if ((GetPointToLineDist(BasePoints.GetPoint(CycGC1), L) > 0) xor (Sign = sgLess)) then
       Result.BasePoints.AddIndexedPoint(BasePoints.GetPoint(CycGC1), BasePoints.I[CycGC1]);
     P.Destroy;
    end
   else
    Result := NIL
  end;

 function TRegion.GetCrossedRegion(PL : TPointLine; Sign : TSign) : TRegion;
  begin
   Result := GetCrossedRegion(GetLineByPointLine(PL), Sign);
  end;

 procedure TRegion.GetCrossedRegions(L : TLine; var R : TRegionArray; var N : Integer);
  var
   NewRegion : TRegion;
   CycGC1, CycGC2, CycGC3, TmpV, NUsedPoints, NNewPoints, StartPoint, EndPoint, MinI : Integer;
   NewPoints : TIntegerArray;
   IsUsedPoint, IsNewPoint : TBooleanArray;
   PI : T3DPoint;
   PL : TPointLine;
  begin
   Assert(not(Rotated), 'Can''t divide rotated region');
   if (CrossLine(L)) then
    begin
{8.03} Simplify;
     NewRegion := TRegion.Create(fMPS);
     NNewPoints := 0;
     for CycGC1 := 1 to fNPoints do
      begin
       NewRegion.AddPoint(GetPoint(CycGC1));
       IsUsedPoint[NewRegion.NPoints] := false;
       IsNewPoint[NewRegion.NPoints] := false;
       PL := GetPointLine(CycGC1);
       if (LineCrossPointLine(L, PL)) then
        begin
         PI := GetLinePointLineIntersection(L, PL);
{         if (
             (not(
              (PointsEq(PL[1], PI)) or
              (PointsEq(PL[2], PI))
             )) or
             (
              ((not(Eq(GetPointToLineDist(PL[1], L)))) and (GetPointToLineDist(PL[1], L) > 0)) or
              ((not(Eq(GetPointToLineDist(PL[2], L)))) and (GetPointToLineDist(PL[2], L) > 0))

              )) then}
         if (
             (not(
              (PointsEq(PL[1], PI)) or
              (PointsEq(PL[2], PI))
             ))
              or
             (
              ((not(Eq(GetPointToLineDist(PL[1], L)))) and (GetPointToLineDist(PL[1], L) > 0)) or
              ((not(Eq(GetPointToLineDist(PL[2], L)))) and (GetPointToLineDist(PL[2], L) > 0))
             )
            ) then
          begin
           NewRegion.AddPoint(PI);
           IsUsedPoint[NewRegion.NPoints] := false;
           IsNewPoint[NewRegion.NPoints] := true;
           Inc(NNewPoints);
           NewPoints[NNewPoints] := NewRegion.NPoints;
          end;
        end;
      end;
     for CycGC1 := 1 to NNewPoints do
      for CycGC2 := CycGC1 + 1 to NNewPoints do
       if ((NewRegion.GetPoint(NewPoints[CycGC1]).X < NewRegion.GetPoint(NewPoints[CycGC2]).X) or
           ((Eq(NewRegion.GetPoint(NewPoints[CycGC1]).X, NewRegion.GetPoint(NewPoints[CycGC2]).X)) and
            (NewRegion.GetPoint(NewPoints[CycGC1]).Y < NewRegion.GetPoint(NewPoints[CycGC2]).Y))) then
        begin
         TmpV := NewPoints[CycGC1];
         NewPoints[CycGC1] := NewPoints[CycGC2];
         NewPoints[CycGC2] := TmpV;
        end;

{     WriteLn('Base Region');
     for CycGC1 := 1 to NPoints do
      WriteLn(GetPoint(CycGC1).X:0:2, #9, GetPoint(CycGC1).Y:0:2);
     WriteLn;
     WriteLn('Line');
     WriteLn('A = ', L.A:0:2);
     WriteLn('B = ', L.B:0:2);
     WriteLn('C = ', L.C:0:2);
     WriteLn;
     WriteLn('New Region');
     for CycGC1 := 1 to NewRegion.NPoints do
      WriteLn(NewRegion.GetPoint(CycGC1).X:0:2, #9, NewRegion.GetPoint(CycGC1).Y:0:2);
     WriteLn;}


     NUsedPoints := 0;
     N := 0;
     while (NUsedPoints < fNPoints) do
      begin
       Inc(N);
       R[N] := TRegion.Create(fMPS);
       CycGC1 := 1;
       while ((CycGC1 <= NewRegion.fNPoints) and ((IsNewPoint[CycGC1]) or (IsUsedPoint[CycGC1]))) do
        Inc(CycGC1);
       Assert(CycGC1 <= NewRegion.fNPoints);
       StartPoint := CycGC1;
       EndPoint := StartPoint;
       Inc(NUsedPoints);
       repeat
        IsUsedPoint[EndPoint] := true;
        R[N].AddPoint(NewRegion.GetPoint(EndPoint));
        if (IsNewPoint[EndPoint]) then
         begin
          CycGC1 := 1;
          while((CycGC1 <= NNewPoints) and (NewPoints[CycGC1] <> EndPoint)) do
           Inc(CycGC1);
          if ((CycGC1 <= NNewPoints) and (NewPoints[CycGC1] = EndPoint)) then
           EndPoint := NewPoints[CycGC1 + 2 * (CycGC1 mod 2) - 1]
          else
           Assert(false);
          Assert(EndPoint <= NewRegion.NPoints);
          Assert(IsNewPoint[EndPoint]);
          IsUsedPoint[EndPoint] := true;
          R[N].AddPoint(NewRegion.GetPoint(EndPoint));
         end;
        EndPoint := (EndPoint mod NewRegion.NPoints) + 1;
        if ((not(IsUsedPoint[EndPoint])) and (not(IsNewPoint[EndPoint]))) then
         Inc(NUsedPoints);
       until (EndPoint = StartPoint);
      end;
     NewRegion.Destroy;
     for CycGC1 := 1 to N do
      R[CycGC1].Simplify;
     for CycGC1 := 1 to BasePoints.NPoints do
      begin
       MinI := 1;
       while ((MinI < N) and (Eq(R[MinI].GetSpace))) do
        Inc(MinI);
       for CycGC2 := MinI + 1 to N do
        if ((not(Eq(R[CycGC2].GetSpace))) and (R[CycGC2].GetToPointDist(BasePoints.GetPoint(CycGC1)) < R[MinI].GetToPointDist(BasePoints.GetPoint(CycGC1)))) then
         MinI := CycGC2;
       R[MinI].BasePoints.AddIndexedPoint(BasePoints.A[CycGC1], BasePoints.I[CycGC1]);
      end;
    end;
  end;

 procedure TRegion.GetCrossedRegions(PL : TPointLine; var R : TRegionArray; var N : Integer);
  begin
   GetCrossedRegions(GetLineByPointLine(PL), R, N);
  end;

 function TRegion.GetPosition(L : TLine) : TSign;
  var
   CycGP1, Res : Integer;
  begin
   Res := 0;
   for CycGP1 := 1 to NPoints do
    if (not(Eq(GetPointToLineDist(GetPoint(CycGP1), L)))) then
     if (GetPointToLineDist(GetPoint(CycGP1), L) > 0) then
      begin
   //    Assert(Res <> -1);
       Res := 1
      end
     else
      if (GetPointToLineDist(GetPoint(CycGP1), L) < 0) then
       begin
  //      Assert(Res <> 1);
        Res := -1;
       end;
   if (Res = -1) then
    Result := sgLess
   else
    if (Res = 1) then
     Result := sgGreater
    else
     begin
//      Assert(Res <> 0{false});
{//}  Result := sgGreater;
     end;
  end;

 function TRegion.GetPosition(PL : TPointLine) : TSign;
  begin
   Result := GetPosition(GeTLineByPointLine(PL));
  end;

 procedure TRegion.Rotate(L : TPointLine; Alpha : TFloat);
  begin
   inherited Rotate(L, Alpha);
   BasePoints.Rotate(L, Alpha);
  end;

 procedure TRegion.Mirror(L : TLine);
  begin
   inherited Mirror(L);
   BasePoints.Mirror(L);
  end;

 procedure TRegion.Mirror(PL : TPointLine);
  begin
   Mirror(GetLineByPointLine(PL));
  end;

 procedure TRegion.Mirror(P1, P2 : T3DPoint);
  var
   PL : T3DPointLine;
  begin
   PL[1] := P1;
   PL[2] := P2;
   Mirror(GetLineByPointLine(PL));
  end;

 procedure TRegion.GetFrom(Source : TRegion);
  begin
   inherited GetFrom(Source);
   BasePoints.GetFrom(Source.BasePoints);
  end;

 procedure TRegion.Copy(Source : TRegion);
  var
   CycC1, CycC2 : Integer;
   Exists       : Boolean;
  begin
   for CycC1 := 1 to Source.NPoints do
    begin
     Exists := false;
     for CycC2 := 1 to fNPoints do
      Exists := Exists or (A[CycC2] = Source.A[CycC1]);
     if (not(Exists)) then
      begin
       Inc(fNPoints);
       A[NPoints] := Source.A[CycC1];
      end;
    end;
  end;

 procedure TRegion.Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []);
  begin
   BasePoints.Show(C, V, Options);
   inherited Show(C, V, Options);
  end;

 procedure TRegion.ShowHighlited(C : TCanvas; V : TRotationVector; Options : TShowOptions = []);
  var
   PA : array of TPoint;
   CycSP1 : Word;
   PP : T2DPoint;
  begin
   SetLength(PA, NPoints);
   for CycSP1 := 0 to NPoints - 1 do
    begin
     PP := Project(GetRotatedPoint(Getpoint(CycSP1 + 1), V));
     PA[CycSP1].X := X0 + Trunc(PP.X);
     PA[CycSP1].Y := YMax - Trunc(PP.Y);
    end;
   if (soShowTargets in Options) then
    begin
     C.Brush.Color := clLightRed;
     C.Pen.Color := clLightRed;
    end
   else
    C.Brush.Color := clWhite;
   C.Polygon(PA);
   BasePoints.Show(C, V, Options);
   C.Brush.Color := clWhite;
   C.Pen.Color := clBlack;
  end;

{-----TLineSet-----}

 constructor TLineSet.Create;
  begin
   inherited Create;
   fNLines := 0;
  end;

 procedure TLineSet.AddLine(P1, P2 : T3DPoint);
  var
   CycAL1, PI1, PI2 : Word;
  begin
   PI1 := 0;
   PI2 := 0;
   for CycAL1 := 1 to fNPoints do
    begin
     if (PointsEq(A[CycAL1], P1)) then
      PI1 := CycAL1;
     if (PointsEq(A[CycAL1], P2)) then
      PI2 := CycAL1;
    end;
   if (PI1 = 0) then
    begin
     AddPoint(P1);
     PI1 := fNPoints;
    end;
   if (PI2 = 0) then
    begin
     AddPoint(P2);
     PI2 := fNPoints;
    end;
   Inc(fNLines);
   LA[fNLines].P1 := PI1;
   LA[fNLines].P2 := PI2;
  end;

 procedure TLineSet.AddLine(PL : TPointLine);
  begin
   AddLine(PL[1], PL[2]);
  end;

 procedure TLineSet.AddPolygon(P : TPolygon);
  var
   CycAP1 : Word;
  begin
   for CycAP1 := 1 to P.NPoints do
    AddLine(P.GetPointLine(CycAP1));
  end;

 procedure TLineSet.Clear;
  begin
   inherited Clear;
   fNLines := 0;
  end;

 procedure TLineSet.Show(C : TCanvas; V : TRotationVector; Options : TShowOptions = []);
  var
   CycS1 : Word;
   P : T2DPoint;
  begin
   for CycS1 := 1 to fNLines do
    begin
     P := Project(GetRotatedPoint(A[LA[CycS1].P1], V));
     C.MoveTo(X0 + Round(P.X), YMax - Round(P.Y));
     P := Project(GetRotatedPoint(A[LA[CycS1].P2], V));
     C.LineTo(X0 + Round(P.X), YMax - Round(P.Y));
    end;
  end;

 procedure TLineSet.ShowScaled(C : TCanvas; Width, Height : Integer; V : TRotationVector);
  var
   MinP, MaxP, P : T2DPoint;
   CycSS1 : Word;
   dX, dY, S : Extended;
  begin
   if (fNLines > 0) then
    begin
     MinP := Project(GetRotatedPoint(A[1], V));
     MaxP := Project(GetRotatedPoint(A[1], V));
     for CycSS1 := 1 to fNLines do
      begin
       P := Project(GetRotatedPoint(A[CycSS1], V));
       if (P.X < MinP.X) then
        MinP.X := P.X;
       if (P.Y < MinP.Y) then
        MinP.Y := P.Y;
       if (P.X > MaxP.X) then
        MaxP.X := P.X;
       if (P.Y > MaxP.Y) then
        MaxP.Y := P.Y;
      end;
    end;
   dX := -MinP.X;
   dY := -MinP.Y;
   S := Min(Width / (MaxP.X - MinP.X), Height / (MaxP.Y - MinP.Y));
   for CycSS1 := 1 to fNLines do
    begin
     P := Project(GetRotatedPoint(A[LA[CycSS1].P1], V));
     P.X := P.X + dX;
     P.Y := P.Y + dY;
     P.X := P.X * S;
     P.Y := P.Y * S;
     C.MoveTo(X0 + Round(P.X), Height - Round(P.Y));
     P := Project(GetRotatedPoint(A[LA[CycSS1].P2], V));
     P.X := P.X + dX;
     P.Y := P.Y + dY;
     P.X := P.X * S;
     P.Y := P.Y * S;
     C.LineTo(X0 + Round(P.X), Height - Round(P.Y));
    end;
  end;

end.
