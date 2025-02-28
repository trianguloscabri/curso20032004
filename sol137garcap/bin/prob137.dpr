program prob137;

uses
  Forms,
  main in 'main.pas' {Form1},
  Defs in 'Defs.pas',
  Dibujos in 'Dibujos.pas',
  Cuentas in 'Cuentas.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
