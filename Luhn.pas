unit Luhn;

//************************************************************************//
//  "Modul Luhn"                                                           //  
//   https://ru.wikipedia.org/wiki/Алгоритм_Луна                          //
//   Source https://wiki.openmrs.org/display/docs/Check+Digit+Algorithm   //
//   https://GitHub.com/Superbot-coder                                    //
//************************************************************************//

interface

Uses SysUtils, Math;

function CheckDigit(idWithoutCheckdigit : string) : Integer;

implementation
{----------------------------------- }
function CheckDigit(idWithoutCheckdigit : string) : Integer;
const
  // allowable characters within identifier
  validChars : string = '0123456789ABCDEFGHIJKLMNOPQRSTUVYWXZ_';
var
  I, Sum, Digit, Weight : Integer;
  ch : Char;
begin
  // remove leading or trailing whitespace, convert to uppercase
  idWithoutCheckdigit := UpperCase(Trim(idWithoutCheckdigit));
  // this will be a running total
  Sum := 0;
  // loop through digits from right to left
  for I := 0 to Length(idWithoutCheckdigit) - 1 do
  begin
    //set ch to "current" character to be processed
    ch := idWithoutCheckdigit[Length(idWithoutCheckdigit) - i];
    // throw exception for invalid characters
    if Pos(ch,validChars) = 0 then
      raise Exception.Create(ch + ' is an invalid character');
    // our "digit" is calculated using ASCII value - 48
    Digit := Ord(ch) - 48;
    // weight will be the current digit's contribution to
    // the running total
    if (i mod 2 = 0) then
      // for alternating digits starting with the rightmost, we
      // use our formula this is the same as multiplying x 2 and
      // adding digits together for values 0 to 9.  Using the
      // following formula allows us to gracefully calculate a
      // weight for non-numeric "digits" as well (from their
      // ASCII value - 48).
      Weight := (2 * Digit) - Floor(Digit / 5) * 9
    else
      // even-positioned digits just contribute their ascii
      // value minus 48
      Weight := Digit;
    // keep a running total of weights
    Sum := Sum + Weight;
  end;
  // avoid sum less than 10 (if characters below "0" allowed,
  // this could happen)
  Sum := Abs(Sum) + 10;
  // check digit is amount needed to reach next number
  // divisible by ten
  result := (10 - (sum mod 10)) mod 10;
end;

end.