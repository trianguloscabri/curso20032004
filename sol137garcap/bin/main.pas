unit main;
{$R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, ToolWin, Buttons, Menus, OleCtrls;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    Archivo1: TMenuItem;
    Acerca1: TMenuItem;
    N1: TMenuItem;
    Salir1: TMenuItem;
    Image1: TImage;
    DialogoGrabar: TSaveDialog;
    Guardarbitmap1: TMenuItem;
    Copiaralportapapeles1: TMenuItem;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure RatonArriba(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RatonAbajo(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RatonMovido(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BGuardarClick(Sender: TObject);
    procedure BCopiarClick(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure Acerca1Click(Sender: TObject);
  private
    Estado, PuntoActual: Word;
    Origen, Inicio, Final: TPoint;
    procedure Redibujar;
    procedure DibujarMarcador(P, Q: TPoint);
    function CrearDibujo: TBitmap;
    function CuantosEF(x0, y0: Real; var E1, E2, F1, F2: TPoint): Integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses Math, Clipbrd, Defs, Dibujos;

const
  esQuieto = 0;
  esCambiando = 1;
  esArrastrando = 2;
  esMarcandoZona = 3;

var
  Radio: Word;
  Centro: TPoint;


procedure TForm1.FormCreate(Sender: TObject);
begin
  Kanvas := Image1.Canvas;
  Inicio := Point(0, 0);
  Final := Point(0, 0);
  Ymagen := Image1;
  NumPuntos := 0;
  AgregarPunto(100, 100);
  AgregarPunto(123, 53);
  AgregarPunto(40, 304);
  AgregarPunto(355, 304);
  NumPuntos := 2;
  Redibujar;
end;

procedure TForm1.RatonArriba(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Estado := esQuieto;
end;

procedure TForm1.RatonAbajo(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  PuntoActual := SobreQuePunto(X, Y);
  if (PuntoActual >= 1 ) and (PuntoActual <= 2) then
    Estado := esCambiando
  else if EsInterior(Point(X, Y), Puntos[2], Puntos[3], Puntos[4]) then
    begin
      Estado := esArrastrando;
      Origen := Point(X, Y);
    end
  else
    begin
      Estado := esMarcandoZona;
      if Inicio.X <> Final.X then
        DibujarMarcador(Inicio, Final);
      Inicio := Point(X, Y);
      Final := Point(X, Y);
      Canvas.MoveTo(X, Y);
    end;
end;

procedure TForm1.RatonMovido(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  I: Word;
  x0,y0, Total: Integer;
  E1, E2, F1, F2: TPoint;
begin
  if Estado = esCambiando then
    begin
      x0 := Puntos[1].X-Puntos[3].X;
      y0 := Puntos[3].Y-Puntos[1].Y;
      Total := CuantosEF(x0,y0,E1, E2,F1, F2);
      Puntos[PuntoActual] := Point(X, Y);
      StatusBar1.SimpleText := Format('A=(%d,%d), B=(%d,%d), C=(%d,%d). P=(%d,%d). %d soluciones',
        [Puntos[2].X, Puntos[2].Y, Puntos[3].X, Puntos[3].Y,
         Puntos[4].X, Puntos[4].Y,
         Puntos[1].X, Puntos[1].Y, Total]);
      Redibujar;
    end
  else if Estado = esMarcandoZona then
    begin
      DibujarMarcador(Inicio, Final);
      Final := Point(X, Y);
      DibujarMarcador(Inicio, Final);
    end
  else if Estado = esArrastrando then
      begin
        for I := 2 to 4 do
          begin
            Puntos[I].X := Puntos[I].X + X - Origen.X;
            Puntos[I].Y := Puntos[I].Y + Y - Origen.Y;
          end;
        Origen := Point(X, Y);
        Final := Inicio;
        Redibujar;
      end;
end;

procedure TForm1.DibujarMarcador(P, Q: TPoint);
begin
  with Image1.Canvas do
    begin
      Pen.Width := 1;
      Pen.Style := psDot;
      Pen.Mode := pmNotXor;
      MoveTo(P.X, P.Y);
      LineTo(P.X, Q.Y);
      LineTo(Q.X, Q.Y);
      LineTo(Q.X, P.Y);
      LineTo(P.X, P.Y);
      Pen.Mode := pmCopy;
      Pen.Style := psSolid;
    end;
end;

function TForm1.CrearDibujo: TBitmap;
var
  BitMap: TBitMap;
  ROrigen, RDestino: TRect;
begin
  BitMap := TBitMap.Create;
  if Inicio.X <> Final.X then
    begin
      ROrigen.Left := Min(Inicio.X, Final.X);
      ROrigen.Right := Max(Inicio.X, Final.X);
      ROrigen.Bottom := Max(Inicio.Y, Final.Y);
      ROrigen.Top := Min(Inicio.Y, Final.Y);
      Inc(ROrigen.Left);
      Dec(ROrigen.Right);
      Inc(ROrigen.Top);
      Dec(ROrigen.Bottom);
    end
  else
    ROrigen := Rect(1, 1, Pred(Width), Pred(Height));
  BitMap.Width  := ROrigen.Right-ROrigen.Left;
  BitMap.Height := ROrigen.Bottom-ROrigen.Top;
  RDestino := Rect(0, 0, BitMap.Width, BitMap.Height);
  BitMap.Canvas.CopyRect(RDestino, Image1.Canvas, ROrigen);
  CrearDibujo := Bitmap;
end;

procedure TForm1.BGuardarClick(Sender: TObject);
var
  BitMap: TBitMap;
begin
  if DialogoGrabar.Execute then
    begin
      BitMap := CrearDibujo;
      BitMap.SaveToFile(DialogoGrabar.FileName);
      BitMap.Free;
    end;
end;

procedure TForm1.BCopiarClick(Sender: TObject);
var
  BitMap: TBitMap;
begin
  BitMap := CrearDibujo;
  ClipBoard.Assign(BitMap);
  BitMap.Free;
end;


procedure TForm1.Salir1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Redibujar;
var
  A, B, C, D, E1, F1, E2, F2, M: TPoint;
  x0, y0, Total, cc: Integer;
  u,v, x: Double;
begin
  if v=0 then
    Exit;
  D := Puntos[1];
  A := Puntos[2];
  B := Puntos[3];
  C := Puntos[4];
  x0 := D.X - B.X;
  y0 := B.Y - D.Y;
  cc := C.X-B.X;
  u := A.X-B.X;
  v := B.Y-A.Y;
  Image1.Canvas.FillRect(Image1.ClientRect);
  Triangulo(A, B, C);
  Circulo(A, 2);
  Circulo(D, 2);
  Total := CuantosEF(x0, y0, E1, E2, F1, F2);
  Image1.Canvas.Pen.Color := clRed;
  if Total > 0 then
    Segmento(E1, F1);
  if Total > 1 then
    Segmento(E2, F2);
  Image1.Canvas.Pen.Color := clBlack;
  for y0 := 20 to B.Y- A.Y + 50 do
    if y0 <> 0 then
      begin
        x := u * y0 / v + cc * v / 8 /y0;
        if y0 = 20 then
          Image1.Canvas.Moveto(Round(B.X+x), Round(B.Y-y0))
        else
          Image1.Canvas.Lineto(Round(B.X+x), Round(B.Y-y0))
      end;
  M := PuntoMedio(A, B);
  Segmento(C, M);
  M := PuntoMedio(B, C);
  Segmento(A, M);

end;


function TForm1.CuantosEF(x0, y0: Real; var E1, E2, F1, F2: TPoint): Integer;
var
  t, Signo, Total: Integer;
  A, B, C, D: TPoint;
  m, u, v, k, p1, p2, q1, q2,
  r, cc: Double;
  HayE, HayF: Boolean;
begin
  Total := 0;
  D := Puntos[1];
  A := Puntos[2];
  B := Puntos[3];
  C := Puntos[4];
  u  := A.X - B.X;
  v  := B.Y - A.Y;
  cc  := C.X - B.X;
  r  := cc * v * v  - 8 * v * x0 * y0 + 8 * u * y0 * y0;
  if r > 0 then
    for signo := 0 to 1 do
      begin
        HayE := False;
        HayF := False;

        m := (-cc * v + 4 * x0 * y0 + (2*signo-1) * sqrt(cc * r ))/2/(2* x0*x0-cc * u);

        if m * u - v <> 0 then
          begin
            k := (m * x0 - y0) /(m*u-v);
            if (k > 0) and (k < 1) then
              begin
               HayE := True;
               p1 := k * u;
               p2 := k * v;
              end;
          end;
       if m <> 0 then
         begin
           q1 := x0 - y0/m;
           q2 := 0;
           if (q1 > 0) and (q1 < cc) then
             HayF := True;
         end;
       if HayE and HayF then
         begin
           Inc(Total);
           if Total = 1 then
             begin
               E1 := Point(Round(p1+B.X), Round(B.Y-p2));
               F1 := Point(Round(q1+B.X), Round(B.Y-q2));
             end
           else
             begin
               E2 := Point(Round(p1+B.X), Round(B.Y-p2));
               F2 := Point(Round(q1+B.X), Round(B.Y-q2));
             end;
         end;
      end;
  CuantosEF := Total;
end;

procedure TForm1.Acerca1Click(Sender: TObject);
begin
  Application.MessageBox('Pulsando y arrastrando el interior del triángulo se arrastra todo el triángulo.' + ^M^M +
                         'Se pueden arrastrar el vértice superior y el punto libre.'+ ^M^M +
                         'Cuando el punto libre está en el triangulito curvilíneo determinado por' + ^M +
                         'la hipérbola y las medianas, el problema tiene dos soluciones.' + ^M^M +
                         'Francisco Javier García Capitán, 2004.',
                         'Información',MB_ICONINFORMATION);
end;

end.
