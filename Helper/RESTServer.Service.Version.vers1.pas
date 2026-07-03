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
    // TimeAPP - RESTfunktionen                                               //
    ////////////////////////////////////////////////////////////////////////////
    {$Region TimeAPP-API}
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetContactsZE: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetLastBooking: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetLastBooking(const AJSONObject: TJSONObject): TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetBookingYear: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetAbsenceconfig: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetAbsence: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetOnlineBooking(const AJSONObject: TJSONObject): TJSonObject;


//    [TRoleAuth('WebAPI_PCM')]
//    function GetMonthValues(AID_Benutzer: Integer): TDataset;
    {$EndRegion TimeAPP-API}
    ////////////////////////////////////////////////////////////////////////////
    // Web-APP - RESTfunktionen                                               //
    ////////////////////////////////////////////////////////////////////////////
    {$Region Web-APP-API}
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetLogin: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetEmployee: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetBookingData: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetMonthYearValues: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetFehltage: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetFeiertage: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetLastBook: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetLastBook(const AJSONObject: TJSONObject): TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetOnlineBook: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetOnlineBook(const AJSONObject: TJSONObject): TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateCalcMonth: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetAbsenceDays: TJSonObject;
    {$EndRegion Web-APP-API}
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
    function CheckLoginTime: TJSonObject;
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
  PCMService.API.Methods,
  PCMService.WebModules;
  {$EndRegion Uses}
////////////////////////////////////////////////////////////////////////////////
// Hilfsfunktionen                                                            //
////////////////////////////////////////////////////////////////////////////////
{$Region Hilfsfunktionen}
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
{$Region Server_Login}
function v1.CheckServer: TJSonObject;
begin
  Result:= CheckServer_Intern;
  ResultToJSONContent(Result);
end;
function v1.CheckLogin: TJSonObject;
begin
  Result:= CheckLogin_Intern;
  ResultToJSONContent(Result);
end;
function v1.CheckLoginTime: TJSonObject;
begin
  Result:= CheckLoginTime_Intern;
  ResultToJSONContent(Result);
end;
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
{$Region Kontakte}
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
      Result:= SetKontakte_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetKontakte_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetKontakte_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Kontakte}
{$Region Kalender}
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
function v1.AcceptSetCalendar(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 2 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetKalender_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        StrTobool(StringReplace(metaData.QueryParams[1],'test=','',[rfReplaceAll,rfIgnoreCase])),
        AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetKalender_Intern('',false,AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Kalender}
{$Region Passwords}
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
      Result:= SetPasswoerter_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetPasswoerter_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetPasswoerter_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Passwords}
{$Region Serials}
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
      Result:= SetSerials_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetSerials_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetSerials_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$ENdRegion Serials}
{$Region Einnahmen}
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
      Result:= SetEinnahmen_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetEinnahmen_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetEinnahmen_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Einnahmen}
{$Region Ausgaben}
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
      Result:= SetAusgaben_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetAusgaben_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetAusgaben_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Ausgaben}
{$Region Belege}
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
      Result:= SetVouchers_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetVouchers_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetVouchers_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Belege}
{$Region Gutscheine}
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
      Result:= SetGiftCards_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetGiftCards_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetGiftCards_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Gutscheine}
{$EndRegion APP-Api}
{$Region TimeAPP-Api}
function v1.UpdateGetContactsZE: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserApp then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetContactsZE_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetContactsZE_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetLastBooking: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserApp then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetLastBooking_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
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
function v1.AcceptSetLastBooking(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetLastBooking_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetLastBooking_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetLastBooking_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
function v1.UpdateGetBookingYear: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserApp then
  begin
    if metaData.QueryParams.Count = 2 then
    begin
      Result := GetBookingYear_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),StringReplace(metaData.QueryParams[1],'Year=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetBookingYear_Intern('','');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetAbsenceconfig: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserApp then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetAbsenceconfig_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetAbsenceconfig_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetAbsence: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserApp then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetAbsence_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetAbsence_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetOnlineBooking(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetOnlineBooking_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetOnlineBooking_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetOnlineBooking_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion TimeAPP-Api}
////////////////////////////////////////////////////////////////////////////////
// Web-APP - RESTfunktionen                                                   //
////////////////////////////////////////////////////////////////////////////////
function v1.UpdateGetLogin: TJSonObject;
begin
  Result:= GetLoginWeb_Intern;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetEmployee: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetPersonalWeb_intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetPersonalWeb_intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetBookingData: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetBookinDataWeb_intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetBookinDataWeb_intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetMonthYearValues: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 3 then
    begin
      Result := GetMonthYearValuesWeb_intern(
      StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
      StrToint(StringReplace(metaData.QueryParams[1],'Month=','',[rfReplaceAll,rfIgnoreCase])),
      StrToint(StringReplace(metaData.QueryParams[2],'Year=','',[rfReplaceAll,rfIgnoreCase])));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetMonthYearValuesWeb_intern('',0,0);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetFehltage: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetFehltageWeb_intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetFehltageWeb_intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetFeiertage: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetFeiertageWeb_intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetFeiertageWeb_intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetLastBook: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetLastBookingWeb_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetLastBookingWeb_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetLastBook(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetLastBookingWeb_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetLastBookingWeb_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetLastBookingWeb_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
function v1.UpdateGetOnlineBook: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetBookingWeb_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetBookingWeb_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetOnlineBook(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetOnlineBookingWeb_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetOnlineBookingWeb_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetOnlineBookingWeb_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
function v1.UpdateCalcMonth: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 3 then
    begin
      Result := CalcBookingWeb_Intern(
      StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
      StrToint(StringReplace(metaData.QueryParams[1],'Month=','',[rfReplaceAll,rfIgnoreCase])),
      StrToint(StringReplace(metaData.QueryParams[2],'Year=','',[rfReplaceAll,rfIgnoreCase])));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := CalcBookingWeb_Intern('',0,0);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetAbsenceDays: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 3 then
    begin
      Result := GetAbsenceWeb_intern(
      StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
      StrToint(StringReplace(metaData.QueryParams[1],'Month=','',[rfReplaceAll,rfIgnoreCase])),
      StrToint(StringReplace(metaData.QueryParams[2],'Year=','',[rfReplaceAll,rfIgnoreCase])));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetAbsenceWeb_intern('',0,0);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;


end.

