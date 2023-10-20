unit RESTServer.Service.Version.vers1;

interface

uses
  WinApi.Windows,
  System.SysUtils, System.Classes, System.JSON, REST.JSON,
  Datasnap.DSServer, Datasnap.DSAuth, DataSnap.DSProviderDataModuleAdapter,
  DataSnap.DSSession, Data.DBXPlatform,Data.DBXCommon,
  IdBaseComponent, IdSASL, IdSASLUserPass, IdSASL_CRAMBase, IdSASL_CRAM_MD5,
  IdHash, IdHashMessageDigest, IdHashSHA, IdHashCRC,Data.DB,
  RESTServer.Service.Records;
{$DEFINE PCMService}
type
  {$METHODINFO ON}
  v1 = class(TComponent)
  private
    { Private-Deklarationen }
    procedure ResultToJSONContent(const AJSONObject: TJSONObject);
  public
    { Public-Deklarationen }

    ////////////////////////////////////////////////////////////////////////////
    // PCM - RESTfunktionen                                                   //
    ////////////////////////////////////////////////////////////////////////////
    // Token erstellen
    [TRoleAuth('WebAPI_PCM')]
    function Createtoken: TJSONObject;
    // Token erneuern
    [TRoleAuth('WebAPI_PCM')]
    function AcceptRefreshtoken(const AJSONObject: TJSONObject): TJSONObject;
    // Token löschen
    [TRoleAuth('WebAPI_PCM')]
    function CancelDeletetoken: TJSONObject;
    // Backup erstellen
    [TRoleAuth('WebAPI_PCM')]
    function UpdateCreateBackup: TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetKalenderConfig(const AJSONObject: TJSONObject): TJSONObject;

    ////////////////////////////////////////////////////////////////////////////
    // APP - RESTfunktionen                                                   //
    ////////////////////////////////////////////////////////////////////////////
    // Login ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function CheckServer: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function GetLogin: TJSonObject;
    // kontakte ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetContacts: TJSonObject;
    // kontakte übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetContacts(const AJSONObject: TJSONObject): TJSonObject;
    // Kalender ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetCalendar: TJSonObject;
    // Kalender übernhmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetCalendar(const AJSONObject: TJSONObject): TJSonObject;
    // Passwörter ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetPasswords: TJSONObject;
    // Passwörter übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetPasswords(const AJSONObject: TJSONObject): TJSONObject;
    // Serials ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetSerials: TJSONObject;
    // Serials übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetSerials(const AJSONObject: TJSONObject): TJSONObject;
    // Ausgaben ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetExpenditure: TJSONObject;
    // Ausgaben übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetExpenditure(const AJSONObject: TJSONObject): TJSONObject;
    // Einnahmen ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetReceipts: TJSONObject;
    // Einnahmen übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetReceipts(const AJSONObject: TJSONObject): TJSONObject;


  end;
  {$METHODINFO OFF}


implementation
uses
  PCM.Functions,
  PCM.Data,
  PCMService.API.Methods,
  PCMService.WebModules;

// Ergebnis in JSON umwandeln
procedure v1.ResultToJSONContent(const AJSONObject: TJSONObject);
var
  metaData: TDSInvocationMetadata;
begin
  metaData:= GetInvocationMetadata;
  metaData.ResponseContentType := 'application/json; charset=utf-8';
  metaData.ResponseContent := AJSONObject.ToJSON;
end;
////////////////////////////////////////////////////////////////////////////////
// PCM - RESTfunktionen                                                       //
////////////////////////////////////////////////////////////////////////////////
// PCM - Token
// Token erstellen
function v1.Createtoken: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  Result := CreateToken_Intern;
  metaData.ResponseCode:= iCode;
  metaData.ResponseMessage:= sMessage;
  ResultToJSONContent(Result);
end;
// Token erneuern
function v1.AcceptRefreshtoken(const AJSONObject: TJSONObject): TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  Result := RefreshToken_Intern(AJSONObject);
  metaData.ResponseCode:= iCode;
  metaData.ResponseMessage:= sMessage;
  ResultToJSONContent(Result);
end;
// Token löschen
function v1.CancelDeletetoken: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
 metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count > 1 then
  begin
    Result := DeleteToken_Intern(StringReplace(metaData.QueryParams[0],'Token=','',[rfReplaceAll,rfIgnoreCase]),
    StrToInt(StringReplace(metaData.QueryParams[1],'Program=','',[rfReplaceAll,rfIgnoreCase])));
  end
  else
  begin
    Result := DeleteToken_Intern('',999);
  end;
  metaData.ResponseCode:= iCode;
  metaData.ResponseMessage:= sMessage;
  ResultToJSONContent(Result);
end;
// PCM - Backup
// Backuperstellen
function v1.UpdateCreateBackup: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count > 1 then
  begin
    Result := CreateBackup_Intern(StringReplace(metaData.QueryParams[0],'Token=','',[rfReplaceAll,rfIgnoreCase]),
    StringReplace(metaData.QueryParams[1],'Path=','',[rfReplaceAll,rfIgnoreCase]));
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result := CreateBackup_Intern('','');
  end;
  ResultToJSONContent(Result);
end;
// Kalenderkonfiguration ermitteln
function v1.UpdateGetKalenderConfig(const AJSONObject: TJSONObject): TJSONObject;
begin
  Result := GetKalenderConfig_Intern(AJSONObject);
  ResultToJSONContent(Result);
end;
////////////////////////////////////////////////////////////////////////////////
// APP - RESTfunktionen                                                       //
////////////////////////////////////////////////////////////////////////////////
// PCM - APP
function v1.CheckServer: TJSonObject;
begin
  Result:= CheckServer_Intern;
  ResultToJSONContent(Result);
end;
// Login Daten ermitteln
function v1.GetLogin: TJSonObject;
begin
  Result:= GetLogin_Intern;
  ResultToJSONContent(Result);
end;
// Kontakte ermitteln
function v1.UpdateGetContacts: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 1 then
  begin
    Result := GetKontakte_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result := GetKontakte_Intern('');
  end;
  ResultToJSONContent(Result);
end;
// Kontakte übernhmen
function v1.acceptSetContacts(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 2 then
  begin
    metaData.ResponseCode:= 200;
    Result:= SetKontakte_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),StrToBool(StringReplace(metaData.QueryParams[1],'Test=','',[rfReplaceAll,rfIgnoreCase])), AJSONObject);
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result:= SetKontakte_Intern('',false,AJSONObject);
  end;
  ResultToJSONContent(Result);
end;
// Kalender ermitteln
function v1.UpdateGetCalendar: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 1 then
  begin
    Result := GetKalender_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result := GetKalender_Intern('');
  end;
  ResultToJSONContent(Result);
end;
// Kalender übernehmen
function v1.AcceptSetCalendar(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 2 then
  begin
    metaData.ResponseCode:= 200;
    Result:= SetKalender_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),StrToBool(StringReplace(metaData.QueryParams[1],'Test=','',[rfReplaceAll,rfIgnoreCase])), AJSONObject);
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result:= SetKalender_Intern('',false,AJSONObject);
  end;
  ResultToJSONContent(Result);
end;
// Passwörter ermitteln
function v1.UpdateGetPasswords: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 1 then
  begin
    Result := GetPasswoerter_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result := GetPasswoerter_Intern('');
  end;
  ResultToJSONContent(Result);
end;
// Passwörter übernehmen
function v1.AcceptSetPasswords(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 2 then
  begin
    metaData.ResponseCode:= 200;
    Result:= SetPasswoerter_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),StrToBool(StringReplace(metaData.QueryParams[1],'Test=','',[rfReplaceAll,rfIgnoreCase])), AJSONObject);
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result:= SetPasswoerter_Intern('',false,AJSONObject);
  end;
  ResultToJSONContent(Result);
end;
// Serials ermitteln
function v1.UpdateGetSerials: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 1 then
  begin
    Result := GetSerials_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result := GetSerials_Intern('');
  end;
  ResultToJSONContent(Result);
end;
// Serials übernehmen
function v1.AcceptSetSerials(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 2 then
  begin
    metaData.ResponseCode:= 200;
    Result:= SetSerials_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),StrToBool(StringReplace(metaData.QueryParams[1],'Test=','',[rfReplaceAll,rfIgnoreCase])), AJSONObject);
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result:= SetSerials_Intern('',false,AJSONObject);
  end;
  ResultToJSONContent(Result);
end;
// Ausgaben ermitteln
function v1.UpdateGetExpenditure: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 1 then
  begin
    Result := GetAusgaben_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result := GetAusgaben_Intern('');
  end;
  ResultToJSONContent(Result);
end;
// Ausgaben übernehmen
function v1.AcceptSetExpenditure(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 2 then
  begin
    metaData.ResponseCode:= 200;
    Result:= SetAusgaben_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),StrToBool(StringReplace(metaData.QueryParams[1],'Test=','',[rfReplaceAll,rfIgnoreCase])), AJSONObject);
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result:= SetAusgaben_Intern('',false,AJSONObject);
  end;
  ResultToJSONContent(Result);
end;
// Einnahmen ermitteln
function v1.UpdateGetReceipts: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 1 then
  begin
    Result := GetEinnahmen_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result := GetEinnahmen_Intern('');
  end;
  ResultToJSONContent(Result);
end;
// Einnahmen übernehmen
function v1.AcceptSetReceipts(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count = 2 then
  begin
    metaData.ResponseCode:= 200;
    Result:= SetEinnahmen_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),StrToBool(StringReplace(metaData.QueryParams[1],'Test=','',[rfReplaceAll,rfIgnoreCase])), AJSONObject);
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result:= SetEinnahmen_Intern('',false,AJSONObject);
  end;
  ResultToJSONContent(Result);
end;

end.

