program Project2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  FormulaV in 'FormulaV.pas',
  Geometry in 'Geometry.pas',
  GTypes in 'GTypes.pas',
  PP in 'PP.pas',
  Variable in 'Variable.pas',
  Animation in 'Animation.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Paper Airplane';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
