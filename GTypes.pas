// GTypes.pas
// 07.03.03 : BcD

unit GTypes;

interface
 uses
  Graphics;
 type
  TFloat = Extended;

 const
  AverageNPolygonVertex = 4 + 5;

  NRegionMax = 100;
  NPointsMax = NRegionMax * AverageNPolygonVertex;

  MaxActions = 100;
  MaxLines = 500;
  X0 = 25;
  YMax = 325;
  ScreenXMax = 1024;
  ScreenYMax = 768;
  FZero : TFloat = 1e-3;
  NA_ALL_ACTIONS = -1;
  clLightRed = TColor($eeeeff);
  clLightGreen = TColor($eeffee);
  clLightBlue = TColor($ffeeee);
  CS_ALL_ACTIONS = -1;
 type
  TLine = record
   A, B, C : TFloat;
  end;
  T3DPoint = record
   X, Y, Z : TFloat;
  end;
  T2DPoint = record
   X, Y : TFloat;
  end;
  TVector = T3DPoint;
 const
  Empty3DPoint : T3DPoint = (X : 0; Y : 0; Z : 0);
 type
  T2DPointLine = array[1..2] of T2DPoint;
  T3DPointLine = array[1..2] of T3DPoint;
  TPointLine = T3DPointLine;
  T2DPointArray = array[1..NPointsMax] of T2DPoint;
  T3DPointArray = array[1..NPointsMax] of T3DPoint;
  TShowOption = (soShowBasePoints, soShowBasePointsIndex, soShowPolygonIndex, soShowMassCenter, soShowTargets, soShowFoldingPoints, soShowSurface);
  TShowOptions = set of TShowOption;
  TRotationVector = record
   Alpha, Beta : TFloat;
   C : T3DPoint;
  end;
  TIntegerArray = array[1..NPointsMax] of Integer;
  TBooleanArray = array[1..NPointsMax] of Boolean;
  TFloatArray = array[1..NRegionMax] of TFloat;
  TAction = record
   P1, P2, NTargets : Word;
   Targets : TIntegerArray;
   Angle : TFloat;
  end;
  TSign = (sgLess, sgGreater);
  TLengthArray = array[1..NRegionMax, 1..NPointsMax div AverageNPolygonVertex] of TFLoat;

implementation

end.
