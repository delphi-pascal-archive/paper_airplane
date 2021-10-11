// Geometry.pas
// 16.03.03 : BcD

unit Geometry;

interface
 uses
  GTypes;

 function  Eq(A : TFloat; B : TFloat = 0) : Boolean;
 function  PointsEq(P1, P2 : T3DPoint) : Boolean;
 function  Min(A, B : Integer) : Integer; overload;
 function  Min(A, B : TFloat) : TFloat; overload;
 function  Add(A, B : TVector) : TVector;
 function  Sub(A, B : TVector) : TVector;
 function  AbsV(A : TVector) : TFloat;
 function  SqrV(A : TVector) : TFloat;
 function  Mul(A : TVector; B : TFloat) : TVector;
 function  DivV(A : TVector; B : TFloat) : TVector;
 function  MulScal(A, B : TVector) : TFloat;
 function  MulVec(A, B : TVector) : TVector;
 function  GetRotatedPoint(R1 : TVector; L : T3DPointLine; Alpha : TFloat) : TVector; overload;
 function  Project(V : T3DPoint) : T2DPoint;
 function  Get2DPointBy3DPoint(P : T3DPoint) : T2DPoint;
 function  Get3DPointBy2DPoint(P : T2DPoint) : T3DPoint;
 function  GetVectorByPointLine(PL : TPointLine) : TVector;
 function  GetMirroredPoint(L : TLine; P : T3DPoint) : T3DPoint;
 function  GetPointToPointDist(P1, P2 : T3DPoint) : TFloat;
 function  GetPointLineLength(PL : T3DPointLine) : TFloat;
 function  GetLineByPointLine(PL : TPointLine) : TLine;
 function  GetLinePointLineIntersection(L : TLine; PL : T3DPointLine) : T3DPoint;
 function  LineCrossPointLine(L : TLine; PL : T3DPointLine) : Boolean;
 function  GetPointToLineDist(P : T3DPoint; L : TLine) : TFloat;
 function  GetPointToPointLineDist(P : T3DPoint; PL : TPointLine) : TFloat;
 function  GetFlatTriangleSpace(P1, P2, P3 : T3DPoint) : TFloat; overload;
 function  GetTriangleSpace(P1, P2, P3 : T3DPoint) : TFloat; overload;
 function  GetTriangleCenterPoint(P1, P2, P3 : T3DPoint) : T3DPoint;
 function  GetRotatedPoint(P : T3DPoint; A, B : TFloat) : T3DPoint; overload;
 function  GetRotatedPoint(P : T3DPoint; V : TRotationVector) : T3DPoint; overload;
 function  PointBeforeSurface(P, P1, P2, P3 : T3DPoint) : TFloat;

implementation

 function Eq(A : TFloat; B : TFloat = 0) : Boolean;
  begin
   Result := (Abs(A - B) <= FZero);
  end;

 function Eq0(A : TFloat) : Boolean;
  begin
   Result := (Abs(A) <= FZero);
  end;

 function PointsEq(P1, P2 : T3DPoint) : Boolean;
  begin
   Result := ((Eq(P1.X, P2.X)) and (Eq(P1.Y, P2.Y)) and (Eq(P1.Z, P2.Z)));
  end;

 function Min(A, B : Integer) : Integer;
  begin
   if (A < B) then
    Result := A
   else
    Result := B;
  end;

 function Min(A, B : TFloat) : TFloat;
  begin
   if (A < B) then
    Result := A
   else
    Result := B;
  end;

 function Add(A, B : TVector) : TVector;
  begin
   Result.X := A.X + B.X;
   Result.Y := A.Y + B.Y;
   Result.Z := A.Z + B.Z;
  end;

 function Sub(A, B : TVector) : TVector;
  begin
   Result.X := A.X - B.X;
   Result.Y := A.Y - B.Y;
   Result.Z := A.Z - B.Z;
  end;

 function AbsV(A : TVector) : TFloat;
  begin
   Result := Sqrt(Sqr(A.X) + Sqr(A.Y) + Sqr(A.Z));
  end;

 function SqrV(A : TVector) : TFloat;
  begin
   Result := Sqr(AbsV(A));
  end;

 function Mul(A : TVector; B : TFloat) : TVector;
  begin
   Result.X := A.X * B;
   Result.Y := A.Y * B;
   Result.Z := A.Z * B;
  end;

 function DivV(A : TVector; B : TFloat) : TVector;
  begin
   Result.X := A.X / B;
   Result.Y := A.Y / B;
   Result.Z := A.Z / B;
  end;

 function MulScal(A, B : TVector) : TFloat;
  begin
   Result := A.X * B.X + A.Y * B.Y + A.Z * B.Z;
  end;

 function MulVec(A, B : TVector) : TVector;
  begin
   Result.X := A.Y * B.Z - A.Z * B.Y;
   Result.Y := A.Z * B.X - A.X * B.Z;
   Result.Z := A.X * B.Y - A.Y * B.X;
  end;

 function GetRotatedPoint(R1 : TVector; L : T3DPointLine; Alpha : TFloat) : TVector;
  var     {RotationPoint}
   R0, A, PR, D1, D2, C, Prg, VX, VY : TVector;
  begin
   R0 := L[1];
   A := Sub(L[1], L[2]);
   Prg := DivV(Mul(A, MulScal(A, Sub(R1, R0))), SqrV(A));
   PR := Add(Prg, R0);                              {Prg || a }
   D1 := Sub(R1, PR);                               {D1, D2 _|_ a}
   if (AbsV(D1) <= fZero) then
    Result := R1
   else
    begin
     C := Mul(DivV(A, AbsV(A)), SqrV(D1) * Sin(Alpha)); {D1 X D2 = C}
     VX := Mul(D1, Cos(Alpha));
     VY := DivV(MulVec(D1, C), SqrV(D1));
     D2 := Add(VX, VY);
     Result := Add(PR, D2);
    end;
  end;

 function Project(V : T3DPoint) : T2DPoint;
  begin
   Result := Get2DPointBy3DPoint(V);
  end;

 function Get2DPointBy3DPoint(P : T3DPoint) : T2DPoint;
  begin
   Result.X := P.X;
   Result.Y := P.Y;
  end;

 function Get3DPointBy2DPoint(P : T2DPoint) : T3DPoint;
  begin
   Result.X := P.X;
   Result.Y := P.Y;
   Result.Z := 0;
  end;

 function GetVectorByPointLine(PL : TPointLine) : TVector;
  begin
   Result := Sub(PL[2], PL[1]);
  end;

 function GetMirroredPoint(L : TLine; P : T3DPoint) : T3DPoint;
  begin
   Result.X := (P.X * (Sqr(L.B) - Sqr(L.A)) - 2 * L.A * (P.Y * L.B + L.C)) / (Sqr(L.A) + Sqr(L.B));
   Result.Y := (P.Y * (Sqr(L.A) - Sqr(L.B)) - 2 * L.B * (P.X * L.A + L.C)) / (Sqr(L.B) + Sqr(L.A));
   Result.Z := P.Z;
  end;

 function GetPointToPointDist(P1, P2 : T3DPoint) : TFloat;
  begin
   Result := Sqrt(Sqr(P1.X - P2.X) + Sqr(P1.Y - P2.Y) + Sqr(P1.Z - P2.Z));
  end;

 function GetPointLineLength(PL : T3DPointLine) : TFloat;
  begin
   Result := GetPointToPointDist(PL[1], PL[2]);
  end;

 function GetPointToLineDist(P : T3DPoint; L : TLine) : TFloat;
  begin
   if (not(Eq(Sqr(L.A) + Sqr(L.B)))) then
    Result := ((P.X * L.A) + (P.Y * L.B) + L.C) / Sqrt(Sqr(L.A) + Sqr(L.B))
   else
    begin
//     Assert(false);
     Result := Sqrt(Sqr(P.X) + Sqr(P.Y));
    end; 
  end;

 function GetPointToPointLineDist(P : T3DPoint; PL : TPointLine) : TFloat;
  var
   D0, DC, D1, D2 : TFloat;
  begin
   D0 := Abs(GetPointToLineDist(P, GetLineByPointLine(PL)));
   DC := Sqrt(Sqr(D0) + Sqr(GetPointLineLength(PL)));
   D1 := GetPointToPointDist(P, PL[1]);
   D2 := GetPointToPointDist(P, PL[2]);
   if ((D1 <= DC) and (D2 <= DC)) then
    Result := D0
   else
    if (D1 < D2) then
     Result := D1
    else
     Result := D2;
  end;

 function LineCrossPointLine(L : TLine; PL : T3DPointLine) : Boolean;
  var
   A, B : TFloat;
  begin
   A := GetPointToLineDist(PL[1], L);
   B := GetPointToLineDist(PL[2], L);
   Result := ((Eq(A)) or (Eq(B)) or ((A > 0) xor (B > 0)));
  end;

 function GetLinePointLineIntersection(L : TLine; PL : T3DPointLine) : T3DPoint;
  var
   l1, l2 : TFloat;
  begin
   l1 := Abs(GetPointToLineDist(PL[1], L));
   l2 := Abs(GetPointToLineDist(PL[2], L));
   if ((Eq(l1)) and (Eq(l2))) then
    Result := PL[1]
   else
    begin
     Result.X := (l2 * PL[1].X + (l1 * PL[2].X)) / (l1 + l2);
     Result.Y := (l2 * PL[1].Y + (l1 * PL[2].Y)) / (l1 + l2);
     Result.Z := 0;
    end;
  end;

 function GetLineByPointLine(PL : TPointLine) : TLine;
  begin
   Result.A := PL[2].Y - PL[1].Y;
   Result.B := PL[1].X - PL[2].X;
   Result.C := PL[1].Y * (PL[2].X - PL[1].X) + PL[1].X * (PL[1].Y - PL[2].Y);
  end;

 function GetFlatTriangleSpace(P1, P2, P3 : T3DPoint) : TFloat;
  begin
   Result := Abs(P1.X * (P2.Y - P3.Y) + P2.X * (P3.Y - P1.Y) + P3.X * (P1.Y - P2.Y)) / 2;
  end;

 function GetTriangleSpace(P1, P2, P3 : T3DPoint) : TFloat;
  var
   V1, V2 : TVector;
  begin
   V1 := Sub(P1, P3);
   V2 := Sub(P2, P3);
   Result := AbsV(MulVec(V1, V2)) / 2;;
  end;

 function GetTriangleCenterPoint(P1, P2, P3 : T3DPoint) : T3DPoint;
  begin
   Result.X := (P1.X + P2.X + P3.X) / 3;
   Result.Y := (P1.Y + P2.Y + P3.Y) / 3;
   Result.Z := (P1.Z + P2.Z + P3.Z) / 3;
  end;

 function GetRotatedPoint(P : T3DPoint; A, B : TFloat) : T3DPoint;
  var                      //not used
   Src : T3DPoint;
  begin
   Src := P;
   Result.X := Src.X;
   Result.Y := (Src.Y * Cos(A)) - (Src.Z * Sin(A));
   Result.Z := (Src.Y * Sin(A)) + (Src.Z * Cos(A));
   Src := Result;
   Result.X := (Src.Z * Sin(B)) + (Src.X * Cos(B));
   Result.Y := Src.Y;
   Result.Z := (Src.Z * Cos(B)) - (Src.X * Sin(B));
  end;

 function GetRotatedPoint(P : T3DPoint; V : TRotationVector) : T3DPoint;
  var
   Src : T3DPoint;
  begin
   Src.X := P.X - V.C.X;
   Src.Y := P.Y - V.C.Y;
   Src.Z := P.Z - V.C.Z;
   Result.X := Src.X;
   Result.Y := (Src.Y * Cos(V.Alpha)) - (Src.Z * Sin(V.Alpha));
   Result.Z := (Src.Y * Sin(V.Alpha)) + (Src.Z * Cos(V.Alpha));
   Src := Result;
   Result.X := (Src.Z * Sin(V.Beta)) + (Src.X * Cos(V.Beta));
   Result.Y := Src.Y;
   Result.Z := (Src.Z * Cos(V.Beta)) - (Src.X * Sin(V.Beta));
   Result.X := Result.X + V.C.X;
   Result.Y := Result.Y + V.C.Y;
   Result.Z := Result.Z + V.C.Z;
  end;

 function PointBeforeSurface(P, P1, P2, P3 : T3DPoint) : TFloat;
  begin
   Result := (((P.X - P1.X) * (P2.Y - P1.Y) * (P3.Z - P1.Z) +
               (P.Y - P1.Y) * (P2.Z - P1.Z) * (P3.X - P1.X) +
               (P.Z - P1.Z) * (P2.X - P1.X) * (P3.Y - P1.Y)) -
              ((P.Z - P1.Z) * (P2.Y - P1.Y) * (P3.X - P1.X) +
               (P.Y - P1.Y) * (P2.X - P1.X) * (P3.Z - P1.Z) +
               (P.X - P1.X) * (P2.Z - P1.Z) * (P3.Y - P1.Y)));
  end;

end.
