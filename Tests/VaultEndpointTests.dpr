program VaultEndpointTests;
{$APPTYPE CONSOLE}
uses System.SysUtils, System.JSON, Data.DBXPlatform,
 RESTServer.Service.Version.vers1, PCMService.WebModules;
var API: v1; Metadata: TDSInvocationMetadata; Response: TJSONObject;
procedure CheckDenied(const LabelText: string);
begin
 Response := API.GetPasswordVaultKey;
 try
  if (Metadata.ResponseCode <> 403) or (Response.GetValue('Key') <> nil) or
     (Response.GetValue('HasError').Value <> 'true') then
    raise Exception.Create('FAIL: ' + LabelText);
  Writeln('PASS: ' + LabelText);
 finally Response.Free; end;
end;
begin
 try
  Metadata := TDSInvocationMetadata.Create;
  SetInvocationMetadata(Metadata);
  API := v1.Create(nil);
  try
   VaultRequestUsesTLS := False;
   CheckDenied('request without verified TLS denied before database access');
   VaultRequestUsesTLS := True;
   Metadata.QueryParams.Add('ID_User=2');
   CheckDenied('foreign identity parameter denied before database access');
  finally
   API.Free;
   SetInvocationMetadata(nil);
   // SetInvocationMetadata owns and frees the old metadata.
  end;
 except on E: Exception do begin Writeln(E.ClassName, ': ', E.Message); Halt(1); end; end;
end.
