object PCM_Restserver: TPCM_Restserver
  DisplayName = 'PCM-Restserver'
  AfterInstall = ServiceAfterInstall
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 651
  Width = 955
  object tmrServiceStart: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tmrServiceStartTimer
    Left = 560
    Top = 280
  end
  object FDManager: TFDManager
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 328
    Top = 16
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 200
    Top = 360
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 216
    Top = 416
  end
  object RESTClient1: TRESTClient
    Authenticator = HTTPBasicAuthenticator1
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://192.168.178.83:8081/PCM/api/v1/Refreshtoken'
    ContentType = 'application/x-www-form-urlencoded'
    Params = <>
    ConnectTimeout = 0
    ReadTimeout = 0
    SynchronizedEvents = False
    Left = 600
    Top = 440
  end
  object RESTRequest1: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTClient1
    Method = rmPUT
    Params = <>
    Response = RESTResponse1
    ConnectTimeout = 0
    ReadTimeout = 0
    SynchronizedEvents = False
    Left = 472
    Top = 488
  end
  object RESTResponse1: TRESTResponse
    ContentType = 'application/json'
    Left = 624
    Top = 528
  end
  object HTTPBasicAuthenticator1: THTTPBasicAuthenticator
    Username = 'JHenske'
    Password = 'Jh2019+1'
    Left = 736
    Top = 416
  end
end
