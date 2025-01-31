unit RESTServer.Service.Version.vers1;

interface

uses
  {$Region Uses}
  WinApi.Windows,
  System.SysUtils,
  System.Classes,
  System.JSON,
  REST.JSON,
  Data.DB,
  Data.DBXCommon,
  Data.DBXPlatform,
  Datasnap.DSAuth,
  DataSnap.DSProviderDataModuleAdapter,
  Datasnap.DSServer,
  DataSnap.DSSession,
  IdBaseComponent,
  IdHash,
  IdHashCRC,
  IdHashMessageDigest,
  IdHashSHA,
  IdSASL,
  IdSASL_CRAMBase,
  IdSASL_CRAM_MD5,
  IdSASLUserPass,
  RESTServer.Service.Records;
  {$EndRegion Uses}
{$DEFINE PCMService}
type
  {$Region Type}
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
    {$Region Rest-API}
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
    {$EndRegion Rest-API}
    ////////////////////////////////////////////////////////////////////////////
    // APP - RESTfunktionen                                                   //
    ////////////////////////////////////////////////////////////////////////////
    {$Region APP-API}
    // Login ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function CheckServer: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function CheckLogin: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetDeviceID(const AJSONObject: TJSONObject): TJSonObject;
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
    // Belege ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetVouchers: TJSONObject;
    // Belege übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetVouchers(const AJSONObject: TJSONObject): TJSONObject;
    // Gutscheine ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetGiftCards: TJSONObject;
    // Gutscheine übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetGiftCards(const AJSONObject: TJSONObject): TJSONObject;
    {$EndRegion APP-API}
  end;
  {$METHODINFO OFF}
  {$EndRegion Type}
implementation

uses
  {$Region Uses}
  PCM.Data,
  PCM.Functions,
  PCMService.API.Methods,
  PCMService.WebModules;
  {$EndRegion Uses}
////////////////////////////////////////////////////////////////////////////////
// Hilfsfunktionen                                                            //
////////////////////////////////////////////////////////////////////////////////
{$Region Hilfsfunktionen}
  // Ergebnis in JSON umwandeln
procedure v1.ResultToJSONContent(const AJSONObject: TJSONObject);
var
  metaData: TDSInvocationMetadata;
begin
  metaData:= GetInvocationMetadata;
  metaData.ResponseContentType := 'application/json; charset=utf-8';
  metaData.ResponseContent := AJSONObject.ToJSON;
end;
{$EndRegion Hilfsfunktionen}
////////////////////////////////////////////////////////////////////////////////
// PCM - RESTfunktionen                                                       //
////////////////////////////////////////////////////////////////////////////////
{$Region Web-Api}
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
{$EndRegion Web-Api}
////////////////////////////////////////////////////////////////////////////////
// APP - RESTfunktionen                                                       //
////////////////////////////////////////////////////////////////////////////////
{$Region APP-Api}
// Server und Login Prüfen
{$Region Server_Login}
function v1.CheckServer: TJSonObject;
begin
  Result:= CheckServer_Intern;
  ResultToJSONContent(Result);
end;
// Login prüfen
function v1.CheckLogin: TJSonObject;
begin
  Result:= CheckLogin_Intern;
  ResultToJSONContent(Result);
end;
// Token übernehmen
function v1.acceptSetDeviceID(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    metaData.ResponseCode:= 200;
    Result:= SetDeviceID_intern(AJSONObject);
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$ENdRegion Server_Login}
// Kontakte
{$Region Kontakte}
// Kontakte ermitteln
function v1.UpdateGetContacts: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetKontakte_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetKontakte_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
// Kontakte übernhmen
function v1.acceptSetContacts(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetKontakte_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]), AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetKontakte_Intern('',AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Kontakte}
// Kalender
{$Region Kalender}
// Kalender ermitteln
function v1.UpdateGetCalendar: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetKalender_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetKalender_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
// Kalender übernehmen
function v1.AcceptSetCalendar(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetKalender_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]), AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetKalender_Intern('',AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Kalender}
// Passwörter
{$Region Passwords}
// Passwörter ermitteln
function v1.UpdateGetPasswords: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetPasswoerter_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetPasswoerter_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
// Passwörter übernehmen
function v1.AcceptSetPasswords(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetPasswoerter_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]), AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetPasswoerter_Intern('',AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Passwords}
// Serials
{$Region Serials}
// Serials ermitteln
function v1.UpdateGetSerials: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetSerials_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetSerials_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
// Serials übernehmen
function v1.AcceptSetSerials(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetSerials_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]), AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetSerials_Intern('',AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$ENdRegion Serials}
// Einnahmen
{$Region Einnahmen}
// Einnahmen ermitteln
function v1.UpdateGetReceipts: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetEinnahmen_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetEinnahmen_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
// Einnahmen übernehmen
function v1.AcceptSetReceipts(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetEinnahmen_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]), AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetEinnahmen_Intern('',AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Einnahmen}
// Ausgaben
{$Region Ausgaben}
// Ausgaben ermitteln
function v1.UpdateGetExpenditure: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetAusgaben_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetAusgaben_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
// Ausgaben übernehmen
function v1.AcceptSetExpenditure(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetAusgaben_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]), AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetAusgaben_Intern('',AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Ausgaben}
// Belege
{$Region Belege}
// Belege ermitteln
function v1.UpdateGetVouchers: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetVouchers_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetVouchers_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
// Belege übernehmen
function v1.AcceptSetVouchers(const AJSONObject: TJSONObject): TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetVouchers_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]), AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetVouchers_Intern('',AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Belege}
// Gutscheine
{$Region Gutscheine}
// Gutscheine ermitteln
function v1.UpdateGetGiftCards: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetGiftCards_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetGiftCards_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
// Gutscheine übernehmen
function v1.AcceptSetGiftCards(const AJSONObject: TJSONObject): TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetGiftCards_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]), AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetGiftCards_Intern('',AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Gutscheine}
{$EndRegion APP-Api}
end.

