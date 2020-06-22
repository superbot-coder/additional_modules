unit OS;

//********************************************************
//      "Modul OS" by SUPERBOT                          //
//      Https://GitHub.com/Superbot-coder               //
//********************************************************

interface

Uses
  SysUtils,
  Windows;

Type TOSVersion = (Unk, UnkNT, Unk9X, WinNT, Win2K, WinXP, Win95, Win98, Win98SE, WinME, Vista, Win7);

function GetOSVersion: TOSVersion;
function OSTypeToStr: String;

implementation

Uses Unit1;

{------------------------------ GetOSVersion ---------------------------------}
function GetOSVersion: TOSVersion;
var
 OSVerInfo:_OSVERSIONINFOA;
 majorVer, minorVer: integer;
begin
 result := Unk;
 OSVerInfo.dwOSVersionInfoSize:=sizeof(OSVerInfo);
 if (GetVersionExA(OSVerInfo)) then
  begin
   majorVer := OSVerInfo.dwMajorVersion;
   minorVer := OSVerInfo.dwMinorVersion;

   case OSVerInfo.dwPlatformId of

    VER_PLATFORM_WIN32_NT:
     case majorVer of
      4: result := WinNT;
      5: case minorVer of
           0: result := Win2K;
           1: result := WinXP;
         else
           result := UnkNT;
         end;
      6: begin
           case minorVer of
             0: Result := Vista;
             1: Result := Win7;
           end;
         end;
     end;{case majorVer NT}

    VER_PLATFORM_WIN32_WINDOWS:
     case majorVer of
       4: case minorVer of
             0 : result := Win95;
            10 : if (OSVerInfo.szCSDVersion[1]='A') then
                   result:=Win98SE else result:=Win98;
            90 : result := WinME;
          else
            result := Unk9X;
          end;
     else
       result := Unk9X;
     end;{case majorVer 9X}

   end;{case PlatformId}
  end; {if GetVersionEx}

end;
{----------------------------- OSTypeToStr -----------------------------------}
function OSTypeToStr: String;
begin
  case GetOSVersion of
    Unk     : Result := 'Unknown';
    UnkNT   : Result := 'Unknown NT';
    Unk9X   : Result := 'Unknown 9X';
    WinNT   : Result := 'Windows NT';
    Win2K   : Result := 'Windows 2000';
    WinXP   : Result := 'Windows XP';
    Win95   : Result := 'Windows 95';
    Win98   : Result := 'Windows 98';
    Win98SE : Result := 'Windows 98 SE';
    WinME   : Result := 'Windows ME';

  end;
end;

end.
