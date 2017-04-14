<#
  .SYNOPSYS
    csvグラフ化ツール
  .DESCRIPTION
    csvをグラフ化する
  .INPUTS
    - [n]csv        : csv
    - [o]out        : Excel保存先
    - [o]max        : Y軸MAX値
    - [o]min        : Y軸MIN値
  .OUTPUTS
    - グラフ化エクセル
  .Last Change : 2017/04/14 15:16:46.
#>
param(
  [string]$csv = (Read-Host "Enter csv path"),
  [string]$out,
  [string]$max,
  [string]$min
)

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue" # Continue SilentlyContinue Stop Inquire

# Excel const value.
$CONST = @{
  xlPasteAll =  -4104
  xlPasteAllExceptBorders =  7
  xlPasteColumnWidths =  8
  xlPasteComments =  -4144
  xlPasteFormats =  -4122
  xlPasteFormulas =  -4123
  xlPasteFormulasAndNumberFormats =  11
  xlPasteValidation =  6
  xlPasteValues =  -4163
  xlPasteValuesAndNumberFormats =  12
  xlExpression =  2
  xlCellValue =  1
  xlCategoryScale = 2
  xl24HourClock =  33
  xl3DArea =  -4098
  xl3DBar =  -4099
  xl3DColumn =  -4100
  xl3DEffects1 =  13
  xl3DEffects2 =  14
  xl3DLine =  -4101
  xl3DPie =  -4102
  xl3DSurface =  -4103
  xl4DigitYears =  43
  xlA1 =  1
  xlAbove =  1
  xlAbsRowRelColumn =  2
  xlAbsolute =  1
  xlAccounting1 =  4
  xlAccounting2 =  5
  xlAccounting3 =  6
  xlAccounting4 =  17
  xlAdd =  2
  xlAddIn =  18
  xlAll =  -4104
  xlAllAtOnce =  2
  xlAlternateArraySeparator =  16
  xlAnd =  1
  xlArea =  1
  xlAscending =  1
  xlAutoActivate =  3
  xlAutoClose =  2
  xlAutoDeactivate =  4
  xlAutoFill =  4
  xlAutoOpen =  1
  xlAutomatic =  -4105
  xlAutomaticUpdate =  4
  xlAverage =  -4106
  xlAxis =  21
  xlBIFF =  2
  xlBMP =  1
  xlBar =  2
  xlBelow =  1
  xlBitmap =  2
  xlBlanks =  4
  xlBoth =  1
  xlBottom =  -4107
  xlBuiltIn =  -4107
  xlButton =  15
  xlByColumns =  2
  xlByRows =  1
  xlCGM =  7
  xlCSV =  6
  xlCSVMSDOS =  24
  xlCSVMac =  22
  xlCSVWindows =  23
  xlCancel =  1
  xlCap =  1
  xlCascade =  7
  xlCategory =  1
  xlCenter =  -4108
  xlCenterAcrossSelection =  7
  xlChangeAttributes =  6
  xlChart =  -4109
  xlChart4 =  2
  xlChartAsWindow =  5
  xlChartInPlace =  4
  xlChartSeries =  17
  xlChartShort =  6
  xlChartTitles =  18
  xlChecker =  9
  xlChronological =  3
  xlCircle =  8
  xlClassic1 =  1
  xlClassic2 =  2
  xlClassic3 =  3
  xlClipboard =  3
  xlClipboardFormatBIFF =  8
  xlClipboardFormatBIFF2 =  18
  xlClipboardFormatBIFF3 =  20
  xlClipboardFormatBIFF4 =  30
  xlClipboardFormatBinary =  15
  xlClipboardFormatBitmap =  9
  xlClipboardFormatCGM =  13
  xlClipboardFormatCSV =  5
  xlClipboardFormatDIF =  4
  xlClipboardFormatDspText =  12
  xlClipboardFormatEmbedSource =  22
  xlClipboardFormatEmbeddedObjec =  21
  xlClipboardFormatLink =  11
  xlClipboardFormatLinkSource =  23
  xlClipboardFormatLinkSourceDes =  32
  xlClipboardFormatMovie =  24
  xlClipboardFormatNative =  14
  xlClipboardFormatObjectDesc =  31
  xlClipboardFormatObjectLink =  19
  xlClipboardFormatOwnerLink =  17
  xlClipboardFormatPICT =  2
  xlClipboardFormatPrintPICT =  3
  xlClipboardFormatRTF =  7
  xlClipboardFormatSYLK =  6
  xlClipboardFormatScreenPICT =  29
  xlClipboardFormatStandardFont =  28
  xlClipboardFormatStandardScale =  27
  xlClipboardFormatTable =  16
  xlClipboardFormatText =  16
  xlClipboardFormatToolFace =  25
  xlClipboardFormatToolFacePICT =  26
  xlClipboardFormatVALU =  1
  xlClipboardFormatWK1 =  10
  xlClosed =  3
  xlCodePage =  2
  xlColor1 =  7
  xlColor2 =  8
  xlColor3 =  9
  xlColumn =  3
  xlColumnField =  2
  xlColumnHeader =  -4110
  xlColumnItem =  5
  xlColumnSeparator =  14
  xlColumnThenRow =  2
  xlColumns =  2
  xlCombination =  -4111
  xlCommand =  2
  xlConsolidation =  3
  xlConstants =  2
  xlContents =  2
  xlContext =  -5002
  xlContinuous =  1
  xlCopy =  1
  xlCorner =  2
  xlCount =  -4112
  xlCountNums =  -4113
  xlCountryCode =  1
  xlCountrySetting =  2
  xlCrissCross =  16
  xlCross =  4
  xlCurrencyBefore =  37
  xlCurrencyCode =  25
  xlCurrencyDigits =  27
  xlCurrencyLeadingZeros =  40
  xlCurrencyMinusSign =  38
  xlCurrencyNegative =  28
  xlCurrencySpaceBefore =  36
  xlCurrencyTrailingZeros =  39
  xlCustom =  -4114
  xlCut =  2
  xlDBF2 =  7
  xlDBF3 =  8
  xlDBF4 =  11
  xlDIF =  9
  xlDRW =  4
  xlDXF =  5
  xlDash =  -4115
  xlDashDot =  4
  xlDashDotDot =  5
  xlDataField =  4
  xlDataHeader =  3
  xlDataItem =  7
  xlDatabase =  1
  xlDate =  2
  xlDateOrder =  32
  xlDateSeparator =  17
  xlDay =  1
  xlDayCode =  21
  xlDayLeadingZero =  42
  xlDebugCodePane =  13
  xlDecimalSeparator =  3
  xlDefaultAutoFormat =  -1
  xlDelimited =  1
  xlDescending =  2
  xlDesktop =  9
  xlDiagonalDown =  5
  xlDiagonalUp =  6
  xlDialogActivate =  103
  xlDialogActiveCellFont =  476
  xlDialogAddChartAutoformat =  390
  xlDialogAddinManager =  321
  xlDialogAlignment =  43
  xlDialogAppMove =  170
  xlDialogAppSize =  171
  xlDialogApplyNames =  133
  xlDialogApplyStyle =  212
  xlDialogArrangeAll =  12
  xlDialogAssignToObject =  213
  xlDialogAssignToTool =  293
  xlDialogAttachText =  80
  xlDialogAttachToolbars =  323
  xlDialogAttributes =  219
  xlDialogAxes =  78
  xlDialogBorder =  45
  xlDialogCalculation =  32
  xlDialogCellProtection =  46
  xlDialogChangeLink =  166
  xlDialogChartAddData =  392
  xlDialogChartTrend =  350
  xlDialogChartWizard =  288
  xlDialogCheckboxProperties =  435
  xlDialogClear =  52
  xlDialogColorPalette =  161
  xlDialogColumnWidth =  47
  xlDialogCombination =  73
  xlDialogConsolidate =  191
  xlDialogCopyChart =  147
  xlDialogCopyPicture =  108
  xlDialogCreateNames =  62
  xlDialogCreatePublisher =  217
  xlDialogCustomizeToolbar =  276
  xlDialogDataDelete =  36
  xlDialogDataLabel =  379
  xlDialogDataSeries =  40
  xlDialogDefineName =  61
  xlDialogDefineStyle =  229
  xlDialogDeleteFormat =  111
  xlDialogDeleteName =  110
  xlDialogDemote =  203
  xlDialogDisplay =  27
  xlDialogEditColor =  223
  xlDialogEditDelete =  54
  xlDialogEditSeries =  228
  xlDialogEditboxProperties =  438
  xlDialogEditionOptions =  251
  xlDialogErrorbarX =  463
  xlDialogErrorbarY =  464
  xlDialogExtract =  35
  xlDialogFileDelete =  6
  xlDialogFillGroup =  200
  xlDialogFillWorkgroup =  301
  xlDialogFilterAdvanced =  370
  xlDialogFindFile =  475
  xlDialogFont =  26
  xlDialogFontProperties =  381
  xlDialogFormatAuto =  269
  xlDialogFormatChart =  465
  xlDialogFormatCharttype =  423
  xlDialogFormatFont =  150
  xlDialogFormatLegend =  88
  xlDialogFormatMain =  225
  xlDialogFormatMove =  128
  xlDialogFormatNumber =  42
  xlDialogFormatOverlay =  226
  xlDialogFormatSize =  129
  xlDialogFormatText =  89
  xlDialogFormulaFind =  64
  xlDialogFormulaGoto =  63
  xlDialogFormulaReplace =  130
  xlDialogFunctionWizard =  450
  xlDialogGallery3dArea =  193
  xlDialogGallery3dBar =  272
  xlDialogGallery3dColumn =  194
  xlDialogGallery3dLine =  195
  xlDialogGallery3dPie =  196
  xlDialogGallery3dSurface =  273
  xlDialogGalleryArea =  67
  xlDialogGalleryBar =  68
  xlDialogGalleryColumn =  69
  xlDialogGalleryCustom =  388
  xlDialogGalleryDoughnut =  344
  xlDialogGalleryLine =  70
  xlDialogGalleryPie =  71
  xlDialogGalleryRadar =  249
  xlDialogGalleryScatter =  72
  xlDialogGoalSeek =  198
  xlDialogGridlines =  76
  xlDialogInsert =  55
  xlDialogInsertObject =  259
  xlDialogInsertPicture =  342
  xlDialogInsertTitle =  380
  xlDialogLabelProperties =  436
  xlDialogListboxProperties =  437
  xlDialogMacroOptions =  382
  xlDialogMailLogon =  339
  xlDialogMailNextLetter =  378
  xlDialogMainChart =  85
  xlDialogMainChartType =  185
  xlDialogMenuEditor =  322
  xlDialogMove =  262
  xlDialogNew =  119
  xlDialogNote =  154
  xlDialogObjectProperties =  207
  xlDialogObjectProtection =  214
  xlDialogOpen =  1
  xlDialogOpenLinks =  2
  xlDialogOpenMail =  188
  xlDialogOpenText =  441
  xlDialogOptionsCalculation =  318
  xlDialogOptionsChart =  325
  xlDialogOptionsEdit =  319
  xlDialogOptionsGeneral =  356
  xlDialogOptionsListsAdd =  458
  xlDialogOptionsTransition =  355
  xlDialogOptionsView =  320
  xlDialogOutline =  142
  xlDialogOverlay =  86
  xlDialogOverlayChartType =  186
  xlDialogPageSetup =  7
  xlDialogParse =  91
  xlDialogPasteSpecial =  53
  xlDialogPatterns =  84
  xlDialogPivotFieldGroup =  433
  xlDialogPivotFieldProperties =  313
  xlDialogPivotFieldUngroup =  434
  xlDialogPivotShowPages =  421
  xlDialogPivotTableWizard =  312
  xlDialogPlacement =  300
  xlDialogPrint =  8
  xlDialogPrintPreview =  222
  xlDialogPrinterSetup =  9
  xlDialogPromote =  202
  xlDialogProtectDocument =  28
  xlDialogPushbuttonProperties =  445
  xlDialogReplaceFont =  134
  xlDialogRoutingSlip =  336
  xlDialogRowHeight =  127
  xlDialogRun =  17
  xlDialogSaveAs =  5
  xlDialogSaveCopyAs =  456
  xlDialogSaveNewObject =  208
  xlDialogSaveWorkbook =  145
  xlDialogSaveWorkspace =  285
  xlDialogScale =  87
  xlDialogScenarioAdd =  307
  xlDialogScenarioCells =  305
  xlDialogScenarioEdit =  308
  xlDialogScenarioMerge =  473
  xlDialogScenarioSummary =  311
  xlDialogScrollbarProperties =  420
  xlDialogSelectSpecial =  132
  xlDialogSendMail =  189
  xlDialogSeriesAxes =  460
  xlDialogSeriesOrder =  466
  xlDialogSeriesX =  461
  xlDialogSeriesY =  462
  xlDialogSetControlValue =  455
  xlDialogSetPrintTitles =  23
  xlDialogSetUpdateStatus =  159
  xlDialogSheet =  -4116
  xlDialogShowDetail =  204
  xlDialogShowToolbar =  220
  xlDialogSize =  261
  xlDialogSort =  39
  xlDialogSortSpecial =  192
  xlDialogSplit =  137
  xlDialogStandardFont =  190
  xlDialogStandardWidth =  472
  xlDialogStyle =  44
  xlDialogSubscribeTo =  218
  xlDialogSubtotalCreate =  398
  xlDialogSummaryInfo =  474
  xlDialogTabOrder =  394
  xlDialogTable =  41
  xlDialogTextToColumns =  422
  xlDialogUnhide =  94
  xlDialogUpdateLink =  201
  xlDialogVbaInsertFile =  328
  xlDialogVbaMakeAddin =  478
  xlDialogVbaProcedureDefinition =  330
  xlDialogView3d =  197
  xlDialogWindowMove =  14
  xlDialogWindowSize =  13
  xlDialogWorkbookAdd =  281
  xlDialogWorkbookCopy =  283
  xlDialogWorkbookInsert =  354
  xlDialogWorkbookMove =  282
  xlDialogWorkbookName =  386
  xlDialogWorkbookNew =  302
  xlDialogWorkbookOptions =  284
  xlDialogWorkbookProtect =  417
  xlDialogWorkbookTabSplit =  415
  xlDialogWorkbookUnhide =  384
  xlDialogWorkgroup =  199
  xlDialogWorkspace =  95
  xlDialogZoom =  256
  xlDiamond =  2
  xlDifferenceFrom =  2
  xlDirect =  1
  xlDisabled =  1
  xlDistributed =  -4117
  xlDivide =  5
  xlDot =  -4118
  xlDouble =  -4119
  xlDoubleAccounting =  5
  xlDoubleClosed =  5
  xlDoubleOpen =  4
  xlDoubleQuote =  1
  xlDoughnut =  -4120
  xlDown =  -4121
  xlDownThenOver =  1
  xlDownward =  -4170
  xlDrawingObject =  14
  xlEdgeTop =  8
  xlEdgeLeft =  7
  xlEdgeRight =  10
  xlEdgeBottom =  9
  xlEPS =  8
  xlEditionDate =  2
  xlEntireChart =  20
  xlErrDiv0 =  2007
  xlErrNA =  2042
  xlErrName =  2029
  xlErrNull =  2000
  xlErrNum =  2036
  xlErrRef =  2023
  xlErrValue =  2015
  xlErrorHandler =  2
  xlErrors =  16
  xlExcel2 =  16
  xlExcel2FarEast =  27
  xlExcel3 =  29
  xlExcel4 =  33
  xlExcel4IntlMacroSheet =  4
  xlExcel4MacroSheet =  3
  xlExcel4Workbook =  35
  xlExcelLinks =  1
  xlExcelMenus =  1
  xlExponential =  5
  xlExtended =  2
  xlExternal =  2
  xlFill =  5
  xlFillCopy =  1
  xlFillDays =  5
  xlFillDefault =  5
  xlFillFormats =  3
  xlFillMonths =  7
  xlFillSeries =  2
  xlFillValues =  4
  xlFillWeekdays =  6
  xlFillYears =  8
  xlFilterCopy =  2
  xlFilterInPlace =  1
  xlFirst =  1
  xlFitToPage =  2
  xlFixedValue =  1
  xlFixedWidth =  2
  xlFloating =  5
  xlFloor =  23
  xlFormats =  -4122
  xlFormula =  5
  xlFormulas =  -4123
  xlFreeFloating =  3
  xlFullPage =  3
  xlFunction =  1
  xlGeneral =  1
  xlGeneralFormatName =  26
  xlGray16 =  17
  xlGray25 =  -4124
  xlGray50 =  -4125
  xlGray75 =  -4126
  xlGray8 =  18
  xlGrid =  15
  xlGridline =  22
  xlGrowth =  2
  xlGrowthTrend =  10
  xlGuess =  10
  xlHGL =  6
  xlHairline =  1
  xlHidden =  6
  xlHide =  3
  xlHigh =  -4127
  xlHorizontal =  -4128
  xlHourCode =  22
  xlIcons =  1
  xlImmediatePane =  12
  xlIndex =  9
  xlInfo =  -4129
  xlInside =  2
  xlInsideHorizontal =  12
  xlInsideVertical =  11
  xlInteger =  2
  xlInterpolated =  3
  xlInterrupt =  1
  xlIntlAddIn =  26
  xlIntlMacro =  25
  xlJustify =  -4130
  xlLandscape =  2
  xlLast =  1
  xlLastCell =  11
  xlLeft =  -4131
  xlLeftBrace =  12
  xlLeftBracket =  10
  xlLeftToRight =  2
  xlLegend =  24
  xlLightDown =  13
  xlLightHorizontal =  11
  xlLightUp =  14
  xlLightVertical =  12
  xlLine =  4
  xlLinear =  -4132
  xlLinearTrend =  9
  xlList1 =  10
  xlList2 =  11
  xlList3 =  12
  xlListSeparator =  5
  xlLocalFormat1 =  15
  xlLocalFormat2 =  16
  xlLogarithmic =  -4133
  xlLogical =  4
  xlLong =  3
  xlLotusHelp =  2
  xlLow =  -4134
  xlLowerCaseColumnLetter =  9
  xlLowerCaseRowLetter =  8
  xlMAPI =  1
  xlMDY =  44
  xlMSDOS =  3
  xlMacintosh =  1
  xlMacrosheetCell =  7
  xlManual =  -4135
  xlManualUpdate =  5
  xlMax =  -4136
  xlMaximized =  -4137
  xlMaximum =  2
  xlMedium =  -4138
  xlMetric =  35
  xlMicrosoftAccess =  4
  xlMicrosoftFoxPro =  5
  xlMicrosoftMail =  3
  xlMicrosoftPowerPoint =  2
  xlMicrosoftProject =  6
  xlMicrosoftSchedulePlus =  7
  xlMicrosoftWord =  1
  xlMin =  -4139
  xlMinimized =  -4140
  xlMinimum =  2
  xlMinusValues =  3
  xlMinuteCode =  23
  xlMixed =  2
  xlModule =  -4141
  xlMonth =  3
  xlMonthCode =  20
  xlMonthLeadingZero =  41
  xlMonthNameChars =  30
  xlMove =  2
  xlMoveAndSize =  1
  xlMovingAvg =  6
  xlMultiply =  4
  xlNarrow =  4
  xlNext =  1
  xlNextToAxis =  4
  xlNo =  2
  xlNoCap =  2
  xlNoDocuments =  3
  xlNoMailSystem =  3
  xlNonEnglishFunctions =  34
  xlNoncurrencyDigits =  29
  xlNone =  -4142
  xlNormal =  -4143
  xlNotPlotted =  1
  xlNotYetRouted =  1
  xlNotes =  -4144
  xlNumber =  -4145
  xlNumbers =  1
  xlOLEEmbed =  1
  xlOLELink =  1
  xlOLELinks =  2
  xlOff =  -4146
  xlOn =  1
  xlOneAfterAnother =  1
  xlOpaque =  3
  xlOpen =  2
  xlOpenSource =  3
  xlOr =  2
  xlOutside =  3
  xlOverThenDown =  2
  xlPCT =  13
  xlPCX =  10
  xlPIC =  11
  xlPICT =  1
  xlPLT =  12
  xlPageField =  3
  xlPageHeader =  2
  xlPageItem =  6
  xlPageBreakAutomatic =  -4105
  xlPageBreakFull =  1
  xlPageBreakManual =  -4135
  xlPageBreakNone =  -4142
  xlPageBreakPartial =  2
  xlPageBreakPreview =  2
  xlPaper10x14 =  16
  xlPaper11x17 =  17
  xlPaperA3 =  8
  xlPaperA4 =  9
  xlPaperA4Small =  10
  xlPaperA5 =  11
  xlPaperB4 =  12
  xlPaperB5 =  13
  xlPaperCsheet =  24
  xlPaperDsheet =  25
  xlPaperEnvelope10 =  20
  xlPaperEnvelope11 =  21
  xlPaperEnvelope12 =  22
  xlPaperEnvelope14 =  23
  xlPaperEnvelope9 =  19
  xlPaperEnvelopeB4 =  33
  xlPaperEnvelopeB5 =  34
  xlPaperEnvelopeB6 =  35
  xlPaperEnvelopeC3 =  29
  xlPaperEnvelopeC4 =  30
  xlPaperEnvelopeC5 =  28
  xlPaperEnvelopeC6 =  31
  xlPaperEnvelopeC65 =  32
  xlPaperEnvelopeDL =  27
  xlPaperEnvelopeItaly =  36
  xlPaperEnvelopeMonarch =  37
  xlPaperEnvelopePersonal =  38
  xlPaperEsheet =  26
  xlPaperExecutive =  7
  xlPaperFanfoldLegalGerman =  41
  xlPaperFanfoldStdGerman =  40
  xlPaperFanfoldUS =  39
  xlPaperFolio =  14
  xlPaperLedger =  4
  xlPaperLegal =  5
  xlPaperLetter =  1
  xlPaperLetterSmall =  2
  xlPaperNote =  18
  xlPaperQuarto =  15
  xlPaperStatement =  6
  xlPaperTabloid =  3
  xlPaperUser =  256
  xlPart =  2
  xlPercent =  2
  xlPercentDifferenceFrom =  4
  xlPercentOf =  3
  xlPercentOfColumn =  7
  xlPercentOfRow =  6
  xlPercentOfTotal =  8
  xlPicture =  -4147
  xlPie =  5
  xlPivotTable =  -4148
  xlPlaceholders =  2
  xlPlotArea =  19
  xlPlus =  9
  xlPlusValues =  2
  xlPolynomial =  3
  xlPortrait =  1
  xlPower =  4
  xlPrevious =  2
  xlPrimary =  1
  xlPrinter =  2
  xlPstringrintErrorBlank =  1
  xlPrintErrorDash =  2
  xlPrintErrorsDisplayed =  0
  xlPrintErrorsNA =  3
  xlPrintInPlace =  16
  xlPrintInSheetEnd =  1
  xlPrintNoComments =  -4142
  xlProduct =  -4149
  xlPublisher =  1
  xlPublishers =  5
  xlR1C1 =  -4150
  xlRTF =  4
  xlRadar =  -4151
  xlReadOnly =  3
  xlReadWrite =  2
  xlReference =  4
  xlRelRowAbsColumn =  3
  xlRelative =  4
  xlRight =  -4152
  xlRightBrace =  13
  xlRightBracket =  11
  xlRoutingComplete =  2
  xlRoutingInProgress =  1
  xlRowField =  1
  xlRowHeader =  -4153
  xlRowItem =  4
  xlRowSeparator =  15
  xlRowThenColumn =  1
  xlRows =  1
  xlRunningTotal =  5
  xlSYLK =  2
  xlScale =  3
  xlScreen =  1
  xlScreenSize =  1
  xlSecondCode =  24
  xlSecondary =  2
  xlSelect =  3
  xlSemiGray75 =  10
  xlSemiautomatic =  2
  xlSendPublisher =  2
  xlSeries =  3
  xlShort =  1
  xlShowLabel =  4
  xlShowLabelAndPercent =  5
  xlShowPercent =  3
  xlShowValue =  2
  xlSimple =  -4154
  xlSingle =  2
  xlSingleAccounting =  4
  xlSingleQuote =  2
  xlSolid =  1
  xlSortLabels =  2
  xlSortValues =  1
  xlSquare =  1
  xlStDev =  -4155
  xlStDevP =  -4156
  xlStError =  4
  xlStack =  2
  xlStandardSummary =  1
  xlStar =  5
  xlStretch =  1
  xlStrict =  2
  xlSubscriber =  2
  xlSubscribers =  6
  xlSubtract =  3
  xlSum =  -4157
  xlSyllabary =  1
  xlTIF =  9
  xlTableBody =  8
  xlTemplate =  17
  xlText =  -4158
  xlTextBox =  16
  xlTextMSDOS =  21
  xlTextMac =  19
  xlTextPrinter =  36
  xlTextValues =  2
  xlTextWindows =  20
  xlThick =  4
  xlThin =  2
  xlThousandsSeparator =  4
  xlTiled =  1
  xlTimeLeadingZero =  45
  xlTimeSeparator =  18
  xlTitleBar =  8
  xlToLeft =  -4159
  xlToRight =  -4161
  xlToolbar =  1
  xlToolbarButton =  2
  xlTop =  -4160
  xlTopToBottom =  1
  xlTransparent =  2
  xlTriangle =  3
  xlUp =  -4162
  xlUpdateState =  1
  xlUpdateSubscriber =  2
  xlUpperCaseColumnLetter =  7
  xlUpperCaseRowLetter =  6
  xlUpward =  -4171
  xlUnderlineStyleDouble =  -4119
  xlUnderlineStyleDoubleAccounting =  5
  xlUnderlineStyleNone =  -4142
  xlUnderlineStyleSingle =  2
  xlUnderlineStyleSingleAccounting =  4
  xlVALU =  8
  xlValue =  2
  xlValues =  -4163
  xl =  -4164
  xlVarP =  -4165
  xlVertical =  -4166
  xlVeryHidden =  2
  xlVisible =  12
  xlWJ2WD1 =  14
  xlWK1 =  5
  xlWK1ALL =  31
  xlWK1FMT =  30
  xlWK3 =  15
  xlWK3FM3 =  32
  xlWKS =  4
  xlWMF =  2
  xlWPG =  3
  xlWQ1 =  34
  xlWatchPane =  11
  xlWeekday =  2
  xlWeekdayNameChars =  31
  xlWhole =  1
  xlWide =  3
  xlWindows =  2
  xlWorkbook =  1
  xlWorkbookTab =  6
  xlWorks2FarEast =  28
  xlWorksheet =  -4167
  xlWorksheet4 =  1
  xlWorksheetCell =  3
  xlWorksheetShort =  5
  xlX =  -4168
  xlXYScatter =  -4169
  xlY =  1
  xlYear =  4
  xlYearCode =  19
  xlYes =  1
  xlZero =  2
  msoTextBox =  17
  msoTrue =  -1
  msoFalse =  0
  msoAutoSizeShapeToFitText = 1
  msoElementLegendBottom = 104
  msoElementLegendLeft = 103
  msoElementLegendLeftOverlay = 106
  msoElementLegendNone = 100
  msoElementLegendRight = 101
  msoElementLegendRightOverlay = 105
  msoElementLegendTop = 102
}

<#
  .SYNOPSYS
    Init処理
  .DESCRIPTION
    Init処理を実行する
  .INPUTS
    - なし
  .OUTPUTS
    - なし
#>
function Start-Init {

  [CmdletBinding()]
  [OutputType([void])]
  param()
  trap { Write-Host "[Start-Init] Error $_"; throw $_ }

  # アセンブリロード
  Add-Type -Assembly Microsoft.VisualBasic
  # App Obj準備
  $script:app = @{}

  $cmdFullPath = & {
    if ($env:scriptPath) {
      return [System.IO.Path]::GetFullPath($env:scriptPath)
    } else {
      return [System.IO.Path]::GetFullPath($script:MyInvocation.MyCommand.Path)
    }
  }
  $app.Add("cmdFile", $cmdFullPath)
  $app.Add("cmdDir", [System.IO.Path]::GetDirectoryName($app.cmdFile))
  $app.Add("cmdName", [System.IO.Path]::GetFileNameWithoutExtension($app.cmdFile))
  $app.Add("cmdFileName", [System.IO.Path]::GetFileName($app.cmdFile))

  # 実行ディレクトリ
  $app.Add("pwd", [System.IO.Path]::GetFullPath((Get-Location).Path))
  # プロセスID
  $app.Add("pId", $PID)
  # スレッドID
  $app.Add("threadId", [System.Threading.Thread]::CurrentThread.ManagedThreadId)

  # csv情報
  $app.Add("csv", $csv)
  # Y軸max値
  $max = & { if (![string]::IsNullOrEmpty($max)) { [long]$max } else { $null } }
  $app.Add("max", $max)
  # Y軸min値
  $min = & { if (![string]::IsNullOrEmpty($min)) { [long]$min } else { $null } }
  $app.Add("min", $min)
  # 保存Excel名
  if ($app.csv -notmatch "\\") {
    $app.csv = Join-Path $app.pwd $app.csv
  }
  $csvDir = [System.IO.Path]::GetDirectoryName($app.csv)
  $outExcel = Join-Path $csvDir ($app.cmdName + ".xlsx")
  $out = & { if (![string]::IsNullOrEmpty($out)) { $out } else { $outExcel } }
  $app.Add("out", [System.IO.Path]::GetFullPath($out))

  # 戻り値設定
  $app.Add("const", @{
    SUCCESS = 0
    WARN = 1
    ERROR = 2
  })

  # 戻り値初期値
  $app.Add("result", $app.const.ERROR)

  Write-Host "[Start-Init] 処理を開始します。"
  Write-Host "[Start-Init] 入力csv              : [$($app.csv)]"
  Write-Host "[Start-Init] Excel保存先          : [$($app.out)]"
  Write-Host "[Start-Init] Y軸Max値             : [$($app.max)]"
  Write-Host "[Start-Init] Y軸min値             : [$($app.min)]"

}

<#
  .SYNOPSYS
    Main処理
  .DESCRIPTION
    Main処理を実行する
  .INPUTS
    - なし
  .OUTPUTS
    - 処理結果 - 0(正常終了), 1(警告終了), 2(異常終了)
#>
function Start-Main {

  [CmdletBinding()]
  [OutputType([int])]
  param()

  try {

    # 開始時間計測
    $startTime = Get-Date

    # Init処理実行
    Start-Init

    # 現在日時
    $now = Get-Date -Format "yyyyMMddHHmmss"

    # Init excel object.
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.Application.DisplayAlerts = $false
    $excel.Application.ReferenceStyle = $CONST.xlR1C1

    # csv展開
    Get-ChildItem $app.csv | % {

      $csv = Get-FilePathInfo $_.FullName

      # グラフ化する
      Write-Debug "グラフ化開始"
      $book = $excel.Workbooks.Add()

      # csv読み込み
      Write-Host "[$($csv.full)]を読み込みます..."

      $dws = $book.Worksheets.Item(1)
      Write-Debug "CSVをExcelに読み込み"
      $table = $dws.QueryTables.Add("TEXT;$($csv.full)", $dws.Cells.Item(1, 1))
      $table.Name = $csv.name
      $table.TextFileParseType = $CONST.xlDelimited
      $table.TextFileCommaDelimiter = $true
      # $table.TextFileTabDelimiter = $true
      $table.Refresh()
      $table.Delete()

      $maxRow = $dws.Cells.Item($dws.Rows.Count, 1).End($CONST.xlUp).Row
      $maxCol = $dws.Cells.Item(1, $dws.Columns.Count).End($CONST.xlToLeft).Column

      # グラフ化
      Write-Host "[$($csv.name)]をグラフ化します..."
      $chart = $book.Charts.Add($dws)
      $chart.SetSourceData($dws.Range($dws.Cells.Item(1, 1), $dws.Cells.Item($maxRow, $maxCol)))
      $chart.ChartType = $CONST.xlLine

      # Y軸maxの指定があれば設定
      if ($app.max -ne $null) {
        Write-Host "Y軸MAX値を[$($app.max)]に設定します"
        $chart.Axes($CONST.xlValue).MaximumScale = $app.max
      }
      # Y軸minの指定があれば設定
      if ($app.min -ne $null) {
        Write-Host "Y軸MIN値を[$($app.min)]に設定します"
        $chart.Axes($CONST.xlValue).MinimumScale = $app.min
      }
      # なぜか変数だとエラーになる・・・
      # $chart.SetElement($CONST.msoElementLegendBottom)
      # $chart.SetElement($CONST.msoElementLegendRight)
      $chart.SetElement(101)
      $chart.HasTitle = $true
      Write-Host "グラフタイトルを[$($csv.name)]に設定します"
      $chart.ChartTitle.Text = $csv.name

      # Change font size.
      $chart.Legend.Format.TextFrame2.TextRange.Font.Size = 7
    }

    # 保存
    New-Item -Force -ItemType Directory (Split-Path -Parent $app.out) > $null
    Write-Host "[$($app.out)]へ保存します。"
    $book.SaveAs($app.out)

    $app.result = $app.const.SUCCESS

  } catch {
    Write-Host "Error ! [$_]"
  } finally {
    Write-Host "処理を終了します。ExitCode: [$($app.result)]"
    # 終了時間計測
    $endTime = Get-Date
    $span = $endTime - $startTime
    Write-Host ("処理時間: {0} {1:00}:{2:00}:{3:00}.{4:000}" -f $span.Days, $span.Hours, $span.Minutes, $span.Seconds, $span.Milliseconds)
    $app.result
    if ($excel) {
      $excel.Quit()
    }
  }
}

<#
  .SYNOPSYS
    ファイル情報取得
  .DESCRIPTION
    ファイルパスからファイル名、ディレクトリ名などを取得する
  .INPUTS
    - ファイルパス
  .OUTPUTS
    - ファイルパス情報
#>
function Get-FilePathInfo {

  [CmdletBinding()]
  [OutputType([object])]
  param([string]$path)
  trap { Write-Host "[Get-FilePathInfo] Error [$_]"; throw $_ }

  $full = [System.IO.Path]::GetFullPath($path)
  
  return New-Object PSObject -Property @{
    full = $full
    dir = [System.IO.Path]::GetDirectoryName($full)
    file = [System.IO.Path]::GetFileName($full)
    name = [System.IO.Path]::GetFileNameWithoutExtension($full)
  }
}

# Call main.
exit Start-Main

