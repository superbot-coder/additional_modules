unit Fletcher;

(*******************************************************************************
  Implementation of agorhythm "Fletcher" no optimization
  Autor by SUPERBOT
  Discussion link http://forum.delphimaster.net/cgi-bin/forum.pl?id=1616593632&n=3
  Source link https://github.com/superbot-coder/additional_modules/blob/master/Fletcher.pas
  Source link https://en.wikipedia.org/wiki/Fletcher%27s_checksum
  Source link https://ru.wikipedia.org/wiki/Контрольная_сумма_Флетчера
*******************************************************************************)

interface

uses SysUtils;

function Fletcher8(AStrData: PAnsiChar): UInt8;
function Fletcher16(AStrData: PAnsiChar): UInt16;
function Fletcher32(AStrData: PAnsiChar): UInt32;
function Fletcher64(AStrData: PAnsiChar): UInt64;

implementation

Uses Unit1;

{---------------------------------- Fletcher8 ---------------------------------}
function Fletcher8(AStrData: PAnsiChar): UInt8;
var
  sum1, sum2: UInt8;
  ch: AnsiChar;
begin
  sum1 := 0;
  sum2 := 0;
  for ch in AnsiString(PAnsiChar(AStrData)^) do
  begin
    sum1 := (sum1 + Byte(ch)) mod $0F;
    sum2 := (sum2 + sum1) mod $0F;
  end;
  Result := (sum2 shl 4) or sum1;
end;

{---------------------------------- Fletcher16 --------------------------------}
function Fletcher16(AStrData: PAnsiChar): UInt16;
var
  sum1, sum2 : UInt16;
  ch: AnsiChar;
begin
  sum1 := 0;
  sum2 := 0;
  for ch in AnsiString(PAnsiChar(AStrData)^) do
  begin
    sum1 := (sum1 + Byte(ch)) mod $FF;
    sum2 := (sum2 + sum1) mod $FF;
  end;
  Result := (sum2 shl 8) or sum1;
end;

{-------------------------------- Fletcher32 ----------------------------------}
function Fletcher32(AStrData: PAnsiChar): UInt32;
var
  sum1, sum2, len, i: UInt32;
type
  PUInt16 = ^UInt16;
begin
  sum1   := 0;
  sum2   := 0;
  len    := Length(PAnsiChar(AStrData));

  // Определение четности
  if (Len mod 2) = 0 then len := len div 2
  else len := (len div 2) + 1;

  for i := 1 to len do
  begin
    sum1 := (sum1 + PUint16(AStrData)^) mod $FFFF;
    sum2 := (sum2 + sum1) mod $FFFF;
    Inc(PUint16(AStrData));
  end;
  Result := (sum2 shl 16) or sum1;
end;

{------------------------------- Fletcher64 -----------------------------------}
function Fletcher64(AStrData: PAnsiChar): UInt64;
var
  sum1, sum2: UInt64;
  len, i: UInt32;
Type
  PUint32 = ^Uint32;
begin
  sum1 := 0;
  sum2 := 0;
  len := Length(PAnsiChar(AStrData));

  // Определение четности
  if (len mod 4) = 0 then len := len div 4
  else Len := (Len div 4) + 1;

  for i := 1 to len do
  begin
    sum1 := (sum1 + PUint32(AStrData)^) mod $FFFFFFFF;
    sum2 := (sum2 + sum1) mod $FFFFFFFF;
    Inc(PUint32(AStrData));
  end;
  Result := (sum2 shl 32) or sum1;
end;

end.