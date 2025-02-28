unit Defs;

interface

uses Windows, Classes;

const
  MaxPuntos = 100;

var
  NumPuntos: Word;
  Puntos: array[1..MaxPuntos] of TPoint;

  function EsInterior(M, A, B, C: TPoint): Boolean;
  function SobreQuePunto(X, Y: Integer): Word;
  procedure AgregarPunto(X, Y: Integer);


implementation

uses Cuentas;

procedure AgregarPunto(X, Y: Integer);
begin
  if NumPuntos < MaxPuntos then
    begin
      Inc(NumPuntos);
      Puntos[NumPuntos] := Point(X, Y);
    end;
end;

function SobreQuePunto(X, Y: Integer): Word;
var
  I: Word;
begin
  SobreQuePunto := 0;
  for I := 1 to NumPuntos do
    if (Abs(X-Puntos[I].X) <= 10) and
       (Abs(Y-Puntos[I].Y) <= 10) then
      begin
        SobreQuePunto := I;
        Break;
      end;
end;

function EsInterior(M, A, B, C: TPoint): Boolean;
var
  X, Y: Real;
begin
  EsInterior := False;
  ResolverSistema(B.X-A.X, C.X-B.X, M.X-A.X,
                  B.Y-A.Y, C.Y-B.Y, M.Y-A.Y, X, Y);
  if (X > 0) and (X < 1) then
    begin
      Y := Y / X;
      EsInterior := (Y > 0) and (Y < 1);
    end;
end;


end.
