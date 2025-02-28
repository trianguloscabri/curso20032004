unit Cuentas;

interface
  function ResolverSistema(A, B, C, D, E, F: Real; var X, Y: Real) : Boolean;
  
implementation

function ResolverSistema(A, B, C, D, E, F: Real; var X, Y: Real) : Boolean;
{ Si A*E-B*F = 0, ResolverSistema devuelve False.
  En otro caso, ResolverSistema devuelve True y en X, Y las soluciones del
  sistema Ax + By = C, Dx + Ey = F. }
var
  Determinante : Real;
begin
  ResolverSistema := False;
  Determinante := A * E - B * D;
  if Determinante <> 0 then
    begin
      X := (C * E - B * F) / Determinante;
      Y := (A * F - C * D) / Determinante;
      ResolverSistema := True;
    end;
end;


end.
