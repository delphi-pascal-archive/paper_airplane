// FormulaV.pas
// 25.13.02 : BcD

unit FormulaV;

interface
uses
 SysUtils, Variable;

var
 LastError : Word;
const
 NVariables = 255;
 eNoError    = $0000;
 eBrackets   = $0001;
 eExpression = $0002;
 ePointer    = $0004;
 ePower      = $0008;
 eRoot       = $0010;
 eTan        = $0020;
 eArcSin     = $0040;
 eArcCos     = $0080;
 eTH         = $0100;
 eArCH       = $0200;
 eArTH       = $0400;
 eSqrt       = $1000;
 eDiv        = $2000;
 eRange      = $4000;

type
 TValue = (fvUndefined, fvFunction, fvVariable, fvReal);
 TFunction = (ffUndefined,
              ffPower, ffRoot, ffMul, ffDiv, ffAdd, ffSub,
              ffArcSin, ffArcCos, ffArcTan, ffSin, ffCos, ffTan, ffArSH, ffArCH, ffArTH, ffSH, ffCH, ffTH, ffSqrt, ffSqr, ffExp, ffLn, ffAbs, ffSgn);
 TVariable = String;
const
 NBinFunction = (Integer(ffSub) - Integer(ffPower)) + 1;
 NUnFunction = (Integer(ffSgn) - Integer(ffArcSin)) + 1;
type
 TBinFunctionArray = array[1..NBinFunction] of String;
 TUnFunctionArray = array[1..NUnFunction] of String;
const
 BinFunctionArray : TBinFunctionArray = ('^', 'root', '*', '/', '+', '-');
 UnFunctionArray : TUnFunctionArray = ('arcsin', 'arccos', 'arctan', 'sin', 'cos', 'tan', 'arsh', 'arch', 'arth', 'sh', 'ch', 'th', 'sqrt', 'sqr', 'exp', 'ln', 'abs', 'sgn');
type
 TFormula = class
   constructor Fill(nLeft, nRight : TFormula; nHasLeft, nHasRight : Boolean; nValue : TValue; nFunc : TFunction; nRealValue : Extended; nVariable : TVariable);
   constructor Create(S : String);
   destructor Destroy; override;
  private
   Left, Right : TFormula;
   HasLeft, HasRight : Boolean;
   Value : TValue;
   Func : TFunction;
   RealValue : Extended;
   Variable : TVariable;
   function Power(X, Y : Extended) : Extended;
   function Root(X, Y : Extended) : Extended;
   function Tan(X : Extended) : Extended;
   function ArcSin(X : Extended) : Extended;
   function ArcCos(X : Extended) : Extended;
   function SH(X : Extended) : Extended;
   function CH(X : Extended) : Extended;
   function TH(X : Extended) : Extended;
   function ArSH(X : Extended) : Extended;
   function ArCH(X : Extended) : Extended;
   function ArTH(X : Extended) : Extended;
   function Signum(X : Extended) : Extended;
   procedure DeleteBrackets(var Formula : String);
   procedure LowString (var Formula : String);
   procedure DeleteSpaces(var S : String);
   function GetVariableText : String;
   function GetVariableValue(Va : TVariableList) : Extended;
   function VariablesEqual(V1, V2 : TVAriable) : Boolean;
  public
   function C : TFormula;
   function D(V : TVariable) : TFormula;
   function V(V : TVAriable) : TFormula;
   function E(RV : Extended) : TFormula;
   function FPower(FL, FR : TFormula) : TFormula;
   function FRoot(FL, FR : TFormula) : TFormula;
   function FMul(FL, FR : TFormula) : TFormula;
   function FDiv(FL, FR : TFormula) : TFormula;
   function FAdd(FL, FR : TFormula) : TFormula;
   function FSub(FL, FR : TFormula) : TFormula;
   function FArcSin(F : TFormula) : TFormula;
   function FArcCos(F : TFormula) : TFormula;
   function FArcTan(F : TFormula) : TFormula;
   function FSin(F : TFormula) : TFormula;
   function FCos(F : TFormula) : TFormula;
   function FTan(F : TFormula) : TFormula;
   function FArSH(F : TFormula) : TFormula;
   function FArCH(F : TFormula) : TFormula;
   function FArTH(F : TFormula) : TFormula;
   function FSH(F : TFormula) : TFormula;
   function FCH(F : TFormula) : TFormula;
   function FTH(F : TFormula) : TFormula;
   function FSqrt(F : TFormula) : TFormula;
   function FSqr(F : TFormula) : TFormula;
   function FExp(F : TFormula) : TFormula;
   function FLn(F : TFormula) : TFormula;
   function FAbs(F : TFormula) : TFormula;
   function FSgn(F : TFormula) : TFormula;
   function GetFunctionText : String;
   function Caluclate(Va : TVariableList) : Extended;
   function CopyTree : TFormula;
   function Diff(V : TVariable) : TFormula;
   function GetError(E : Integer) : String;
 end;

implementation

constructor TFormula.Fill(nLeft, nRight : TFormula; nHasLeft, nHasRight : Boolean; nValue : TValue; nFunc : TFunction; nRealValue : Extended; nVariable : TVariable);
 begin
  HasLeft := nHasLeft;
  HasRight := nHasRight;
  if (HasLeft) then
   Left := nLeft;
  if (HasRight) then
   Right := nRight;
  Value := nValue;
  Func := nFunc;
  RealValue := nRealValue;
  Variable := nVariable;
 end;

constructor TFormula.Create(S : String);
 var
  Cyc1, CurPos, NOpenBrackets, Code : Integer;
  Fin : Boolean;
 begin
  DeleteSpaces(S);
  DeleteBrackets(S);
  LowString(S);
  Cyc1 := 1;
  while ((Cyc1 < NUnFunction) and (Pos(UnFunctionArray[Cyc1], S) <> 1)) do
   Inc(Cyc1);
  if ((Pos(UnFunctionArray[Cyc1], S) = 1){ and (S[Length(S)] = ')')}) then
   begin
    Value := fvFunction;
    Func := TFunction(Cyc1 + NBinFunction);
    HasLeft := false;
    HasRight := true;
    Right := TFormula.Create(Copy(S, Length(UnFunctionArray[Cyc1]) + 1, Length(S) - Length(UnFunctionArray[Cyc1])));
   end
  else
   begin
    CurPos := 0;
    NOpenBrackets := 0;
    Fin := false;
    while ((CurPos < Length(S)) and (not(Fin))) do
     begin
      Inc(CurPos);
      case (S[CurPos]) of
       '(' :
        Inc(NOpenBrackets);
       ')' :
        Dec(NOpenBrackets);
      end;
      if (NOpenBrackets = 0) then
       begin
        Cyc1 := 1;
        while ((Cyc1 < NBinFunction) and (Copy(S, CurPos, Length(BinFunctionArray[Cyc1])) <> BinFunctionArray[Cyc1])

{        Pos(BinFunctionArray[Cyc1], S) <> CurPos)}) do
         Inc(Cyc1);
        if (Copy(S, CurPos, Length(BinFunctionArray[Cyc1])) = BinFunctionArray[Cyc1]) then
         Fin := true;
       end;
     end;
    if (Fin) then
     begin
      Value := fvFunction;
      Func := TFunction(Cyc1);
      HasLeft := true;
      HasRight := true;
      Left := TFormula.Create(Copy(S, 1, CurPos - 1));
      Right := TFormula.Create(Copy(S, CurPos + Length(BinFunctionArray[Cyc1]), Length(S) - (CurPos + Length(BinFunctionArray[Cyc1])) + 1));
     end
    else
     begin
      Val(S, RealValue, Code);
      if (Code <> 0) then
       begin
        Value := fvVariable;
        Variable := S;
       end
      else
       Value := fvReal;
     end;
   end;
 end;

destructor TFormula.Destroy;
 begin
  if (HasLeft) then
   Left.Destroy;
  if (HasRight) then
   Right.Destroy;
  inherited Destroy;
 end;

function TFormula.Power(X, Y : Extended) : Extended;
 begin
  if (X > 0) then
   Power := Exp(Y * Ln(X))
  else
   if (X < 0) then
    if (Y - Round(Y) = 0) then
     if (Odd(Round(Y))) then
      Power := -Exp(Y * Ln(-X))
     else
      Power := Exp(Y * Ln(-X))
    else
     begin
      Power := 0;
      LastError := LastError or ePower;
     end
   else
    begin
     Power := 0;
     LastError := LastError or ePower;
    end;
 end;

function TFormula.Root(X, Y : Extended) : Extended;
 begin
  if (X <> 0) then
   if (Y > 0) then
    Root := Exp(Ln(Y) / X)
   else
    if (Y < 0) then
     if (Y - Round(Y) = 0) then
      if (Odd(Round(Y))) then
       Root := -Exp(Ln(-Y) / X)
      else
       begin
        Root := 0;
        LastError := LastError or eRoot;
       end
     else
      begin
       Root := 0;
       LastError := LastError or eRoot;
      end
    else
     Root := 1
  else
   begin
    Root := 0;
    if (Y <= 0) then
     LastError := LastError or eRoot;
   end;
 end;

function TFormula.Tan(X : Extended) : Extended;
 begin
  if (Cos(X) <> 0) then
   Tan := Sin(X) / Cos(X)
  else
   begin
    Tan := 0;
    LastError := LastError or eTan;
   end;
 end;

function TFormula.ArcSin(X : Extended) : Extended;
 begin
  if (Abs(X) <= 1) then
   if (1 - Sqr(X) <> 0) then
    ArcSin := ArcTan(X / Sqrt(1 - Sqr(X)))
   else
    ArcSin := PI / 2
  else
   begin
    ArcSin := 0;
    LastError := LastError or eArcSin;
   end;
 end;

function TFormula.ArcCos(X : Extended) : Extended;
 begin
  if (Abs(X) <= 1) then
   if (X <> 0) then
    ArcCos := ArcTan(Sqrt(1 - Sqr(X)) / X)
   else
    ArcCos := PI / 2
  else
   begin
    ArcCos := 0;
    LastError := LastError or eArcCos;
   end;
 end;

function TFormula.SH(X : Extended) : Extended;
 begin
  SH := (Exp(X) - Exp(-X)) / 2;
 end;

function TFormula.CH(X : Extended) : Extended;
 begin
  CH := (Exp(X) + Exp(-X)) / 2;
 end;

function TFormula.TH(X : Extended) : Extended;
 begin
  if ((Exp(X) + Exp(-X)) <> 0) then
   TH := (Exp(X) - Exp(-X))/(Exp(X) + Exp(-X))
  else
   begin
    TH := 0;
    LastError := LastError or eTH;
   end;
 end;

function TFormula.ArSH(X : Extended) : Extended;
 begin
  ArSH := Ln(X + Sqrt(Sqr(X) + 1));
 end;

function TFormula.ArCH(X : Extended) : Extended;
 begin
  if (X >= 1) then
   ArCH := Ln(X + Sqrt(Sqr(X) - 1))
  else
   begin
    ArCH := 0;
    LastError := LastError or eArCH;
   end;
 end;

function TFormula.ArTH(X : Extended) : Extended;
 begin
  if ((X <= -1) and (X > 1)) then
   ArTH := 0.5 * Ln((1 + X) / (1 - X))
  else
   begin
    ArTH := 0;
    LastError := LastError or eArTH;
   end;
 end;

function TFormula.Signum(X : Extended) : Extended;
 begin
  if (X > 0) then
   Signum := 1
  else
   if (X < 0) then
    Signum := -1
   else
    Signum := 0;
 end;

procedure TFormula.DeleteBrackets(var Formula : String);
 var
  NBrackets, Min              : Integer;
  CycDB1, CycDB2, CycDB3, Ans : Byte;
 begin
  if (Length(Formula) > 0) then
   begin
    CycDB1 := 0;
    repeat
     Inc(CycDB1);
    until (Formula[CycDB1] <> '(');
    CycDB2 := Length(Formula) + 1;
    repeat
     Dec(CycDB2);
    until (Formula[CycDB2] <> ')');
    NBrackets := 0;
    Min := 0;
    for CycDB3 := CycDB1 to CycDB2 do
     begin
      if (Formula[CycDB3] = '(') then
       Inc(NBrackets)
      else
       if (Formula[CycDB3] = ')') then
        Dec(NBrackets);
      if (NBrackets < Min) then
       Min := NBrackets;
     end;
    Dec(CycDB1);
    CycDB2 := Length(Formula) - CycDB2;
    if (Min > 0) then
     Ans := CycDB2 - Min
    else
     Ans := CycDB1 + Min;
    Formula := Copy(Formula, Ans + 1, Length(Formula) - 2 * Ans);
   end;
 end;

procedure TFormula.LowString (var Formula : String);
 var
  CycLS1 : Byte;
 begin
  for CycLS1 := 1 to Length(Formula) do
   if (Formula[CycLS1] in ['A'..'Z']) then
    Formula[CycLS1] := Chr(Ord(Formula[CycLS1]) + $20);
 end;

procedure TFormula.DeleteSpaces(var S : String);
 var
  CycDS1 : Integer;
 begin
  if (Length(S)  > 0) then
   begin
    CycDS1 := 1;
    repeat
     if (S[CycDS1] = ' ') then
      Delete(S, CycDS1, 1)
     else
      if (CycDS1 < Length(S)) then
       Inc(CycDS1);
    until (CycDS1 >= Length(S));
   end;
 end;

function TFormula.GetVariableText : String;
 begin
  Result := Variable;
 end;

function TFormula.GetVariableValue(Va : TVariableList) : Extended;
 begin
  Result := Va.GetValueByName(Variable);
 end;

function TFormula.VariablesEqual(V1, V2 : TVariable) : Boolean;
 begin
  Result := (V1 = V2);
 end;

function TFormula.C : TFormula;
 begin
  Result := CopyTree;
 end;

function TFormula.D(V : TVariable) : TFormula;
 begin
  Result := Diff(V);
 end;

function TFormula.V(V : TVariable) : TFormula;
 begin
  Result := TFormula.Fill(NIL, NIL, false, false, fvVariable, ffUndefined, 0, V);
 end;

function TFormula.E(RV : Extended) : TFormula;
 begin
  Result := TFormula.Fill(NIL, NIL, false, false, fvReal, ffUndefined, RV, '');
 end;

function TFormula.FPower(FL, FR : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(FL, FR, true, true, fvFunction, ffPower, 0, '');
 end;

function TFormula.FRoot(FL, FR : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(FL, FR, true, true, fvFunction, ffRoot, 0, '');
 end;

function TFormula.FMul(FL, FR : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(FL, FR, true, true, fvFunction, ffMul, 0, '');
 end;

function TFormula.FDiv(FL, FR : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(FL, FR, true, true, fvFunction, ffDiv, 0, '');
 end;

function TFormula.FAdd(FL, FR : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(FL, FR, true, true, fvFunction, ffAdd, 0, '');
 end;

function TFormula.FSub(FL, FR : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(FL, FR, true, true, fvFunction, ffSub, 0, '');
 end;

function TFormula.FArcSin(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffArcSin, 0, '');
 end;

function TFormula.FArcCos(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffArcCos, 0, '');
 end;

function TFormula.FArcTan(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffArcTan, 0, '');
 end;

function TFormula.FSin(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffSin, 0, '');
 end;

function TFormula.FCos(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffCos, 0, '');
 end;

function TFormula.FTan(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffTan, 0, '');
 end;

function TFormula.FArSH(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffArSH, 0, '');
 end;

function TFormula.FArCH(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffArCH, 0, '');
 end;

function TFormula.FArTH(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffArTH, 0, '');
 end;

function TFormula.FSH(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffSH, 0, '');
 end;

function TFormula.FCH(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffCH, 0, '');
 end;

function TFormula.FTH(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffTH, 0, '');
 end;

function TFormula.FSqrt(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffSqrt, 0, '');
 end;

function TFormula.FSqr(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffSqr, 0, '');
 end;

function TFormula.FExp(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffExp, 0, '');
 end;

function TFormula.FLn(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffLn, 0, '');
 end;

function TFormula.FAbs(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffAbs, 0, '');
 end;

function TFormula.FSgn(F : TFormula) : TFormula;
 begin
  Result := TFormula.Fill(NIL, F, false, true, fvFunction, ffSgn, 0, '');
 end;

function TFormula.GetFunctionText : String;
 begin
  case (Value) of
   fvFunction :
    if (Integer(Func) <= NBinFunction) then
     Result := '(' + Left.GetFunctionText + ')' + BinFunctionArray[Integer(Func)] + '(' + Right.GetFunctionText + ')'
    else
     Result := UnFunctionArray[Integer(Func) - NBinFunction] + '(' + Right.GetFunctionText + ')';
   fvVariable :
    Result := GetVariableText;
   fvReal :
    Result := FloatToStr(RealValue);
  end;
 end;

function TFormula.Caluclate(Va : TVariableList) : Extended;
 begin
  case (Value) of
   fvFunction :
    case (Func) of
     ffPower :
      Result := Power(Left.Caluclate(Va), Right.Caluclate(Va));
     ffRoot :
      Result := Root(Left.Caluclate(Va), Right.Caluclate(Va));
     ffMul :
      Result := Left.Caluclate(Va) * Right.Caluclate(Va);
     ffDiv :
      Result := Left.Caluclate(Va) / Right.Caluclate(Va);
     ffAdd :
      Result := Left.Caluclate(Va) + Right.Caluclate(Va);
     ffSub :
      Result := Left.Caluclate(Va) - Right.Caluclate(Va);  
     ffArcSin :
      Result := ArcSin(Right.Caluclate(Va));
     ffArcCos :
      Result := ArcCos(Right.Caluclate(Va));
     ffArcTan :
      Result := ArcTan(Right.Caluclate(Va));
     ffSin :
      Result := Sin(Right.Caluclate(Va));
     ffCos :
      Result := Cos(Right.Caluclate(Va));
     ffTan :
      Result := Tan(Right.Caluclate(Va));
     ffArSH :
      Result := ArSH(Right.Caluclate(Va));
     ffArCH :
      Result := ArCH(Right.Caluclate(Va));
     ffArTH :
      Result := ArTH(Right.Caluclate(Va));
     ffSH :
      Result := SH(Right.Caluclate(Va));
     ffCH :
      Result := CH(Right.Caluclate(Va));
     ffTH :
      Result := TH(Right.Caluclate(Va));
     ffSqrt :
      Result := Sqrt(Right.Caluclate(Va));
     ffSqr :
      Result := Sqr(Right.Caluclate(Va));
     ffExp :
      Result := Exp(Right.Caluclate(Va));
     ffLn :
      Result := Ln(Right.Caluclate(Va));
     ffAbs :
      Result := Abs(Right.Caluclate(Va));
     ffSgn :
      Result := Signum(Right.Caluclate(Va));
     else
      Result := 0;
    end;
   fvVariable :
    Result := GetVariableValue(Va);
   fvReal :
    Result := RealValue;
   else
    Result := 0;
  end;
 end;

function TFormula.CopyTree : TFormula;
 begin
  Result := TFormula.Fill(Left, Right, HasLeft, HasRight, Value, Func, RealValue, Variable);
  if (HasLeft) then
   Result.Left := Left.CopyTree;
  if (HasRight) then
   Result.Right := Right.CopyTree;
 end;

function TFormula.Diff(V : TVariable) : TFormula;
 begin
  case (Value) of
   fvFunction :
    case (Func) of
     ffPower :
      Result := FMul(C, FAdd(FDiv(FMul(Right.C, Left.D(V)), Left.C), FMul(Right.D(V), FLn(Left.C))));
     ffRoot :
      Result := FDiv(FMul(C, FSub(FMul(Right.D(V), FDiv(Left.C, Right.C)), FMul(Left.D(V), FLn(Right.C)))), FSqr(Left.C));
     ffMul :
      Result := FAdd(FMul(Left.C, Right.D(V)), FMul(Right.C, Left.D(V)));
     ffDiv :
      Result := FDiv(FSub(FMul(Right.C, Left.D(V)), FMul(Left.C, Right.D(V))), FSqr(Right.C));
     ffAdd :
      Result := FAdd(Left.D(V), Right.D(V));
     ffSub :
      Result := FSub(Left.D(V), Right.D(V));
     ffArcSin :
      Result := FDiv(Right.D(V), FSqrt(FSub(E(1), FSqr(Right.C))));
     ffArcCos :
      Result := FDiv(FSub(E(0), Right.D(V)), FSqrt(FSub(E(1), FSqr(Right.C))));
     ffArcTan :
      Result := FDiv(Right.D(V), FAdd(E(1), FSqr(Right.C)));
     ffSin :
      Result := FMul(FCos(Right.C), Right.D(V));
     ffCos :
      Result := FMul(FSub(E(0), FSin(Right.C)), Right.D(V));
     ffTan :
      Result := FDiv(Right.D(V), FSqr(FCos(Right.C)));
     ffSh :
      Result := FMul(Right.D(V), FCH(Right.C));
     ffCh :
      Result := FMul(Right.D(V), FSH(Right.C));
     ffTh :
      Result := FDiv(Right.D(V), FSqr(FCH(Right.C)));
     ffArSh :
      Result := FDiv(Right.D(V), FSqrt(FAdd(E(1), FSqr(Right.C))));
     ffArCh :
      Result := FDiv(Right.D(V), FSqrt(FSub(FSqr(Right.C), E(1))));
     ffArTh :
      Result := FDiv(Right.D(V), FSub(E(1), FSqr(Right.C)));
     ffSqrt :
      Result := FDiv(Right.D(V), FMul(E(2), FSqrt(Right.C)));
     ffSqr :
      Result := FMul(FMul(E(2), Right.C), Right.D(V));
     ffExp :
      Result := FMul(FExp(Right.C), Right.D(V));
     ffLn :
      Result := FDiv(Right.D(V), Right.C);
     ffAbs :
      Result := FMul(FSgn(Right.C), Right.D(V));
     else
      Result := E(0);
    end;
   fvVariable :
    if (VariablesEqual(V, Variable)) then
     Result := E(1)
    else
     Result := E(0);
   fvReal :
    Result := E(0);
   else
    Result := E(0);
  end;
 end;

function TFormula.GetError(E : Integer) : String;
 begin
  Result := '';
  if (E and eBrackets = E) then
   Result := Result + 'eBrackets';
  if (E and eExpression = E) then
   Result := Result + 'eExpression';
  if (E and ePointer = E) then
   Result := Result + 'ePointer';
  if (E and ePower = E) then
   Result := Result + 'ePower';
  if (E and eRoot = E) then
   Result := Result + 'eRoot';
  if (E and eTan = E) then
   Result := Result + 'eTan';
  if (E and eArcSin = E) then
   Result := Result + 'eArcSin';
  if (E and eArcCos = E) then
   Result := Result + 'eArcCos';
  if (E and eTH = E) then
   Result := Result + 'eTH';
  if (E and eArCH = E) then
   Result := Result + 'eArCH';
  if (E and eArTH = E) then
   Result := Result + 'eArTH';
  if (E and eSqrt = E) then
   Result := Result + 'eSqrt';
  if (E and eDiv = E) then
   Result := Result + 'eDiv';
  if (E and eRange = E) then
   Result := Result + 'eRange';
 end;

end.
