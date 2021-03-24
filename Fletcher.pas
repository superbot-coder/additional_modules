unit Fletcher;

(*******************************************************************************
  Implementation of agorhythm "Fletcher" no optimization
  Autor by SUPERBOT
  Source link https://en.wikipedia.org/wiki/Fletcher%27s_checksum
  Source link https://ru.wikipedia.org/wiki/Контрольная_сумма_Флетчера
*******************************************************************************)

interface
uses SysUtils;
    
function Fletcher16(AStrData: AnsiString): UInt16;
function Fletcher32(AStrData: AnsiString): UInt32;
function Fletcher64(AStrData: AnsiString): UInt64;

implementation
{---------------------------------- Fletcher16 --------------------------------}
function Fletcher16(AStrData: AnsiString): UInt16;
var
  sum1, sum2 : UInt16;
  ch: AnsiChar;
begin
  sum1 := 0;
  sum2 := 0;
  for ch in AStrData do
  begin
    sum1 := (sum1 + Byte(ch)) mod $FF;
    sum2 := (sum2 + sum1) mod $FF;
  end;
  Result := (sum2 shl 8) or sum1;
end;

{-------------------------------- Fletcher32 ----------------------------------}
function Fletcher32(AStrData: AnsiString): UInt32;
var
  sum1, sum2: UInt32;
  ch: AnsiChar;
begin
  sum1 := 0;
  sum2 := 0;
  for ch in AStrData do
  begin
    sum1 := (sum1 + Byte(ch)) mod $FFFF;
    sum2 := (sum2 + sum2) mod $FFFF;
  end;
  Result := (sum2 shl 16) or sum1;
end;

{------------------------------- Fletcher64 -----------------------------------}
function Fletcher64(AStrData: AnsiString): UInt64;
var
  sum1, sum2: UInt64;
  ch: AnsiChar;
begin
  sum1 := 0;
  sum2 := 0;
  for ch in AStrData do
  begin
    sum1 := (sum1 + Byte(ch)) mod $FFFFFFFF;
    sum2 := (sum2 + sum1) mod $FFFFFFFF;
  end;
  Result := (sum2 shl 32) or sum1;
end;

end.