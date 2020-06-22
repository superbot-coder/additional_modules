unit Files;

//********************************************************
//      "Modul Files" by SUPERBOT                       //
//      Https://GitHub.com/Superbot-coder               //
//********************************************************

interface

Uses SysUtils;

function GetSearchFileSize(FileName: String): Int64;
function GetFileSizeFormat(FileName: String): String;
function FormatFileSize(FileSize: Int64): string;

implementation

Function SetPoint(R: Real): String;
Var i: integer;
    s: String;
begin
   Str(R:3:2, s);
   if s[4] = '.' then s := Copy(s, 1, 3)
   else begin
     s := Copy(s, 1, 4);
     for I := 1 to Length(s) do if s[i] = '.' then s[i]:=',';
   end;
   Result := s;
end;

function GetSearchFileSize(FileName: String): int64;
var
  SR: TSearchRec;
begin
  Result := -1;
  if FindFirst(FileName, faAnyFile, SR) = 0 then
  begin
    Result := SR.Size;
    FindClose(SR);
  end;
end;


function GetFileSizeFormat(FileName: String): String;
Var
  SR : TSearchRec;
const
   K = 1024;
   M = 1048576;
   G = 1073741824;
begin
  Result := '';
  if FindFirst(FileName, faAnyFile, SR) = 0 then
  begin

    if SR.Size < K then Result := IntToStr(SR.Size)+' BT'
    else
      if SR.Size < M then Result := SetPoint(SR.Size/K)+' KB'
      else
        if SR.Size < G then Result := SetPoint(SR.Size/M)+' MB'
        else
          Result := SetPoint((SR.Size/G))+' GB';

    FindClose(SR);
  end;
   {
    if SR.Size < K then
    begin
      Result := IntToStr(SR.Size)+' BT';
      FindClose(SR);
      exit;
    end;
    if SR.Size < M then
    begin
      Result := SetPoint(SR.Size/K)+' KB';
      FindClose(SR);
      Exit;
    end;
    if SR.Size < G then
    begin
      Result := SetPoint(SR.Size/M)+' MB';
      FindClose(SR);
      Exit;
    end;
    Result := SetPoint((SR.Size/G))+' GB';
    }
end;

function FormatFileSize(FileSize: Int64): string;
var size: Extended;
begin
  Result := '';
  if FileSize = -1 then Exit;
  size := FileSize;
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
