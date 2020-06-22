Unit GUID;

interface

Uses Error;

Type
  TCLSID = TGUID;
  POleStr = PWideChar;

function CoCreateGuid(out guid: TGUID): HResult; stdcall;
function StringFromCLSID(const clsid: TCLSID; out psz: POleStr): HResult; stdcall;
procedure CoTaskMemFree(pv: Pointer); stdcall;

function CreateGuid: string;

implementation

function CoCreateGuid; external 'ole32.dll' name 'CoCreateGuid';
function StringFromCLSID; external 'ole32.dll' name 'StringFromCLSID';
procedure CoTaskMemFree; external 'ole32.dll' name 'CoTaskMemFree';

{
function Succeeded(Res: HResult): Boolean;
begin
  Result := Res and $80000000 = 0;
end;

procedure OleCheck(Result: HResult);
begin
  if not Succeeded(Result) then Exit;//OleError(Result);
end;
 }

function GUIDToString(const ClassID: TGUID): string;
var
  P: PWideChar;
begin
  //OleCheck(StringFromCLSID(ClassID, P));
  if Not (StringFromCLSID(ClassID, P) and $80000000 = 0) then
  begin
    SaveErrorMessage('Uses GUID, function CoCreateGuid');
    Exit; //OleError(Result);
  end;
  Result := P;
  CoTaskMemFree(P);
end;

function CreateGuid: string;
 var
   ID: TGUID;
 begin
   Result := '';
   if CoCreateGuid(ID) = S_OK then
     Result := GUIDToString(ID);
 end;

end.