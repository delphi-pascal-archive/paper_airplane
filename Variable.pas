// Variable.pas
// 14.12.02 : BcD

unit Variable;

interface

type
 TVariableList = class
   constructor Create(nName : String; nValue : Extended);
   destructor Destroy; override;
  private
   Name : String;
   Value : Extended;
   HasNext : Boolean;
   Next : TVariableList;
  private
   procedure AddVariable(nName : String; nValue : Extended);
   procedure ModifyVariable(nName : String; nValue : Extended);
  public
   procedure SetValue(nValue : Extended);
   function  GetValue : Extended;
   function  GetVariableByName(nName : String) : TVariableList;
   function  VariableExists(nName : String) : Boolean;
   function  GetValueByName(nName : String) : Extended;
   procedure SetVariableValue(nName : String; nValue : Extended);
 end;

implementation
 constructor TVariableList.Create(nName : String; nValue : Extended);
  begin
   inherited Create;
   Name := nName;
   Value := nValue;
   HasNext := false;
   Next := NIL;
  end;

 destructor TVariableList.Destroy;
  begin
   if (HasNext) then
    Next.Destroy;
   inherited Destroy;
  end;

 procedure TVariableList.SetValue(nValue : Extended);
  begin
   Value := nValue;
  end;

 function TVariableList.GetValue : Extended;
  begin
   Result := Value;
  end;

 function TVariableList.GetVariableByName(nName : String) : TVariableList;
  begin
   if (Name = nName) then
    Result := Self
   else
    if (HasNext) then
     Result := Next.GetVariableByName(nName)
    else
     Result := NIL;
  end;

 function TVariableList.VariableExists(nName : String) : Boolean;
  begin
   Result := (GetVariableByName(nName) <> NIL);
  end;

 function TVariableList.GetValueByName(nName : String) : Extended;
  begin
   if (VariableExists(nName)) then
    Result := GetVariableByName(nName).Value
   else
    Result := 0;
  end;

 procedure TVariableList.AddVariable(nName : String; nValue : Extended);
  var
   Cur : TVariableList;
  begin
   Cur := Self;
   while (Cur.HasNext) do
    Cur := Cur.Next;
   Cur.HasNext := true;
   Cur.Next := TVariableList.Create(nName, nValue);
  end;

 procedure TVariableList.ModifyVariable(nName : String; nValue : Extended);
  begin
   GetVariableByName(nName).SetValue(nValue);
  end;

 procedure TVariableList.SetVariableValue(nName : String; nValue : Extended);
  begin
   if (VariableExists(nName)) then
    ModifyVariable(nName, nValue)
   else
    AddVariable(nName, nValue);
  end;
end.



