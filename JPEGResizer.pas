//************************************************************************//
//  Modul JPEGResizer.pas                                                 //  
//  Exsample https://github.com/superbot-coder/JPEGResizer                //
//  https://GitHub.com/Superbot-coder                                     //
//************************************************************************//


unit JPEGResizer;

interface

Uses System.Math, Winapi.Windows, Vcl.Graphics, Jpeg;

Type TScaleMode = (scaleNone, scaleInto);

procedure JPEGResize(jpg: TJpegImage; NewWidth, NewHeight: integer; Mode: TScaleMode);

implementation

procedure JPEGResize(jpg: TJpegImage; NewWidth, NewHeight: integer; Mode: TScaleMode);
var
  bmp    : TBItmap;
  Scale  : Double;
  PrevPt : TPoint;
begin

  bmp := Tbitmap.Create;
  try

   {case Mode of
      scaleNone: bmp.SetSize(NewWidth, NewHeight);
      scaleInto:
        begin
          Scale := jpg.Width / jpg.Height;
          bmp.Width  := NewWidth;
          bmp.Height := Round(NewWidth * Scale);
          if bmp.Height > NewHeight then
          begin
            bmp.Height := NewHeight;
            bmp.Width  := Round(NewHeight * Scale);
          end;
        end;
    end; }

    case Mode of
      scaleNone: bmp.SetSize(NewWidth, NewHeight);
      scaleInto:
        begin
          Scale := Min(NewWidth / jpg.Width, NewHeight / jpg.Height);
          bmp.SetSize(Round(jpg.Width * Scale), Round(jpg.Height * Scale));
        end;
    end;

    bmp.PixelFormat := pf24bit;
    SetStretchBltMode(bmp.canvas.handle, 4);
    SetBrushOrgEx(bmp.canvas.handle, PrevPt.X, PrevPt.Y, @PrevPt);
    StretchBlt(bmp.canvas.handle, 0, 0, bmp.Width, bmp.Height,
                jpg.canvas.handle, 0, 0, jpg.width, jpg.height, SRCCOPY);

    jpg.PixelFormat := jf24Bit;
    jpg.Performance := jpBestQuality;
    jpg.assign(bmp);

  finally
    bmp.Free;
  end;
  //
end;

end.
