unit RESTServer.Service.Records;

interface

type
  {$Region Type}
  TRESTServerConfig = record
    Port_HTTP: Integer;
    Port_HTTPS: Integer;
    TokenTimeout: Integer;
    SSL_PublicKey: String;
    SSL_PrivateKey: String;
    SSL_CA_Key: String;
    RestSwagger: boolean;
    procedure Init;
    procedure LoadData;
  end;

  TPCMTokenData = record
    ID_MA: Integer;
    PrgNr: Integer;
    procedure Init;
  end;
  {$EndRegion Type}
implementation

uses
  {$Region Uses}
  System.IniFiles,
  System.SysUtils;
  {$EndRegion Type}
////////////////////////////////////////////////////////////////////////////////
// Config                                                                     //
////////////////////////////////////////////////////////////////////////////////
{$Region Config}
procedure TRESTServerConfig.Init;
begin
  Self := Default(TRESTServerConfig);
end;
procedure TRESTServerConfig.LoadData;
var
  iniRESTServer: TIniFile;
  sIniFile: String;
begin
  sIniFile := ExtractFilePath(ParamStr(0)) + 'PCMRestserver.ini';
  iniRESTServer := TIniFile.Create(sIniFile);
//  ZMIDebugMsg('Ini suchen: ' + sIniFile);
  try
    if FileExists(sIniFile) then
    begin
//      ZMIDebugMsg('Ini laden in: ' + sIniFile);
      Self.Port_HTTP := iniRESTServer.ReadInteger('Config', 'Port_HTTP', 8081);
      Self.Port_HTTPS := iniRESTServer.ReadInteger('Config', 'Port_HTTPS', 5443);
      Self.TokenTimeout := iniRESTServer.ReadInteger('Config', 'TokenTimeout', 60);
      Self.RestSwagger:= iniRESTServer.ReadBool('Config', 'Swagger', false);
      Self.SSL_PublicKey := iniRESTServer.ReadString('Zertifikate', 'PublicKey', 'c:\Windows\PCMapp.pem');
      Self.SSL_PrivateKey := iniRESTServer.ReadString('Zertifikate', 'PrivateKey', 'c:\Windows\PCMapp.key');
      Self.SSL_CA_Key := iniRESTServer.ReadString('Zertifikate', 'CA_Key', '');
    end
    else
    begin
      iniRESTServer.WriteInteger('Config', 'Port_HTTP', 8081);
      iniRESTServer.WriteInteger('Config', 'Port_HTTPS', 5443);
      iniRESTServer.WriteInteger('Config', 'TokenTimeout', 60);
      iniRESTServer.WriteBool('Config', 'Swagger', false);
      iniRESTServer.WriteString('Zertifikate', 'PublicKey', 'c:\Windows\PCMapp.pem');
      iniRESTServer.WriteString('Zertifikate', 'PrivateKey', 'c:\Windows\PCMapp.key');
      iniRESTServer.WriteString('Zertifikate', 'CA_Key', '');

    end;
  finally
    iniRESTServer.Free;
  end;

end;
{$EndRegion Config}
////////////////////////////////////////////////////////////////////////////////
// Token                                                                      //
////////////////////////////////////////////////////////////////////////////////
{$Region Token}
procedure TPCMTokenData.Init;
begin
  Self := Default(TPCMTokenData);
end;
{$EndRegion Token}
end.
