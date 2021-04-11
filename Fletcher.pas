unit Fletcher;

(*******************************************************************************
  Implementation of agorhythm "Fletcher" no optimization
  Autor by SUPERBOT
  Discussion link http://forum.delphimaster.net/cgi-bin/forum.pl?id=1616593632&n=3
  Source link https://github.com/superbot-coder/additional_modules/blob/master/Fletcher.pas
  Source link https://en.wikipedia.org/wiki/Fletcher%27s_checksum
  Source link https://ru.wikipedia.org/wiki/Контрольная_сумма_Флетчера
  Last Update: 11.04.2021
*******************************************************************************)

interface

uses SysUtils;

type
  PUInt16 = ^UInt16;
  PUInt32 = ^Uint32;

function Fletcher8(AStrData: PAnsiChar): UInt8;
function Fletcher16(AStrData: PAnsiChar): UInt16;
function Fletcher32(AStrData: PAnsiChar): UInt32;
function Fletcher32Rev(AStrData: PAnsiChar): UInt32;
function Fletcher64(AStrData: PAnsiChar): UInt64;
function Fletcher64Rev(AStrData: PAnsiChar): UInt64;

implementation

Uses Unit1;

{---------------------------------- Fletcher8 ---------------------------------}
function Fletcher8(AStrData: PAnsiChar): UInt8;
var
  sum1, sum2: UInt8;
  c: Cardinal;
begin
  sum1 := 0;
  sum2 := 0;
  for c := 1 to Length(PAnsiChar(AStrData)) do
  begin
    sum1 := (sum1 + Byte(AStrData^)) mod $0F;
    sum2 := (sum2 + sum1) mod $0F;
    Inc(AStrData);
  end;
  Result := (sum2 shl 4) or sum1;
end;

{---------------------------------- Fletcher16 --------------------------------}
function Fletcher16(AStrData: PAnsiChar): UInt16;
var
  sum1, sum2 : UInt16;
  c: Cardinal;
begin
  sum1 := 0;
  sum2 := 0;
  for c := 1 to Length(PAnsiChar(AStrData)) do
  begin
    sum1 := (sum1 + Byte(AStrData^)) mod $FF;
    sum2 := (sum2 + sum1) mod $FF;
    Inc(AStrData);
  end;
  Result := (sum2 shl 8) or sum1;
end;

{-------------------------------- Fletcher32 ----------------------------------}
function Fletcher32(AStrData: PAnsiChar): UInt32;
var
  sum1, sum2, len, i: UInt32;
  sum0: Uint16;
  rem: Byte; // Remainder of division
  PData: PUint16;
begin
  sum1 := 0;
  sum2 := 0;
  len  := Length(PAnsiChar(AStrData));
  // Uint16 размер чтения входящего блока 2 байта
  rem  := (len mod 2);
  PData := PUint16(AStrData);

  // Определение четности
  if rem = 0 then len := len div 2
  else len := (len div 2) + 1;

  for i := 1 to len do
  begin
    sum0 := PData^;
    // Определяем, что блок последний
    // Сдвигает байты влево, а затем обратно,
    // что бы почисть от возможного мусора в последнем блоке
    // если размер блока выходит за размер входных данных
    if (i = len) and (rem <> 0) then sum0 := (sum0 shl 8) shr 8;
    sum1 := (sum1 + sum0) mod $FFFF;
    sum2 := (sum2 + sum1) mod $FFFF;
    Inc(PData);
  end;

  Result := (sum2 shl 16) or sum1;
end;

{------------------------------ Fletcher32Rev ---------------------------------}
function Fletcher32Rev(AStrData: PAnsiChar): UInt32;
var
  sum1, sum2, len, i: UInt32;
  sum0, sum: Uint16;
  rem: Byte; // Remainder of division
  PData: PUint16;
begin
  sum1 := 0;
  sum2 := 0;
  len  := Length(PAnsiChar(AStrData));
  // Uint16 размер чтения входящего блока 2 байта
  rem  := (len mod 2);
  PData := PUint16(AStrData);

  // Определение четности
  if rem = 0 then len := len div 2
  else len := (len div 2) + 1;

  for i := 1 to len do
  begin
    sum := PData^;
    // разворачиваем байты в другой порядок
	// [ba] -> [ab]
    sum0 := ((sum0 xor sum0) or sum) shl 8;
    sum0 := sum0 or (sum shr 8);
    // Определяем, что блок последний
    // Сдвигает биты вправо, а затем обратно,
    // что бы почисть от возможного мусора в последнем блоке
    // если размер блока выходит за размер входных данных
    if (i = len) and (rem <> 0) then sum0 := (sum0 shr 8) shl 8;
    sum1 := (sum1 + sum0) mod $FFFF;
    sum2 := (sum2 + sum1) mod $FFFF;
    Inc(PData);
  end;

  Result := (sum2 shl 16) or sum1;
end;

{------------------------------- Fletcher64 -----------------------------------}
function Fletcher64(AStrData: PAnsiChar): UInt64;
var
  sum1, sum2: UInt64;
  sum0, len, i: UInt32;
  rem, shift: Byte; //rem - Remainder of division
  PData : PUint32;

begin
  sum1  := 0;
  sum2  := 0;
  shift := 0;
  len   := Length(PAnsiChar(AStrData));
  rem   := (len mod 4); // Uint32 размер чтения входящего блока 4 байта
  PData := PUint32(AStrData);

  // Определение четности
  if rem = 0 then len := len div 4
  else
  begin
    // если rem <> 0 вычисляем сдвиг (SizeOf(sum0) - rem) * 8 Bit
    shift := (4 - rem) * 8; 
    Len := (Len div 4) + 1;
  end;

  for i := 1 to len do
  begin
    sum0  := PData^;
    // Определяем, что блок последний
    // Сдвигает байты влево, а затем обратно,
    // что бы почисть от возможного мусора в последнем блоке
    // если размер блока выходит за размер входных данных
    if (i = len) and (rem <> 0) then sum0 := (sum0 shl shift) shr shift;
    sum1 := (sum1 + sum0) mod $FFFFFFFF;
    sum2 := (sum2 + sum1) mod $FFFFFFFF;
    Inc(PData);
  end;

  Result := (sum2 shl 32) or sum1;
end;

{------------------------------- Fletcher64Rev --------------------------------}
function Fletcher64Rev(AStrData: PAnsiChar): UInt64;
var
  sum1, sum2: UInt64;
  sum, sum0, len, i: UInt32;
  rem, shift, j, b: Byte; //rem - Remainder of division
  PData : PUint32;
  
begin
  sum1  := 0;
  sum2  := 0;
  shift := 0;
  len   := Length(PAnsiChar(AStrData));
  rem   := (len mod 4); // Uint32 размер чтения входящего блока 4 байта
  PData := PUint32(AStrData);

  // Определение четности
  if rem = 0 then len := len div 4
  else
  begin
    // если rem <> 0 вычисляем сдвиг (SizeOf(sum0) - rem) * 8 Bit
    shift := (4 - rem) * 8; 
    Len := (Len div 4) + 1;
  end;

  for i := 1 to len do
  begin
    sum  := PData^;
    // разворачиваем байты в другой порядок
	// Uint32[dcba] -> Uint32[abcd]
	for j := 0 to 3 do
    begin
      b := (b xor b) or (sum shr (j * 8));
      sum0 := (sum0 or b);
      if j <> 3 then sum0 := sum0 shl 8;
    end;	
    // Определяем, что блок последний
    // Сдвигает байты вправо, а затем обратно,
    // что бы почисть от возможного мусора в последнем блоке
    // если размер блока выходит за размер входных данных
    if (i = len) and (rem <> 0) then sum0 := (sum0 shr shift) shl shift;
    sum1 := (sum1 + sum0) mod $FFFFFFFF;
    sum2 := (sum2 + sum1) mod $FFFFFFFF;
    Inc(PData);
  end;

  Result := (sum2 shl 32) or sum1;
end;

end.