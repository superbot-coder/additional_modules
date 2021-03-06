﻿unit FormatFileSizeMod;

//********************************************************
//      Modul by SUPERBOT                               //
//      https://GitHub.com/Superbot-coder               //
//********************************************************

interface

Uses SysUtils, Windows;

function GetFileSizeFormat(FileName: String): String;
function FormatFileSize(Size: extended): string;
function GetFileSz(FileName: String): int64;

implementation

function GetFileSz(FileName: String): int64;
var
  SR : TSearchRec;
begin
  if FindFirst(FileName, faAnyFile, SR) = 0 then
  begin
    Result := SR.Size;
    SysUtils.FindClose(SR);
  end;
end;

function GetFileSizeFormat(FileName: String): String;
var
  SR : TSearchRec;
begin
  if FindFirst(FileName, faAnyFile, SR) = 0 then
  begin
    Result := FormatFileSize(SR.Size);
    SysUtils.FindClose(SR);
  end;
end;

function FormatFileSize(Size: Extended): string;
begin
  if Size = 0 then
  begin
    Result := '0 B';
  end
  else if Size < 1000 then
  begin
    Result := FormatFloat('0', Size) + ' B';
  end
  else
  begin
    Size := Size / 1024;
    if (Size < 1000) then
    begin
      Result := FormatFloat('0.0', Size) + ' KB';
    end
    else
    begin
      Size := Size / 1024;
      if (Size < 1000) then
      begin
        Result := FormatFloat('0.00', Size) + ' MB';
      end
      else
      begin
        Size := Size / 1024;
        if (Size < 1000) then
        begin
          Result := FormatFloat('0.00', Size) + ' GB';
        end
        else
        begin
          Size := Size / 1024;
          if (Size < 1024) then
          begin
            Result := FormatFloat('0.00', Size) + ' TB';
          end
        end
      end
    end
  end;
end;

end.
