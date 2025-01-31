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
end
