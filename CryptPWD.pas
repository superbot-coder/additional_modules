unit CryptPWD;

//********************************************************
//      "Modul CryptPWD" by SUPERBOT                    //
//      Https://GitHub.com/Superbot-coder               //
//********************************************************

interface

Uses
  Windows, SysUtils, Classes, DCPrc4, DCPSha512, DCPMD5, DCPConst;

function GetWinUserName: AnsiString;
function GetSystemDrive: AnsiString;
function GetComputerNetName: AnsiString;
function GetVolumeDriveSN(Disk: AnsiString): AnsiString;
function EncryptString(Value: AnsiString): AnsiString;
function DecryptString(Value: AnsiString): AnsiString;
function GetMD5Hash(Value: AnsiString): AnsiString;

implementation

function GetWinUserName: string;
var
  dw_size: DWORD;
begin
  dw_size := 254;
  SetLength(Result, dw_size);
  GetUserName(PChar(Result),dw_size);
  Result := String(PChar(Result));
end;

function GetSystemDrive: String;
var
  dw_size: DWORD;
  Drive : String;
begin
  dw_size := MAXCHAR;
  SetLength(Drive, dw_size);
  GetEnvironmentVariable(PChar('SystemDrive'),PChar(Drive),dw_size);
  Result := PChar(Drive);
end;

function GetComputerNetName: String;
var dw_size: DWORD;
begin
  dw_size := 254;
  SetLength(Result,dw_size);
  GetComputerName(PChar(Result), dw_size);
  Result := String(PChar(Result));
end;

function GetVolumeDriveSN(Disk: String): String;
var
  VolumeSN : DWORD;
  MaxComponentLength : DWORD;
  FileSysFlags : DWORD;
  SN: String;
begin
  GetVolumeInformation(PChar(Disk),nil,0,@VolumeSN,MaxComponentLength,FileSysFlags,nil,0);
  SN := IntToHex(HiWord(VolumeSN),4)+'-'+IntToHex(LoWord(VolumeSN),4);
  Result := SN;
end;

function DigestToStr(Digest: array of byte): String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to SizeOf(Digest)-1 do Result := Result + LowerCase(IntToHex(Digest[i], 2));
end;

function GetMD5Hash(Value: String): String;
var
  Hash: TDCP_md5;
  Digest: array[0..15] of byte; //sha1 вычисляет 160-битовую хэш-сумму (20 байт)
begin
  Hash := TDCP_md5.Create(Nil);    // создаём объект
  Hash.Init;                       // инициализируем
  Hash.UpdateStr(Value);           // вычисляем хэш-сумму
  Hash.Final(Digest);              // сохраняем её в массив       // уничтожаем объект
  Result := DigestToStr(Digest);
  Hash.Free;
end;

function CreateKey: String;
var
 SysDrive: String;
 VolumeSN: String;
 WinUserName: String;
 ComputerName: String;
begin
  SysDrive    := GetSystemDrive;
  VolumeSN    := GetVolumeDriveSN(SysDrive+'\');
  WinUserName := GetWinUserName;
  ComputerName:= GetComputerNetName;
  Result := GetMD5Hash(AnsiLowerCase(WinUserName + ComputerName + VolumeSN));
end;

function EncryptString(Value: AnsiString): String;
var
 i : integer;
 Cipher : TDCP_rc4;
      st: AnsiString;
begin
  Randomize;
  for i:=1 to 16 do st := st + char(Random(255));
  Cipher:= TDCP_rc4.Create(Nil);
  Cipher.InitStr(CreateKey,TDCP_sha512);         // initialize the cipher with a hash of the passphrase
  Result:= Cipher.EncryptString(st+Value);
  Cipher.Burn;
  Cipher.Free;
end;

function DecryptString(Value: AnsiString): AnsiString;
var
  Cipher : TDCP_rc4;
  KeyStr : string;
  st: String;
begin
  Result := '';
  if Value = '' then Exit;
  Cipher := TDCP_rc4.Create(Nil);
  Cipher.InitStr(CreateKey,TDCP_sha512);
  try
    try
      st := Cipher.DecryptString(Value);
      Result := copy(st,17,Length(st)-16);
    except
      //
    end;
  finally
    Cipher.Burn;
    Cipher.Free;
  end;
end;

end.
