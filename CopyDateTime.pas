Unit CopyDateTime;

//***************************************************************
//  Для копирования свойства DataTime из одного файла в другой //
//  Modul by SUPERBOT                                          //
//  https://GitHub.com/Superbot-coder                          //
//***************************************************************

interface

Uses Windows;

function CopyDateTimeFileToFile(FileSource,FileDest: String): Boolean;

implementation

function CopyDateTimeFileToFile(FileSource,FileDest: String): Boolean;
Var
  FCreate     : TFileTime;
  FLastAccess : TFileTime;
  FLastWrite  : TFileTime;
  hFileSource : THandle;
  hFileDest   : THandle;
begin
  Result := False;
  try

    hFileSource := CreateFile(PChar(FileSource),   // name of file
                     GENERIC_READ,                 // access mode
                     FILE_SHARE_READ,              // share mode
                     nil,                          // default security
                     OPEN_EXISTING,                // create flags
                     FILE_ATTRIBUTE_NORMAL,        // file attributes
                     0);
    if hFileSource = INVALID_HANDLE_VALUE Then begin
      //RaiseLastOSError;
      Exit;
    end;

   hFileDest := CreateFile(PChar(FileDest),         // name of file
                     GENERIC_READ or GENERIC_WRITE, // access mode
                     FILE_SHARE_WRITE,              // share mode
                     nil,                           // default security
                     OPEN_EXISTING,                 // create flags
                     FILE_ATTRIBUTE_NORMAL,         // file attributes
                     0);
    if hFileDest = INVALID_HANDLE_VALUE Then begin
      //RaiseLastOSError;
      Exit;
    end;

    if Not GetFileTime(hFileSource,@FCreate,@FLastAccess,@FLastWrite) then begin
      //RaiseLastOSError;
      Exit;
    end;

    if Not SetFileTime(hFileDest,@FCREATE,@FLastAccess,@FLastWrite) then begin
      //RaiseLastOSError;
      exit;
    end;

    Result:=True;

  finally
    CloseHandle(hFileDest);
    CloseHandle(hFileSource);
  end;
end;

end.