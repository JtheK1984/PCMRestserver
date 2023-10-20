object webPCMModul: TwebPCMModul
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = WebModule1DefaultHandlerAction
    end>
  BeforeDispatch = WebModuleBeforeDispatch
  Height = 333
  Width = 414
  object wdispAuth: TDSHTTPWebDispatcher
    DSContext = 'PCM/'
    RESTContext = 'Sandbox/'
    Server = DSServer1
    Filters = <>
    AuthenticationManager = authMngr
    WebDispatch.PathInfo = 'PCM/Sandbox/v0*'
    Left = 88
    Top = 67
  end
  object authMngr: TDSAuthenticationManager
    OnUserAuthenticate = authMngrUserAuthenticate
    Roles = <>
    Left = 88
    Top = 123
  end
  object dsSrvClassAuth: TDSServerClass
    OnGetClass = dsSrvClassAuthGetClass
    Server = DSServer1
    Left = 104
    Top = 11
  end
  object wdispService: TDSHTTPWebDispatcher
    DSContext = 'PCM/'
    RESTContext = 'sandbox-api/'
    Server = DSServer1
    Filters = <>
    AuthenticationManager = authMngr
    WebDispatch.PathInfo = 'PCM/sandbox-api*'
    Left = 184
    Top = 67
  end
  object dsSrvClassService_V1: TDSServerClass
    OnGetClass = dsSrvClassService_V1GetClass
    Server = DSServer1
    Left = 184
    Top = 11
  end
  object wdispServiceHTTPS: TDSHTTPWebDispatcher
    DSContext = 'PCM/'
    RESTContext = 'api/'
    Server = DSServer1
    Filters = <>
    AuthenticationManager = authMngr
    WebDispatch.PathInfo = 'PCM/api*'
    Left = 248
    Top = 67
  end
  object DSServer1: TDSServer
    Left = 24
    Top = 11
  end
end
