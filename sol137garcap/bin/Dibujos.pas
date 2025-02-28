unit Dibujos;

interface

uses Windows, Graphics, ExtCtrls;

var
  Kanvas: TCanvas;
  Ymagen: TImage;


  function Distancia(A, B: TPoint): Real;
  function PuntoEnSegmento(A, B: TPoint; T: Real): TPoint;
  function PuntoMedio(A, B: TPoint): TPoint;
  function Baricentro(A, B, C: TPoint): TPoint;
  function Circuncentro(A, B, C: TPoint): TPoint;
  function Interseccion(A, B, C, D: TPoint; var E: TPoint): Boolean;
  function Traslacion(A, B, C: TPoint): TPoint;
  function Proyeccion(A, B, C: TPoint): TPoint;
  procedure CoeficientesMediatriz(P, Q: TPoint; var A, B, C: Real);
  function PuntoEnCirculo(Centro: TPoint; Radio: Integer; Angulo: Real): TPoint;

  procedure Punto(A: TPoint);
  procedure Segmento(A, B: TPoint);
  procedure Triangulo(A, B, C: TPoint);
  procedure Circulo(P: TPoint; Radio: Integer);
  procedure TrazarAltura(A, B, C: TPoint);
  procedure NombrarVertice(Letra: String; A, B, C: TPoint);
  procedure MarcaAngulo(A, B, C: TPoint; Radio: Integer);
  procedure InterseccionRectaYVentana( A, B, C: Real;
                                     V : TRect;
                                     var NumPuntos: Byte;
                                     var P, Q: TPoint);
  procedure RectaCoefs(A, B, C: Real);
  procedure Recta(A, B: TPoint);
  procedure CambiarColor(NuevoColor: TColor);

implementation

uses Classes, Cuentas;

function Distancia(A, B: TPoint): Real;
begin
  Distancia := Sqrt(Sqr(B.X-A.X) + Sqr(B.Y-A.Y));
end;

function PuntoEnSegmento(A, B: TPoint; T: Real): TPoint;
{ Devuelve un punto del segmento AB si 0 <= T <= 1. Para otros
  valores el punto devuelto estará en la recta AB }
begin
  PuntoEnSegmento := Point(
    Round((1-T)*A.X + T*B.X),
    Round((1-T)*A.Y + T*B.Y));
end;

function PuntoMedio(A, B: TPoint): TPoint;
{ Devuelve el punto medio del segmento AB }
begin
  PuntoMedio := PuntoEnSegmento(A, B, 0.5);
end;

function Baricentro(A, B, C: TPoint): TPoint;
{ Devuelve el baricentro del triángulo ABC }
begin
  Baricentro := Point(
    Round((A.X+B.X+C.X)/3),
    Round((A.Y+B.Y+C.Y)/3))
end;


 function Interseccion(A, B, C, D: TPoint; var E: TPoint): Boolean;
{ Calcula la intersección de la recta AB y la recta CD }
var
  X, Y, Z1, Z2: Real;
begin
  Z1 := B.X * A.Y - B.Y * A.X;
  Z2 := D.X * C.Y - D.Y * C.X;
  Interseccion := False;
  if ResolverSistema(A.Y-B.Y, B.X-A.X, Z1,
                     C.Y-D.Y, D.X-C.X, Z2, X, Y) then
    begin
     E := Point(Round(X), Round(Y));
     Interseccion := True;
    end;
end;

function Traslacion(A, B, C: TPoint): TPoint;
{ Devuelve el resultado de aplicar al punto A el vector BC }
begin
  Traslacion.X := A.X + C.X - B.X;
  Traslacion.Y := A.Y + C.Y - B.Y;
end;

function Proyeccion(A, B, C: TPoint): TPoint;
{ Devuelve la proyeccion del punto A sobre la recta BC }
var
  a1, b1, c1,
  a2, b2, c2,
  x, y: Real;
begin
  a1 := C.Y - B.Y;
  b1 := B.X - C.X;
  c1 := a1 * B.X + B1*B.Y;
  a2 := C.X - B.X;
  b2 := C.Y - B.Y;
  c2 := a2 * A.X + B2*A.Y;
  ResolverSistema(a1, b1, c1, a2, b2, c2, x, y);
  Proyeccion := Point(Round(X), Round(Y));
end;

procedure CoeficientesMediatriz(P, Q: TPoint; var A, B, C: Real);
begin
  A := 2*Q.X - 2*P.X;
  B := 2*Q.Y - 2*P.Y;
  C := P.X*P.X - Q.X*Q.X + P.Y*P.Y - Q.Y*Q.Y;
end;

function Circuncentro(A, B, C: TPoint): TPoint;
var
  X, Y: Real;
  A1, B1, C1, A2, B2, C2: Real;
begin
  CoeficientesMediatriz(A, B, A1, B1, C1);
  CoeficientesMediatriz(B, C, A2, B2, C2);
  ResolverSistema(A1, B1, -C1, A2, B2, -C2, X, Y);
  Circuncentro := Point(Round(X), Round(Y));
end;


{ --------------------------------------------------- }

procedure Punto(A: TPoint);
begin
  Circulo(A, 3);
end;

procedure Segmento(A, B: TPoint);
begin
  Kanvas.MoveTo(A.X, A.Y);
  Kanvas.LineTo(B.X, B.Y);
end;

procedure Triangulo(A, B, C: TPoint);
begin
  Kanvas.PolyLine([A, B, C, A]);
end;

procedure Circulo(P: TPoint; Radio: Integer);
begin
  Kanvas.Ellipse(P.X-Radio, P.Y-Radio, P.X+Radio, P.Y+Radio);
end;

procedure CambiarColor(NuevoColor: TColor);
begin
  Kanvas.Pen.Color := NuevoColor;
end;

procedure TrazarAltura(A, B, C: TPoint);
{ Traza la altura por A del triángulo ABC }
var
  P: TPoint;
begin
  P := Proyeccion(A, B, C);
  Kanvas.Pen.Style := psDot;
  Segmento(P, B);
  Segmento(P, C);
  Kanvas.Pen.Style := psSolid;
  Segmento(A, P);
end;

procedure NombrarVertice(Letra: String; A, B, C: TPoint);
var
  M: TPoint;
  T: Real;
begin
  M := PuntoMedio(B, C);
  T := Distancia(A, M);
  Kanvas.TextOut(Round(A.X + (A.X-M.X)/T*15),
                 Round(A.Y + (A.Y-M.Y)/T*15), Letra);
end;

procedure MarcaAngulo(A, B, C: TPoint; Radio: Integer);
begin
  Kanvas.Arc(A.X-Radio, A.Y-Radio, A.X+Radio, A.Y+Radio,
    B.X, B.Y, C.X, C.Y);
end;

function PuntoEnCirculo(Centro: TPoint; Radio: Integer; Angulo: Real): TPoint;
begin
  Angulo := Pi/180*Angulo;
  PuntoEnCirculo.X := Round(Centro.X + Radio*Cos(Angulo));
  PuntoEnCirculo.Y := Round(Centro.Y - Radio*Sin(Angulo));
end;

procedure InterseccionRectaYVentana( A, B, C: Real;
                                     V : TRect;
                                     var NumPuntos: Byte;
                                     var P, Q: TPoint);
{ Ax + By + C = 0 es una recta.
  (VX1, VY1) y (VX2, VY2) son las cordenadas de los v‚rtices inferior
  izquierdo y superior derecho respectivamente de un rect ngulo.
  En NumPuntos se devuelve el n£mero de intersecciones (0, 1 ¢ 2) de la
  recta con el rect ngulo. En (X1, Y1) y (X2, Y2) se devuelven las
  coordenadas de los puntos de intersecci¢n }
var
  ArrayPuntos : array[1..2] of TPoint;
  X, Y : Real;
  procedure Agregar(X1, Y1: Real);
  begin
    if NumPuntos <> 2 then
      begin
        Inc(NumPuntos);
        ArrayPuntos[NumPuntos].X := Round(X1);
        ArrayPuntos[NumPuntos].Y := Round(Y1);
      end;
  end;
begin
  NumPuntos := 0;
  if A <> 0 then
    begin
      X := - (C + B * V.Top) / A;
      if (X >= V.Left) and (X <= V.Right) then
        Agregar(X, V.Top);
      X := - (C + B * V.Bottom) / A;
      if (X >= V.Left) and (X <= V.Right) then
        Agregar(X, V.Bottom);
    end;
  if B <> 0 then
    begin
      Y := - (C + A * V.Left) / B;
      if (Y >= V.Top) and (Y <= V.Bottom) then
        Agregar(V.Left, Y);
      Y := - (C + A * V.Right) / B;
      if (Y >= V.Top) and (Y <= V.Bottom) then
        Agregar(V.Right, Y);
    end;
  if (A = 0) and (B <> 0) then
    begin
      Y := - C / B;
      if (Y > V.Top) and (Y < V.Bottom) then
        begin
          Agregar(V.Left, Y);
          Agregar(V.Right, Y);
        end;
     end;
   if (B=0) and (A<>0) then
     begin
       X := - C / A;
       if (X > V.Left) and (X < V.Right) then
         begin
           Agregar(X, V.Top);
           Agregar(X, V.Bottom);
         end;
     end;
  P := ArrayPuntos[1];
  Q := ArrayPuntos[2];
end;

procedure RectaCoefs(A, B, C: Real);
var
  NumPuntos: Byte;
  Punto1, Punto2: TPoint;
  V: TRect;
begin
  V := YMagen.ClientRect;
  InterseccionRectaYVentana(A, B, C, V, NumPuntos, Punto1, Punto2);
  if NumPuntos = 2 then
    Segmento(Punto1, Punto2);
end;

procedure Recta(A, B: TPoint);
begin
  RectaCoefs(B.Y-A.Y, A.X-B.X, (A.Y-B.Y)*A.X+(B.X-A.X)*A.Y);
end;




end.
