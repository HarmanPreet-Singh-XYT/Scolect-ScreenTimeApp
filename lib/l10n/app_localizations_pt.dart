// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appWindowTitle =>
      'Scolect - Rastrear Tempo de Tela e Uso de Aplicativos';

  @override
  String get appName => 'Scolect';

  @override
  String get appTitle => 'Tempo de Tela Produtivo';

  @override
  String get sidebarTitle => 'Tempo de Tela';

  @override
  String get sidebarSubtitle => 'Código Aberto';

  @override
  String get trayShowWindow => 'Mostrar Janela';

  @override
  String get trayStartFocusMode => 'Iniciar Modo Foco';

  @override
  String get trayStopFocusMode => 'Parar Modo Foco';

  @override
  String get trayReports => 'Relatórios';

  @override
  String get trayAlertsLimits => 'Alertas e Limites';

  @override
  String get trayApplications => 'Aplicativos';

  @override
  String get trayDisableNotifications => 'Desativar Notificações';

  @override
  String get trayEnableNotifications => 'Ativar Notificações';

  @override
  String get trayVersionPrefix => 'Versão: ';

  @override
  String trayVersion(String version) {
    return 'Versão: $version';
  }

  @override
  String get trayExit => 'Sair';

  @override
  String get navOverview => 'Visão Geral';

  @override
  String get navApplications => 'Aplicativos';

  @override
  String get navAlertsLimits => 'Alertas e Limites';

  @override
  String get navReports => 'Relatórios';

  @override
  String get navFocusMode => 'Modo Foco';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navHelp => 'Ajuda';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get faqCategoryGeneral => 'Perguntas Gerais';

  @override
  String get faqCategoryApplications => 'Gerenciamento de Aplicativos';

  @override
  String get faqCategoryReports => 'Análises e Relatórios de Uso';

  @override
  String get faqCategoryAlerts => 'Alertas e Limites';

  @override
  String get faqCategoryFocusMode => 'Modo Foco e Timer Pomodoro';

  @override
  String get faqCategorySettings => 'Configurações e Personalização';

  @override
  String get faqCategoryTroubleshooting => 'Solução de Problemas';

  @override
  String get faqGeneralQ1 => 'Como este aplicativo rastreia o tempo de tela?';

  @override
  String get faqGeneralA1 =>
      'O aplicativo monitora o uso do seu dispositivo em tempo real, rastreando o tempo gasto em diferentes aplicativos. Ele fornece insights abrangentes sobre seus hábitos digitais, incluindo tempo total de tela, tempo produtivo e uso específico de aplicativos.';

  @override
  String get faqGeneralQ2 => 'O que torna um aplicativo \'Produtivo\'?';

  @override
  String get faqGeneralA2 =>
      'Você pode marcar manualmente aplicativos como produtivos na seção \'Aplicativos\'. Aplicativos produtivos contribuem para sua Pontuação de Produtividade, que calcula a porcentagem do tempo de tela gasto em aplicativos relacionados ao trabalho ou benéficos.';

  @override
  String get faqGeneralQ3 => 'Quão preciso é o rastreamento do tempo de tela?';

  @override
  String get faqGeneralA3 =>
      'O aplicativo usa rastreamento em nível de sistema para fornecer medição precisa do uso do seu dispositivo. Ele captura o tempo em primeiro plano para cada aplicativo com impacto mínimo na bateria.';

  @override
  String get faqGeneralQ4 =>
      'Posso personalizar a categorização dos meus aplicativos?';

  @override
  String get faqGeneralA4 =>
      'Com certeza! Você pode criar categorias personalizadas, atribuir aplicativos a categorias específicas e modificar facilmente essas atribuições na seção \'Aplicativos\'. Isso ajuda a criar análises de uso mais significativas.';

  @override
  String get faqGeneralQ5 => 'Quais insights posso obter deste aplicativo?';

  @override
  String get faqGeneralA5 =>
      'O aplicativo oferece insights abrangentes incluindo Pontuação de Produtividade, padrões de uso por hora do dia, uso detalhado de aplicativos, rastreamento de sessões de foco e análises visuais como gráficos e diagramas de pizza para ajudá-lo a entender e melhorar seus hábitos digitais.';

  @override
  String get faqAppsQ1 =>
      'Como oculto aplicativos específicos do rastreamento?';

  @override
  String get faqAppsA1 =>
      'Na seção \'Aplicativos\', você pode alternar a visibilidade dos aplicativos.';

  @override
  String get faqAppsQ2 => 'Posso pesquisar e filtrar meus aplicativos?';

  @override
  String get faqAppsA2 =>
      'Sim, a seção Aplicativos inclui funcionalidade de pesquisa e opções de filtragem. Você pode filtrar aplicativos por categoria, status de produtividade, status de rastreamento e visibilidade.';

  @override
  String get faqAppsQ3 =>
      'Quais opções de edição estão disponíveis para aplicativos?';

  @override
  String get faqAppsA3 =>
      'Para cada aplicativo, você pode editar: atribuição de categoria, status de produtividade, rastreamento de uso, visibilidade em relatórios e definir limites de tempo diários individuais.';

  @override
  String get faqAppsQ4 => 'Como as categorias de aplicativos são determinadas?';

  @override
  String get faqAppsA4 =>
      'As categorias iniciais são sugeridas pelo sistema, mas você tem controle total para criar, modificar e atribuir categorias personalizadas com base em seu fluxo de trabalho e preferências.';

  @override
  String get faqReportsQ1 => 'Quais tipos de relatórios estão disponíveis?';

  @override
  String get faqReportsA1 =>
      'Os relatórios incluem: Tempo total de tela, Tempo produtivo, Aplicativos mais usados, Sessões de foco, Gráfico de tempo de tela diário, Gráfico de pizza de categorias, Uso detalhado de aplicativos, Tendências de uso semanal e Análise de padrões de uso por hora do dia.';

  @override
  String get faqReportsQ2 =>
      'Quão detalhados são os relatórios de uso de aplicativos?';

  @override
  String get faqReportsA2 =>
      'Relatórios detalhados de uso de aplicativos mostram: Nome do aplicativo, Categoria, Tempo total gasto, Status de produtividade e oferecem uma seção \'Ações\' com insights mais profundos como resumo de uso, limites diários, tendências de uso e métricas de produtividade.';

  @override
  String get faqReportsQ3 =>
      'Posso analisar minhas tendências de uso ao longo do tempo?';

  @override
  String get faqReportsA3 =>
      'Sim! O aplicativo fornece comparações semana a semana, mostrando gráficos de uso das últimas semanas, uso médio diário, sessões mais longas e totais semanais para ajudá-lo a acompanhar seus hábitos digitais.';

  @override
  String get faqReportsQ4 => 'O que é a análise de \'Padrão de Uso\'?';

  @override
  String get faqReportsA4 =>
      'O Padrão de Uso divide seu tempo de tela em segmentos de manhã, tarde, noite e madrugada. Isso ajuda você a entender quando está mais ativo no seu dispositivo e identificar áreas potenciais de melhoria.';

  @override
  String get faqAlertsQ1 => 'Quão granulares são os limites de tempo de tela?';

  @override
  String get faqAlertsA1 =>
      'Você pode definir limites gerais de tempo de tela diário e limites individuais para aplicativos. Os limites podem ser configurados em horas e minutos, com opções para redefinir ou ajustar conforme necessário.';

  @override
  String get faqAlertsQ2 => 'Quais opções de notificação estão disponíveis?';

  @override
  String get faqAlertsA2 =>
      'O aplicativo oferece múltiplos tipos de notificação: Alertas do sistema quando você excede o tempo de tela, Alertas frequentes em intervalos personalizáveis (1, 5, 15, 30 ou 60 minutos) e alternadores para modo foco, tempo de tela e notificações específicas de aplicativos.';

  @override
  String get faqAlertsQ3 => 'Posso personalizar alertas de limites?';

  @override
  String get faqAlertsA3 =>
      'Sim, você pode personalizar a frequência de alertas, ativar/desativar tipos específicos de alertas e definir limites diferentes para tempo de tela geral e aplicativos individuais.';

  @override
  String get faqFocusQ1 => 'Quais tipos de Modos de Foco estão disponíveis?';

  @override
  String get faqFocusA1 =>
      'Os modos disponíveis incluem Trabalho Profundo (sessões focadas mais longas), Tarefas Rápidas (curtos períodos de trabalho) e Modo Leitura. Cada modo ajuda você a estruturar efetivamente seu tempo de trabalho e pausas.';

  @override
  String get faqFocusQ2 => 'Quão flexível é o Timer Pomodoro?';

  @override
  String get faqFocusA2 =>
      'O timer é altamente personalizável. Você pode ajustar a duração do trabalho, tempo de pausa curta e duração da pausa longa. Opções adicionais incluem início automático para próximas sessões e configurações de notificação.';

  @override
  String get faqFocusQ3 => 'O que o histórico do Modo Foco mostra?';

  @override
  String get faqFocusA3 =>
      'O histórico do Modo Foco rastreia sessões de foco diárias, mostrando o número de sessões por dia, gráfico de tendências, duração média da sessão, tempo total de foco e um gráfico de pizza de distribuição de tempo dividindo sessões de trabalho, pausas curtas e pausas longas.';

  @override
  String get faqFocusQ4 =>
      'Posso acompanhar o progresso da minha sessão de foco?';

  @override
  String get faqFocusA4 =>
      'O aplicativo possui uma interface de timer circular com botões de play/pausa, recarregar e configurações. Você pode facilmente acompanhar e gerenciar suas sessões de foco com controles intuitivos.';

  @override
  String get faqSettingsQ1 =>
      'Quais opções de personalização estão disponíveis?';

  @override
  String get faqSettingsA1 =>
      'A personalização inclui seleção de tema (Sistema, Claro, Escuro), configurações de idioma, comportamento de inicialização, controles abrangentes de notificação e opções de gerenciamento de dados como limpar dados ou redefinir configurações.';

  @override
  String get faqSettingsQ2 => 'Como forneço feedback ou relato problemas?';

  @override
  String get faqSettingsA2 =>
      'No final da seção Configurações, você encontrará botões para Relatar um Bug, Enviar Feedback ou Contatar Suporte. Estes irão redirecioná-lo para os canais de suporte apropriados.';

  @override
  String get faqSettingsQ3 => 'O que acontece quando limpo meus dados?';

  @override
  String get faqSettingsA3 =>
      'Limpar dados redefinirá todas as suas estatísticas de uso, histórico de sessões de foco e configurações personalizadas. Isso é útil para começar do zero ou solucionar problemas.';

  @override
  String get faqTroubleQ1 => 'Dados não aparecem, erro de hive não abrindo';

  @override
  String get faqTroubleA1 =>
      'O problema é conhecido, a correção temporária é limpar dados através das configurações e se não funcionar, vá para Documentos e delete os seguintes arquivos se existirem - harman_screentime_app_usage_box.hive e harman_screentime_app_usage.lock, também é sugerido atualizar o aplicativo para a versão mais recente.';

  @override
  String get faqTroubleQ2 =>
      'O aplicativo abre a cada inicialização, o que fazer?';

  @override
  String get faqTroubleA2 =>
      'Este é um problema conhecido que ocorre no Windows 10, a correção temporária é ativar Iniciar Minimizado nas configurações para que inicie minimizado.';

  @override
  String get usageAnalytics => 'Análises de Uso';

  @override
  String get last7Days => 'Últimos 7 Dias';

  @override
  String get lastMonth => 'Último Mês';

  @override
  String get last3Months => 'Últimos 3 Meses';

  @override
  String get lifetime => 'Todo o Período';

  @override
  String get custom => 'Personalizado';

  @override
  String get loadingAnalyticsData => 'Carregando dados de análise...';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get failedToInitialize =>
      'Falha ao inicializar análises. Por favor, reinicie o aplicativo.';

  @override
  String unexpectedError(String error) {
    return 'Ocorreu um erro inesperado: $error. Por favor, tente novamente mais tarde.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Erro ao carregar dados de análise: $error. Por favor, verifique sua conexão e tente novamente.';
  }

  @override
  String get customDialogTitle => 'Personalizado';

  @override
  String get dateRange => 'Intervalo de Datas:';

  @override
  String get specificDate => 'Data Específica';

  @override
  String get startDate => 'Data Inicial: ';

  @override
  String get endDate => 'Data Final: ';

  @override
  String get date => 'Data';

  @override
  String get cancel => 'Cancelar';

  @override
  String get apply => 'Aplicar';

  @override
  String get ok => 'OK';

  @override
  String get invalidDateRange => 'Intervalo de Datas Inválido';

  @override
  String get startDateBeforeEndDate =>
      'A data inicial deve ser anterior ou igual à data final.';

  @override
  String get totalScreenTime => 'Tempo de Tela Total';

  @override
  String get productiveTime => 'Tempo Produtivo';

  @override
  String get mostUsedApp => 'App Mais Usado';

  @override
  String get focusSessions => 'Sessões de Foco';

  @override
  String positiveComparison(String percent) {
    return '+$percent% vs período anterior';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% vs período anterior';
  }

  @override
  String iconLabel(String title) {
    return 'Ícone de $title';
  }

  @override
  String get dailyScreenTime => 'TEMPO DE TELA DIÁRIO';

  @override
  String get categoryBreakdown => 'DIVISÃO POR CATEGORIA';

  @override
  String get noDataAvailable => 'Nenhum dado disponível';

  @override
  String sectionLabel(String title) {
    return 'Seção $title';
  }

  @override
  String get detailedApplicationUsage => 'Uso Detalhado de Aplicativos';

  @override
  String get searchApplications => 'Pesquisar aplicativos';

  @override
  String get nameHeader => 'Nome';

  @override
  String get categoryHeader => 'Categoria';

  @override
  String get totalTimeHeader => 'Tempo Total';

  @override
  String get productivityHeader => 'Produtividade';

  @override
  String get actionsHeader => 'Ações';

  @override
  String sortByOption(String option) {
    return 'Ordenar por: $option';
  }

  @override
  String get sortByName => 'Nome';

  @override
  String get sortByCategory => 'Categoria';

  @override
  String get sortByUsage => 'Uso';

  @override
  String get productive => 'Produtivo';

  @override
  String get nonProductive => 'Não Produtivo';

  @override
  String get noApplicationsMatch =>
      'Nenhum aplicativo corresponde aos seus critérios de pesquisa';

  @override
  String get viewDetails => 'Ver detalhes';

  @override
  String get usageSummary => 'Resumo de Uso';

  @override
  String get usageOverPastWeek => 'Uso na Última Semana';

  @override
  String get usagePatternByTimeOfDay => 'Padrão de Uso por Hora do Dia';

  @override
  String get patternAnalysis => 'Análise de Padrões';

  @override
  String get today => 'Hoje';

  @override
  String get dailyLimit => 'Limite Diário';

  @override
  String get noLimit => 'Sem limite';

  @override
  String get usageTrend => 'Tendência de Uso';

  @override
  String get productivity => 'Produtividade';

  @override
  String get increasing => 'Aumentando';

  @override
  String get decreasing => 'Diminuindo';

  @override
  String get stable => 'Estável';

  @override
  String get avgDailyUsage => 'Uso Médio Diário';

  @override
  String get longestSession => 'Sessão mais longa';

  @override
  String get weeklyTotal => 'Total Semanal';

  @override
  String get noHistoricalData => 'Nenhum dado histórico disponível';

  @override
  String get morning => 'Manhã (6-12)';

  @override
  String get afternoon => 'Tarde (12-17)';

  @override
  String get evening => 'Noite (17-21)';

  @override
  String get night => 'Madrugada (21-6)';

  @override
  String get usageInsights => 'Insights de Uso';

  @override
  String get limitStatus => 'Status do Limite';

  @override
  String get close => 'Fechar';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'Você usa principalmente $appName durante $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Seu uso aumentou significativamente ($percentage%) em comparação com o período anterior.';
  }

  @override
  String get trendingUpward =>
      'Seu uso está tendendo para cima em comparação com o período anterior.';

  @override
  String significantDecrease(String percentage) {
    return 'Seu uso diminuiu significativamente ($percentage%) em comparação com o período anterior.';
  }

  @override
  String get trendingDownward =>
      'Seu uso está tendendo para baixo em comparação com o período anterior.';

  @override
  String get consistentUsage =>
      'Seu uso tem sido consistente em comparação com o período anterior.';

  @override
  String get markedAsProductive =>
      'Este é marcado como um aplicativo produtivo nas suas configurações.';

  @override
  String get markedAsNonProductive =>
      'Este é marcado como um aplicativo não produtivo nas suas configurações.';

  @override
  String mostActiveTime(String time) {
    return 'Seu horário mais ativo é por volta das $time.';
  }

  @override
  String get noLimitSet =>
      'Nenhum limite de uso foi definido para este aplicativo.';

  @override
  String get limitReached =>
      'Você atingiu seu limite diário para este aplicativo.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'Você está prestes a atingir seu limite diário com apenas $remainingTime restantes.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'Você usou $percent% do seu limite diário com $remainingTime restantes.';
  }

  @override
  String remainingTime(String time) {
    return 'Você tem $time restantes do seu limite diário.';
  }

  @override
  String get todayChart => 'Hoje';

  @override
  String hourPeriodAM(int hour) {
    return '${hour}h';
  }

  @override
  String hourPeriodPM(int hour) {
    return '${hour}h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String get alertsLimitsTitle => 'Alertas e Limites';

  @override
  String get notificationsSettings => 'Configurações de Notificações';

  @override
  String get overallScreenTimeLimit => 'Limite Geral de Tempo de Tela';

  @override
  String get applicationLimits => 'Limites de Aplicativos';

  @override
  String get popupAlerts => 'Alertas Pop-up';

  @override
  String get frequentAlerts => 'Alertas Frequentes';

  @override
  String get soundAlerts => 'Alertas Sonoros';

  @override
  String get systemAlerts => 'Alertas do Sistema';

  @override
  String get dailyTotalLimit => 'Limite Diário Total: ';

  @override
  String get hours => 'Horas';

  @override
  String get minutes => 'Minutos';

  @override
  String get currentUsage => 'Uso Atual: ';

  @override
  String get tableName => 'Nome';

  @override
  String get tableCategory => 'Categoria';

  @override
  String get tableDailyLimit => 'Limite Diário';

  @override
  String get tableCurrentUsage => 'Uso Atual';

  @override
  String get tableStatus => 'Status';

  @override
  String get tableActions => 'Ações';

  @override
  String get addLimit => 'Adicionar Limite';

  @override
  String get noApplicationsToDisplay => 'Nenhum aplicativo para exibir';

  @override
  String get statusActive => 'Ativo';

  @override
  String get statusOff => 'Desligado';

  @override
  String get durationNone => 'Nenhum';

  @override
  String get addApplicationLimit => 'Adicionar Limite de Aplicativo';

  @override
  String get selectApplication => 'Selecionar Aplicativo';

  @override
  String get selectApplicationPlaceholder => 'Selecione um aplicativo';

  @override
  String get enableLimit => 'Ativar Limite: ';

  @override
  String editLimitTitle(String appName) {
    return 'Editar Limite: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Falha ao carregar dados: $error';
  }

  @override
  String get resetSettingsTitle => 'Redefinir Configurações?';

  @override
  String get resetSettingsContent =>
      'Se você redefinir as configurações, não poderá recuperá-las. Deseja redefinir?';

  @override
  String get resetAll => 'Redefinir Tudo';

  @override
  String get refresh => 'Atualizar';

  @override
  String get save => 'Salvar';

  @override
  String get add => 'Adicionar';

  @override
  String get error => 'Erro';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get applicationsTitle => 'Aplicativos';

  @override
  String get searchApplication => 'Pesquisar Aplicativo';

  @override
  String get tracking => 'Monitorados';

  @override
  String get hiddenVisible => 'Oculto/Visível';

  @override
  String get selectCategory => 'Selecione uma Categoria';

  @override
  String get allCategories => 'Todas';

  @override
  String get tableScreenTime => 'Tempo de Tela';

  @override
  String get tableTracking => 'Rastreamento';

  @override
  String get tableHidden => 'Oculto';

  @override
  String get tableEdit => 'Editar';

  @override
  String editAppTitle(String appName) {
    return 'Editar $appName';
  }

  @override
  String get categorySection => 'Categoria';

  @override
  String get customCategory => 'Personalizada';

  @override
  String get customCategoryPlaceholder =>
      'Digite o nome da categoria personalizada';

  @override
  String get uncategorized => 'Sem Categoria';

  @override
  String get isProductive => 'É Produtivo';

  @override
  String get trackUsage => 'Rastrear Uso';

  @override
  String get visibleInReports => 'Visível nos Relatórios';

  @override
  String get timeLimitsSection => 'Limites de Tempo';

  @override
  String get enableDailyLimit => 'Ativar Limite Diário';

  @override
  String get setDailyTimeLimit => 'Definir limite de tempo diário:';

  @override
  String get saveChanges => 'Salvar Alterações';

  @override
  String errorLoadingData(String error) {
    return 'Erro ao carregar dados da visão geral: $error';
  }

  @override
  String get focusModeTitle => 'Modo Foco';

  @override
  String get historySection => 'Histórico';

  @override
  String get trendsSection => 'Tendências';

  @override
  String get timeDistributionSection => 'Distribuição de Tempo';

  @override
  String get sessionHistorySection => 'Histórico de Sessões';

  @override
  String get workSession => 'Sessão de Trabalho';

  @override
  String get shortBreak => 'Pausa Curta';

  @override
  String get longBreak => 'Pausa Longa';

  @override
  String get dateHeader => 'Data';

  @override
  String get durationHeader => 'Duração';

  @override
  String get monday => 'Segunda-feira';

  @override
  String get tuesday => 'Terça-feira';

  @override
  String get wednesday => 'Quarta-feira';

  @override
  String get thursday => 'Quinta-feira';

  @override
  String get friday => 'Sexta-feira';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get focusModeSettingsTitle => 'Configurações do Modo Foco';

  @override
  String get modeCustom => 'Personalizado';

  @override
  String get modeDeepWork => 'Trabalho Profundo (60 min)';

  @override
  String get modeQuickTasks => 'Tarefas Rápidas (25 min)';

  @override
  String get modeReading => 'Leitura (45 min)';

  @override
  String workDurationLabel(int minutes) {
    return 'Duração do Trabalho: $minutes min';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Intervalo Curto';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Intervalo Longo';
  }

  @override
  String get autoStartNextSession => 'Iniciar próxima sessão automaticamente';

  @override
  String get blockDistractions => 'Bloquear distrações durante o modo foco';

  @override
  String get enableNotifications => 'Ativar notificações';

  @override
  String get saved => 'Salvo';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Erro ao carregar dados do modo foco: $error';
  }

  @override
  String get overviewTitle => 'Visão Geral de Hoje';

  @override
  String get startFocusMode => 'Iniciar Modo Foco';

  @override
  String get loadingProductivityData =>
      'Carregando seus dados de produtividade...';

  @override
  String get noActivityDataAvailable =>
      'Nenhum dado de atividade disponível ainda';

  @override
  String get startUsingApplications =>
      'Comece a usar seus aplicativos para rastrear o tempo de tela e a produtividade.';

  @override
  String get refreshData => 'Atualizar Dados';

  @override
  String get topApplications => 'Principais Aplicativos';

  @override
  String get noAppUsageDataAvailable =>
      'Nenhum dado de uso de aplicativo disponível ainda';

  @override
  String get noApplicationDataAvailable =>
      'Nenhum dado de aplicativo disponível';

  @override
  String get noCategoryDataAvailable => 'Nenhum dado de categoria disponível';

  @override
  String get noApplicationLimitsSet => 'Nenhum limite de aplicativo definido';

  @override
  String get screenLabel => 'Tempo de';

  @override
  String get timeLabel => 'Tela';

  @override
  String get productiveLabel => 'Pontuação';

  @override
  String get scoreLabel => 'Produtiva';

  @override
  String get defaultNone => 'Nenhum';

  @override
  String get defaultTime => '0h 0m';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Desconhecido';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get generalSection => 'Geral';

  @override
  String get notificationsSection => 'Notificações';

  @override
  String get dataSection => 'Dados';

  @override
  String get versionSection => 'Versão';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageDescription => 'Idioma do aplicativo';

  @override
  String get startupBehaviourTitle => 'Comportamento de Inicialização';

  @override
  String get startupBehaviourDescription => 'Iniciar com o sistema operacional';

  @override
  String get launchMinimizedTitle => 'Iniciar Minimizado';

  @override
  String get launchMinimizedDescription =>
      'Iniciar o aplicativo na Bandeja do Sistema (Recomendado para Windows 10)';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsAllDescription =>
      'Todas as notificações do aplicativo';

  @override
  String get focusModeNotificationsTitle => 'Modo Foco';

  @override
  String get focusModeNotificationsDescription =>
      'Todas as notificações para o modo foco';

  @override
  String get screenTimeNotificationsTitle => 'Tempo de Tela';

  @override
  String get screenTimeNotificationsDescription =>
      'Todas as notificações para restrição de tempo de tela';

  @override
  String get appScreenTimeNotificationsTitle => 'Tempo de Tela do Aplicativo';

  @override
  String get appScreenTimeNotificationsDescription =>
      'Todas as notificações para restrição de tempo de tela de aplicativos';

  @override
  String get frequentAlertsTitle => 'Intervalo de Alertas Frequentes';

  @override
  String get frequentAlertsDescription =>
      'Definir intervalo para notificações frequentes (minutos)';

  @override
  String get clearDataTitle => 'Limpar Dados';

  @override
  String get clearDataDescription =>
      'Limpar todo o histórico e outros dados relacionados';

  @override
  String get resetSettingsTitle2 => 'Redefinir Configurações';

  @override
  String get resetSettingsDescription => 'Redefinir todas as configurações';

  @override
  String get versionTitle => 'Versão';

  @override
  String get versionDescription => 'Versão atual do aplicativo';

  @override
  String get contactButton => 'Contato';

  @override
  String get reportBugButton => 'Relatar Bug';

  @override
  String get submitFeedbackButton => 'Enviar Feedback';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'Limpar Dados?';

  @override
  String get clearDataDialogContent =>
      'Isso limpará todo o histórico e dados relacionados. Você não poderá recuperá-los. Deseja prosseguir?';

  @override
  String get clearDataButtonLabel => 'Limpar Dados';

  @override
  String get resetSettingsDialogTitle => 'Redefinir Configurações?';

  @override
  String get resetSettingsDialogContent =>
      'Isso redefinirá todas as configurações para os valores padrão. Deseja prosseguir?';

  @override
  String get resetButtonLabel => 'Redefinir';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String errorMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get chart_focusTrends => 'Tendências de Foco';

  @override
  String get chart_sessionCount => 'Contagem de Sessões';

  @override
  String get chart_avgDuration => 'Duração Média';

  @override
  String get chart_totalFocus => 'Foco Total';

  @override
  String get chart_yAxis_sessions => 'Sessões';

  @override
  String get chart_yAxis_minutes => 'Minutos';

  @override
  String get chart_yAxis_value => 'Valor';

  @override
  String get chart_monthOverMonthChange => 'Variação mês a mês: ';

  @override
  String get chart_customRange => 'Intervalo Personalizado';

  @override
  String get day_monday => 'Segunda-feira';

  @override
  String get day_mondayShort => 'Seg';

  @override
  String get day_mondayAbbr => 'Sg';

  @override
  String get day_tuesday => 'Terça-feira';

  @override
  String get day_tuesdayShort => 'Ter';

  @override
  String get day_tuesdayAbbr => 'Te';

  @override
  String get day_wednesday => 'Quarta-feira';

  @override
  String get day_wednesdayShort => 'Qua';

  @override
  String get day_wednesdayAbbr => 'Qa';

  @override
  String get day_thursday => 'Quinta-feira';

  @override
  String get day_thursdayShort => 'Qui';

  @override
  String get day_thursdayAbbr => 'Qi';

  @override
  String get day_friday => 'Sexta-feira';

  @override
  String get day_fridayShort => 'Sex';

  @override
  String get day_fridayAbbr => 'Sx';

  @override
  String get day_saturday => 'Sábado';

  @override
  String get day_saturdayShort => 'Sáb';

  @override
  String get day_saturdayAbbr => 'Sb';

  @override
  String get day_sunday => 'Domingo';

  @override
  String get day_sundayShort => 'Dom';

  @override
  String get day_sundayAbbr => 'Dm';

  @override
  String time_hours(int count) {
    return '${count}h';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count min';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: ${hours}h ${minutes}m';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count horas';
  }

  @override
  String get month_january => 'Janeiro';

  @override
  String get month_januaryShort => 'Jan';

  @override
  String get month_february => 'Fevereiro';

  @override
  String get month_februaryShort => 'Fev';

  @override
  String get month_march => 'Março';

  @override
  String get month_marchShort => 'Mar';

  @override
  String get month_april => 'Abril';

  @override
  String get month_aprilShort => 'Abr';

  @override
  String get month_may => 'Maio';

  @override
  String get month_mayShort => 'Mai';

  @override
  String get month_june => 'Junho';

  @override
  String get month_juneShort => 'Jun';

  @override
  String get month_july => 'Julho';

  @override
  String get month_julyShort => 'Jul';

  @override
  String get month_august => 'Agosto';

  @override
  String get month_augustShort => 'Ago';

  @override
  String get month_september => 'Setembro';

  @override
  String get month_septemberShort => 'Set';

  @override
  String get month_october => 'Outubro';

  @override
  String get month_octoberShort => 'Out';

  @override
  String get month_november => 'Novembro';

  @override
  String get month_novemberShort => 'Nov';

  @override
  String get month_december => 'Dezembro';

  @override
  String get month_decemberShort => 'Dez';

  @override
  String get categoryAll => 'Todas';

  @override
  String get categoryProductivity => 'Produtividade';

  @override
  String get categoryDevelopment => 'Desenvolvimento';

  @override
  String get categorySocialMedia => 'Redes Sociais';

  @override
  String get categoryEntertainment => 'Entretenimento';

  @override
  String get categoryGaming => 'Jogos';

  @override
  String get categoryCommunication => 'Comunicação';

  @override
  String get categoryWebBrowsing => 'Navegação Web';

  @override
  String get categoryCreative => 'Criativo';

  @override
  String get categoryEducation => 'Educação';

  @override
  String get categoryUtility => 'Utilitários';

  @override
  String get categoryUncategorized => 'Sem Categoria';

  @override
  String get appMicrosoftWord => 'Microsoft Word';

  @override
  String get appExcel => 'Excel';

  @override
  String get appPowerPoint => 'PowerPoint';

  @override
  String get appGoogleDocs => 'Google Docs';

  @override
  String get appNotion => 'Notion';

  @override
  String get appEvernote => 'Evernote';

  @override
  String get appTrello => 'Trello';

  @override
  String get appAsana => 'Asana';

  @override
  String get appSlack => 'Slack';

  @override
  String get appMicrosoftTeams => 'Microsoft Teams';

  @override
  String get appZoom => 'Zoom';

  @override
  String get appGoogleCalendar => 'Google Agenda';

  @override
  String get appAppleCalendar => 'Calendário';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'Terminal';

  @override
  String get appCommandPrompt => 'Prompt de Comando';

  @override
  String get appChrome => 'Chrome';

  @override
  String get appFirefox => 'Firefox';

  @override
  String get appSafari => 'Safari';

  @override
  String get appEdge => 'Edge';

  @override
  String get appOpera => 'Opera';

  @override
  String get appBrave => 'Brave';

  @override
  String get appNetflix => 'Netflix';

  @override
  String get appYouTube => 'YouTube';

  @override
  String get appSpotify => 'Spotify';

  @override
  String get appAppleMusic => 'Apple Music';

  @override
  String get appCalculator => 'Calculadora';

  @override
  String get appNotes => 'Notas';

  @override
  String get appSystemPreferences => 'Preferências do Sistema';

  @override
  String get appTaskManager => 'Gerenciador de Tarefas';

  @override
  String get appFileExplorer => 'Explorador de Arquivos';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';

  @override
  String get loadingApplication => 'Carregando aplicativo...';

  @override
  String get loadingData => 'Carregando dados...';

  @override
  String get reportsError => 'Erro';

  @override
  String get reportsRetry => 'Tentar Novamente';

  @override
  String get backupRestoreSection => 'Backup e Restauração';

  @override
  String get backupRestoreTitle => 'Backup e Restauração';

  @override
  String get exportDataTitle => 'Exportar Dados';

  @override
  String get exportDataDescription => 'Criar um backup de todos os seus dados';

  @override
  String get importDataTitle => 'Importar Dados';

  @override
  String get importDataDescription =>
      'Restaurar a partir de um arquivo de backup';

  @override
  String get exportButton => 'Exportar';

  @override
  String get importButton => 'Importar';

  @override
  String get closeButton => 'Fechar';

  @override
  String get noButton => 'Não';

  @override
  String get shareButton => 'Compartilhar';

  @override
  String get exportStarting => 'Iniciando exportação...';

  @override
  String get exportSuccessful => 'Exportação Bem-sucedida';

  @override
  String get exportFailed => 'Falha na Exportação';

  @override
  String get exportComplete => 'Exportação Concluída';

  @override
  String get shareBackupQuestion =>
      'Gostaria de compartilhar o arquivo de backup?';

  @override
  String get importStarting => 'Iniciando importação...';

  @override
  String get importSuccessful => 'Importação bem-sucedida!';

  @override
  String get importFailed => 'Falha na importação';

  @override
  String get importOptionsTitle => 'Opções de Importação';

  @override
  String get importOptionsQuestion =>
      'Como você gostaria de importar os dados?';

  @override
  String get replaceModeTitle => 'Substituir';

  @override
  String get replaceModeDescription => 'Substituir todos os dados existentes';

  @override
  String get mergeModeTitle => 'Mesclar';

  @override
  String get mergeModeDescription => 'Combinar com dados existentes';

  @override
  String get appendModeTitle => 'Anexar';

  @override
  String get appendModeDescription => 'Adicionar apenas novos registros';

  @override
  String get warningTitle => '⚠️ Aviso';

  @override
  String get replaceWarningMessage =>
      'Isso substituirá TODOS os seus dados existentes. Tem certeza de que deseja continuar?';

  @override
  String get replaceAllButton => 'Substituir Tudo';

  @override
  String get fileLabel => 'Arquivo';

  @override
  String get sizeLabel => 'Tamanho';

  @override
  String get recordsLabel => 'Registros';

  @override
  String get usageRecordsLabel => 'Registros de uso';

  @override
  String get focusSessionsLabel => 'Sessões de foco';

  @override
  String get appMetadataLabel => 'Metadados do aplicativo';

  @override
  String get updatedLabel => 'Atualizado';

  @override
  String get skippedLabel => 'Ignorado';

  @override
  String get faqSettingsQ4 => 'Como posso restaurar ou exportar meus dados?';

  @override
  String get faqSettingsA4 =>
      'Você pode ir para configurações e lá encontrará a seção Backup e Restauração. Você pode exportar ou importar dados daqui, note que o arquivo de dados exportado é armazenado em Documentos na pasta Scolect-Backups e apenas este arquivo pode ser usado para restaurar dados, nenhum outro arquivo.';

  @override
  String get faqGeneralQ6 =>
      'Como posso mudar o idioma e quais idiomas estão disponíveis, também o que fazer se eu encontrar que a tradução está errada?';

  @override
  String get faqGeneralA6 =>
      'O idioma pode ser alterado através da seção Geral das Configurações, todos os idiomas disponíveis estão listados lá, você pode solicitar tradução clicando em Contato e enviando sua solicitação com o idioma desejado. Saiba que a tradução pode estar errada pois é gerada por IA a partir do inglês e se você quiser relatar pode fazer através de relatar bug, ou contato, ou se você é um desenvolvedor pode abrir uma issue no Github. Contribuições relacionadas a idiomas são bem-vindas!';

  @override
  String get faqGeneralQ7 => 'E se eu encontrar que a tradução está errada?';

  @override
  String get faqGeneralA7 =>
      'A tradução pode estar errada pois é gerada por IA a partir do inglês e se você quiser relatar pode fazer através de relatar bug, ou contato, ou se você é um desenvolvedor pode abrir uma issue no Github. Contribuições relacionadas a idiomas são bem-vindas!';

  @override
  String get activityTrackingSection => 'Rastreamento de Atividade';

  @override
  String get idleDetectionTitle => 'Detecção de Inatividade';

  @override
  String get idleDetectionDescription => 'Parar de rastrear quando inativo';

  @override
  String get idleTimeoutTitle => 'Tempo de Inatividade';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'Tempo antes de considerar inativo ($timeout)';
  }

  @override
  String get advancedWarning =>
      'Recursos avançados podem aumentar o uso de recursos. Ative apenas se necessário.';

  @override
  String get monitorAudioTitle => 'Monitorar Áudio do Sistema';

  @override
  String get monitorAudioDescription =>
      'Detectar atividade pela reprodução de áudio';

  @override
  String get audioSensitivityTitle => 'Sensibilidade de Áudio';

  @override
  String audioSensitivityDescription(String value) {
    return 'Limite de detecção ($value)';
  }

  @override
  String get monitorControllersTitle => 'Monitorar Controles de Jogo';

  @override
  String get monitorControllersDescription => 'Detectar controles Xbox/XInput';

  @override
  String get monitorHIDTitle => 'Monitorar Dispositivos HID';

  @override
  String get monitorHIDDescription =>
      'Detectar volantes, tablets, dispositivos personalizados';

  @override
  String get setIdleTimeoutTitle => 'Definir Tempo de Inatividade';

  @override
  String get idleTimeoutDialogDescription =>
      'Escolha quanto tempo esperar antes de considerá-lo inativo:';

  @override
  String get seconds30 => '30 segundos';

  @override
  String get minute1 => '1 minuto';

  @override
  String get minutes2 => '2 minutos';

  @override
  String get minutes5 => '5 minutos';

  @override
  String get minutes10 => '10 minutos';

  @override
  String get customOption => 'Personalizado';

  @override
  String get customDurationTitle => 'Duração Personalizada';

  @override
  String get minutesLabel => 'Minutos';

  @override
  String get secondsLabel => 'Segundos';

  @override
  String get minAbbreviation => 'min';

  @override
  String get secAbbreviation => 'seg';

  @override
  String totalLabel(String duration) {
    return 'Total: $duration';
  }

  @override
  String minimumError(String value) {
    return 'O mínimo é $value';
  }

  @override
  String maximumError(String value) {
    return 'O máximo é $value';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'Intervalo: $min - $max';
  }

  @override
  String get saveButton => 'Salvar';

  @override
  String timeFormatSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get timeFormatMinute => '1 min';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes min ${seconds}s';
  }

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeDescription => 'Tema de cores do aplicativo';

  @override
  String get voiceGenderTitle => 'Gênero da voz';

  @override
  String get voiceGenderDescription =>
      'Escolha o gênero da voz para notificações do temporizador';

  @override
  String get voiceGenderMale => 'Masculino';

  @override
  String get voiceGenderFemale => 'Feminino';

  @override
  String get alertsLimitsSubtitle =>
      'Gerencie seus limites de tempo de tela e notificações';

  @override
  String get applicationsSubtitle => 'Gerencie seus aplicativos rastreados';

  @override
  String applicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aplicativos',
      one: '1 aplicativo',
    );
    return '$_temp0';
  }

  @override
  String get noApplicationsFound => 'Nenhum aplicativo encontrado';

  @override
  String get tryAdjustingFilters => 'Tente ajustar seus filtros';

  @override
  String get configureAppSettings => 'Configurar configurações do aplicativo';

  @override
  String get behaviorSection => 'Comportamento';

  @override
  String helpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perguntas em 7 categorias',
      one: '1 pergunta em 7 categorias',
    );
    return '$_temp0';
  }

  @override
  String get searchForHelp => 'Buscar ajuda...';

  @override
  String get quickNavGeneral => 'Geral';

  @override
  String get quickNavApps => 'Aplicativos';

  @override
  String get quickNavReports => 'Relatórios';

  @override
  String get quickNavFocus => 'Foco';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado';

  @override
  String get tryDifferentKeywords =>
      'Tente pesquisar com palavras-chave diferentes';

  @override
  String get clearSearch => 'Limpar Pesquisa';

  @override
  String get greetingMorning => 'Bom dia! Aqui está seu resumo de atividades.';

  @override
  String get greetingAfternoon =>
      'Boa tarde! Aqui está seu resumo de atividades.';

  @override
  String get greetingEvening =>
      'Boa noite! Aqui está seu resumo de atividades.';

  @override
  String get screenTimeProgress => 'Tempo de\nTela';

  @override
  String get productiveScoreProgress => 'Pontuação\nProdutiva';

  @override
  String get focusModeSubtitle => 'Mantenha o foco, seja produtivo';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get sessions => 'Sessões';

  @override
  String get totalTime => 'Tempo total';

  @override
  String get avgLength => 'Duração Média';

  @override
  String get focusTime => 'Tempo de Foco';

  @override
  String get paused => 'Pausado';

  @override
  String get shortBreakStatus => 'Intervalo Curto';

  @override
  String get longBreakStatus => 'Intervalo Longo';

  @override
  String get readyToFocus => 'Pronto para Focar';

  @override
  String get focus => 'Foco';

  @override
  String get restartSession => 'Reiniciar Sessão';

  @override
  String get skipToNext => 'Pular para o Próximo';

  @override
  String get settings => 'Configurações';

  @override
  String sessionsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões concluídas',
      one: '1 sessão concluída',
    );
    return '$_temp0';
  }

  @override
  String get focusModePreset => 'Predefinição do Modo de Foco';

  @override
  String get focusDuration => 'Duração do Foco';

  @override
  String minutesFormat(int minutes) {
    return '$minutes min';
  }

  @override
  String get shortBreakDuration => 'Intervalo Curto';

  @override
  String get longBreakDuration => 'Intervalo Longo';

  @override
  String get enableSounds => 'Ativar Sons';

  @override
  String get focus_mode_this_week => 'Esta Semana';

  @override
  String get focus_mode_best_day => 'Melhor Dia';

  @override
  String focus_mode_sessions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões',
      one: '1 sessão',
      zero: '0 sessões',
    );
    return '$_temp0';
  }

  @override
  String get focus_mode_no_data_yet => 'Ainda sem dados';

  @override
  String get chart_current => 'Atual';

  @override
  String get chart_previous => 'Anterior';

  @override
  String get permission_error => 'Erro de Permissão';

  @override
  String get notification_permission_denied =>
      'Permissão de Notificação Negada';

  @override
  String get notification_permission_denied_message =>
      'ScreenTime precisa de permissão de notificação para enviar alertas e lembretes.\n\nGostaria de abrir as Configurações do Sistema para ativar as notificações?';

  @override
  String get notification_permission_denied_hint =>
      'Abra as Configurações do Sistema para ativar as notificações do ScreenTime.';

  @override
  String get notification_permission_required =>
      'Permissão de Notificação Necessária';

  @override
  String get notification_permission_required_message =>
      'ScreenTime precisa de permissão para enviar notificações.';

  @override
  String get open_settings => 'Abrir Configurações';

  @override
  String get allow_notifications => 'Permitir Notificações';

  @override
  String get permission_allowed => 'Permitido';

  @override
  String get permission_denied => 'Negado';

  @override
  String get permission_not_set => 'Não Definido';

  @override
  String get on => 'Ligado';

  @override
  String get off => 'Desligado';

  @override
  String get enable_notification_permission_hint =>
      'Ative a permissão de notificação para receber alertas';

  @override
  String minutes_format(int minutes) {
    return '$minutes min';
  }

  @override
  String get chart_average => 'Média';

  @override
  String get chart_peak => 'Pico';

  @override
  String get chart_lowest => 'Mais baixo';

  @override
  String get active => 'Ativo';

  @override
  String get disabled => 'Desabilitado';

  @override
  String get advanced_options => 'Opções Avançadas';

  @override
  String get sync_ready => 'Sincronização Pronta';

  @override
  String get success => 'Sucesso';

  @override
  String get destructive_badge => 'Destrutivo';

  @override
  String get recommended_badge => 'Recomendado';

  @override
  String get safe_badge => 'Seguro';

  @override
  String get overview => 'Visão Geral';

  @override
  String get patterns => 'Padrões';

  @override
  String get apps => 'Aplicativos';

  @override
  String get sortAscending => 'Ordenar Crescente';

  @override
  String get sortDescending => 'Ordenar Decrescente';

  @override
  String applicationsShowing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aplicativos mostrando',
      one: '1 aplicativo mostrando',
      zero: '0 aplicativos mostrando',
    );
    return '$_temp0';
  }

  @override
  String valueLabel(String value) {
    return 'Valor: $value';
  }

  @override
  String appsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aplicativos',
      one: '1 aplicativo',
      zero: '0 aplicativos',
    );
    return '$_temp0';
  }

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categorias',
      one: '1 categoria',
      zero: '0 categorias',
    );
    return '$_temp0';
  }

  @override
  String get systemNotificationsDisabled =>
      'As notificações do sistema estão desativadas. Ative-as nas Configurações do sistema para alertas de foco.';

  @override
  String get openSystemSettings => 'Abrir Configurações do Sistema';

  @override
  String get appNotificationsDisabled =>
      'As notificações estão desativadas nas configurações do aplicativo. Ative-as para receber alertas de foco.';

  @override
  String get goToSettings => 'Ir para Configurações';

  @override
  String get focusModeNotificationsDisabled =>
      'As notificações do modo de foco estão desativadas. Ative-as para receber alertas de sessão.';

  @override
  String get notificationsDisabled => 'Notificações Desativadas';

  @override
  String get dontShowAgain => 'Não mostrar novamente';

  @override
  String get systemSettingsRequired => 'Configurações do Sistema Necessárias';

  @override
  String get notificationsDisabledSystemLevel =>
      'As notificações estão desativadas no nível do sistema. Para ativar:';

  @override
  String get step1OpenSystemSettings =>
      '1. Abrir Configurações do Sistema (Preferências do Sistema)';

  @override
  String get step2GoToNotifications => '2. Ir para Notificações';

  @override
  String get step3FindApp => '3. Encontrar e selecionar Scolect';

  @override
  String get step4EnableNotifications => '4. Ativar \"Permitir notificações\"';

  @override
  String get returnToAppMessage =>
      'Em seguida, retorne a este aplicativo e as notificações funcionarão.';

  @override
  String get gotIt => 'Entendi';

  @override
  String get noSessionsYet => 'Ainda não há sessões';

  @override
  String applicationsTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aplicativos rastreados',
      one: '1 aplicativo rastreado',
      zero: '0 aplicativos rastreados',
    );
    return '$_temp0';
  }

  @override
  String get applicationHeader => 'Aplicativo';

  @override
  String get currentUsageHeader => 'Uso Atual';

  @override
  String get dailyLimitHeader => 'Limite Diário';

  @override
  String get edit => 'Editar';

  @override
  String get showPopupNotifications => 'Mostrar notificações pop-up';

  @override
  String get moreFrequentReminders => 'Lembretes mais frequentes';

  @override
  String get playSoundWithAlerts => 'Reproduzir som com alertas';

  @override
  String get systemTrayNotifications => 'Notificações na bandeja do sistema';

  @override
  String screenTimeUsed(String current, String limit) {
    return '$current / $limit usado';
  }

  @override
  String get todaysScreenTime => 'Tempo de Tela Hoje';

  @override
  String get activeLimits => 'Limites Ativos';

  @override
  String get nearLimit => 'Próximo ao Limite';

  @override
  String get colorPickerSpectrum => 'Espectro';

  @override
  String get colorPickerPresets => 'Predefinições';

  @override
  String get colorPickerSliders => 'Controles Deslizantes';

  @override
  String get colorPickerBasicColors => 'Cores Básicas';

  @override
  String get colorPickerExtendedPalette => 'Paleta Estendida';

  @override
  String get colorPickerRed => 'Vermelho';

  @override
  String get colorPickerGreen => 'Verde';

  @override
  String get colorPickerBlue => 'Azul';

  @override
  String get colorPickerHue => 'Matiz';

  @override
  String get colorPickerSaturation => 'Saturação';

  @override
  String get colorPickerBrightness => 'Brilho';

  @override
  String get colorPickerHexColor => 'Cor Hexadecimal';

  @override
  String get colorPickerHexPlaceholder => 'RRGGBB';

  @override
  String get colorPickerRGB => 'RGB';

  @override
  String get select => 'Selecionar';

  @override
  String get themeCustomization => 'Personalização de Tema';

  @override
  String get chooseThemePreset => 'Escolher uma Predefinição de Tema';

  @override
  String get yourCustomThemes => 'Seus Temas Personalizados';

  @override
  String get createCustomTheme => 'Criar Tema Personalizado';

  @override
  String get designOwnColorScheme => 'Projete seu próprio esquema de cores';

  @override
  String get newTheme => 'Novo Tema';

  @override
  String get editCurrentTheme => 'Editar Tema Atual';

  @override
  String customizeColorsFor(String themeName) {
    return 'Personalizar cores para $themeName';
  }

  @override
  String customThemeNumber(int number) {
    return 'Tema Personalizado $number';
  }

  @override
  String get deleteCustomTheme => 'Excluir Tema Personalizado';

  @override
  String confirmDeleteTheme(String themeName) {
    return 'Tem certeza de que deseja excluir \"$themeName\"?';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get customizeTheme => 'Personalizar Tema';

  @override
  String get preview => 'Visualizar';

  @override
  String get themeName => 'Nome do Tema';

  @override
  String get brandColors => 'Cores da Marca';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Escuro';

  @override
  String get reset => 'Redefinir';

  @override
  String get saveTheme => 'Salvar Tema';

  @override
  String get customTheme => 'Tema Personalizado';

  @override
  String get primaryColors => 'Cores Primárias';

  @override
  String get primaryColorsDesc =>
      'Cores de destaque principais usadas em todo o aplicativo';

  @override
  String get primaryAccent => 'Destaque Primário';

  @override
  String get primaryAccentDesc => 'Cor principal da marca, botões, links';

  @override
  String get secondaryAccent => 'Destaque Secundário';

  @override
  String get secondaryAccentDesc => 'Destaque complementar para gradientes';

  @override
  String get semanticColors => 'Cores Semânticas';

  @override
  String get semanticColorsDesc => 'Cores que transmitem significado e status';

  @override
  String get successColor => 'Cor de Sucesso';

  @override
  String get successColorDesc => 'Ações positivas, confirmações';

  @override
  String get warningColor => 'Cor de Aviso';

  @override
  String get warningColorDesc => 'Cuidado, estados pendentes';

  @override
  String get errorColor => 'Cor de Erro';

  @override
  String get errorColorDesc => 'Erros, ações destrutivas';

  @override
  String get backgroundColors => 'Cores de Fundo';

  @override
  String get backgroundColorsLightDesc =>
      'Superfícies de fundo principais para modo claro';

  @override
  String get backgroundColorsDarkDesc =>
      'Superfícies de fundo principais para modo escuro';

  @override
  String get background => 'Fundo';

  @override
  String get backgroundDesc => 'Fundo principal do aplicativo';

  @override
  String get surface => 'Superfície';

  @override
  String get surfaceDesc => 'Cartões, diálogos, superfícies elevadas';

  @override
  String get surfaceSecondary => 'Superfície Secundária';

  @override
  String get surfaceSecondaryDesc => 'Cartões secundários, barras laterais';

  @override
  String get border => 'Borda';

  @override
  String get borderDesc => 'Divisórias, bordas de cartões';

  @override
  String get textColors => 'Cores de Texto';

  @override
  String get textColorsLightDesc => 'Cores de tipografia para modo claro';

  @override
  String get textColorsDarkDesc => 'Cores de tipografia para modo escuro';

  @override
  String get textPrimary => 'Texto Primário';

  @override
  String get textPrimaryDesc => 'Títulos, texto importante';

  @override
  String get textSecondary => 'Texto Secundário';

  @override
  String get textSecondaryDesc => 'Descrições, legendas';

  @override
  String previewMode(String mode) {
    return 'Visualização: Modo $mode';
  }

  @override
  String get dark => 'Escuro';

  @override
  String get light => 'Claro';

  @override
  String get sampleCardTitle => 'Título do Cartão de Exemplo';

  @override
  String get sampleSecondaryText =>
      'Este é o texto secundário que aparece abaixo.';

  @override
  String get primary => 'Primário';

  @override
  String get secondary => 'Secundário';

  @override
  String get warning => 'Aviso';

  @override
  String get launchAtStartupTitle => 'Iniciar na inicialização';

  @override
  String get launchAtStartupDescription =>
      'Iniciar automaticamente o Scolect quando você fizer login no seu computador';

  @override
  String get inputMonitoringPermissionTitle =>
      'Monitoramento do teclado indisponível';

  @override
  String get inputMonitoringPermissionDescription =>
      'Ative a permissão de monitoramento de entrada para rastrear a atividade do teclado. No momento, apenas o mouse está sendo monitorado.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get permissionGrantedTitle => 'Permissão concedida';

  @override
  String get permissionGrantedDescription =>
      'O aplicativo precisa ser reiniciado para que o monitoramento de entrada entre em vigor.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get restartRequiredTitle => 'Reinício necessário';

  @override
  String get restartRequiredDescription =>
      'Para ativar o monitoramento do teclado, o aplicativo precisa ser reiniciado. Isso é exigido pelo macOS.';

  @override
  String get restartNote =>
      'O aplicativo será reaberto automaticamente após o reinício.';

  @override
  String get restartNow => 'Reiniciar agora';

  @override
  String get restartLater => 'Reiniciar mais tarde';

  @override
  String get restartFailedTitle => 'Falha ao reiniciar';

  @override
  String get restartFailedMessage =>
      'Não foi possível reiniciar o aplicativo automaticamente. Encerre (Cmd+Q) e abra novamente manualmente.';

  @override
  String get exportAnalyticsReport => 'Exportar Relatório de Análise';

  @override
  String get chooseExportFormat => 'Escolha o formato de exportação:';

  @override
  String get beautifulExcelReport => 'Lindo Relatório Excel';

  @override
  String get beautifulExcelReportDescription =>
      'Planilha colorida e linda com gráficos, emojis e insights ✨';

  @override
  String get excelReportIncludes => 'O relatório Excel inclui:';

  @override
  String get summarySheetDescription =>
      '📊 Folha de Resumo - Métricas principais com tendências';

  @override
  String get dailyBreakdownDescription =>
      '📅 Detalhamento Diário - Padrões de uso visual';

  @override
  String get appsSheetDescription =>
      '📱 Folha de Apps - Rankings detalhados de aplicativos';

  @override
  String get insightsDescription => '💡 Insights - Recomendações inteligentes';

  @override
  String get beautifulExcelExportSuccess =>
      'Lindo relatório Excel exportado com sucesso! 🎉';

  @override
  String failedToExportReport(String error) {
    return 'Falha ao exportar relatório: $error';
  }

  @override
  String get exporting => 'Exportando...';

  @override
  String get exportExcel => 'Exportar Excel';

  @override
  String get saveAnalyticsReport => 'Salvar Relatório de Análise';

  @override
  String analyticsReportFileName(String timestamp) {
    return 'relatorio_analitico_$timestamp.xlsx';
  }

  @override
  String get usageAnalyticsReportTitle => 'RELATÓRIO DE ANÁLISE DE USO';

  @override
  String get generated => 'Gerado:';

  @override
  String get period => 'Período:';

  @override
  String dateRangeValue(String startDate, String endDate) {
    return '$startDate a $endDate';
  }

  @override
  String get keyMetrics => 'MÉTRICAS PRINCIPAIS';

  @override
  String get metric => 'Métrica';

  @override
  String get value => 'Valor';

  @override
  String get change => 'Mudança';

  @override
  String get trend => 'Tendência';

  @override
  String get productivityRate => 'Taxa de Produtividade';

  @override
  String get trendUp => 'Subiu';

  @override
  String get trendDown => 'Desceu';

  @override
  String get trendExcellent => 'Excelente';

  @override
  String get trendGood => 'Bom';

  @override
  String get trendNeedsImprovement => 'Precisa Melhorar';

  @override
  String get trendActive => 'Ativo';

  @override
  String get trendNone => 'Nenhum';

  @override
  String get trendTop => 'Top';

  @override
  String get category => 'Categoria';

  @override
  String get percentage => 'Porcentagem';

  @override
  String get visual => 'Visual';

  @override
  String get statistics => 'ESTATÍSTICAS';

  @override
  String get averageDaily => 'Média Diária';

  @override
  String get highestDay => 'Dia Mais Alto';

  @override
  String get lowestDay => 'Dia Mais Baixo';

  @override
  String get day => 'Dia';

  @override
  String get applicationUsageDetails => 'DETALHES DE USO DE APLICATIVOS';

  @override
  String get totalApps => 'Total de Apps:';

  @override
  String get productiveApps => 'Apps Produtivos:';

  @override
  String get rank => 'Posição';

  @override
  String get application => 'Aplicativo';

  @override
  String get time => 'Tempo';

  @override
  String get percentOfTotal => '% do Total';

  @override
  String get type => 'Tipo';

  @override
  String get usageLevel => 'Nível de Uso';

  @override
  String get leisure => 'Lazer';

  @override
  String get usageLevelVeryHigh => 'Muito Alto ||||||||';

  @override
  String get usageLevelHigh => 'Alto ||||||';

  @override
  String get usageLevelMedium => 'Médio ||||';

  @override
  String get usageLevelLow => 'Baixo ||';

  @override
  String get keyInsightsTitle => 'PRINCIPAIS INSIGHTS E RECOMENDAÇÕES';

  @override
  String get personalizedRecommendations => 'RECOMENDAÇÕES PERSONALIZADAS';

  @override
  String insightHighDailyUsage(String hours) {
    return 'Alto Uso Diário: Você está usando em média $hours horas por dia de tempo de tela';
  }

  @override
  String insightLowDailyUsage(String hours) {
    return 'Baixo Uso Diário: Você está usando em média $hours horas por dia - ótimo equilíbrio!';
  }

  @override
  String insightModerateUsage(String hours) {
    return 'Uso Moderado: Média de $hours horas por dia de tempo de tela';
  }

  @override
  String insightExcellentProductivity(String percentage) {
    return 'Produtividade Excelente: $percentage% do seu tempo de tela é trabalho produtivo!';
  }

  @override
  String insightGoodProductivity(String percentage) {
    return 'Boa Produtividade: $percentage% do seu tempo de tela é produtivo';
  }

  @override
  String insightLowProductivity(String percentage) {
    return 'Alerta de Baixa Produtividade: Apenas $percentage% do tempo de tela é produtivo';
  }

  @override
  String insightFocusSessions(int count, String avgPerDay) {
    return 'Sessões de Foco: Completou $count sessões ($avgPerDay por dia em média)';
  }

  @override
  String insightGreatFocusHabit(int count) {
    return 'Ótimo Hábito de Foco: Você construiu uma incrível rotina de foco com $count sessões completadas!';
  }

  @override
  String get insightNoFocusSessions =>
      'Sem Sessões de Foco: Considere usar o modo foco para aumentar sua produtividade';

  @override
  String insightScreenTimeTrend(String direction, String percentage) {
    return 'Tendência de Tempo de Tela: Seu uso $direction $percentage% comparado ao período anterior';
  }

  @override
  String insightProductiveTimeTrend(String direction, String percentage) {
    return 'Tendência de Tempo Produtivo: Seu tempo produtivo $direction $percentage% comparado ao período anterior';
  }

  @override
  String get directionIncreased => 'aumentou';

  @override
  String get directionDecreased => 'diminuiu';

  @override
  String insightTopCategory(String category, String percentage) {
    return 'Categoria Principal: $category domina com $percentage% do seu tempo total';
  }

  @override
  String insightMostUsedApp(
      String appName, String percentage, String duration) {
    return 'App Mais Usado: $appName representa $percentage% do seu tempo ($duration)';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return 'O Uso Varia Significativamente: $highDay teve ${multiplier}x mais uso que $lowDay';
  }

  @override
  String get insightNoInsights => 'Nenhum insight significativo disponível';

  @override
  String get recScheduleFocusSessions =>
      'Tente agendar mais sessões de foco ao longo do dia para aumentar a produtividade';

  @override
  String get recSetAppLimits =>
      'Considere definir limites em aplicativos de lazer';

  @override
  String get recAimForFocusSessions =>
      'Mire em pelo menos 1-2 sessões de foco por dia para construir um hábito consistente';

  @override
  String get recTakeBreaks =>
      'Seu tempo de tela diário é bastante alto. Tente fazer pausas regulares usando a regra 20-20-20';

  @override
  String get recSetDailyGoals =>
      'Considere definir metas diárias de tempo de tela para reduzir gradualmente o uso';

  @override
  String get recBalanceEntertainment =>
      'Apps de entretenimento ocupam grande parte do seu tempo. Considere equilibrar com atividades mais produtivas';

  @override
  String get recReviewUsagePatterns =>
      'Seu tempo de tela aumentou significativamente. Revise seus padrões de uso e estabeleça limites';

  @override
  String get recScheduleFocusedWork =>
      'Seu tempo produtivo diminuiu. Tente agendar blocos de trabalho focado no seu calendário';

  @override
  String get recKeepUpGreatWork =>
      'Continue assim! Seus hábitos de tempo de tela parecem saudáveis';

  @override
  String get recContinueFocusSessions =>
      'Continue usando sessões de foco para manter a produtividade';

  @override
  String get sheetSummary => 'Resumo';

  @override
  String get sheetDailyBreakdown => 'Detalhamento Diário';

  @override
  String get sheetApps => 'Apps';

  @override
  String get sheetInsights => 'Insights';

  @override
  String get statusHeader => 'Status';

  @override
  String workSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões de trabalho',
      one: '$count sessão de trabalho',
    );
    return '$_temp0';
  }

  @override
  String get complete => 'Concluído';

  @override
  String get inProgress => 'Em andamento';

  @override
  String get workTime => 'Tempo de trabalho';

  @override
  String get breakTime => 'Tempo de pausa';

  @override
  String get phasesCompleted => 'Fases concluídas';

  @override
  String hourMinuteFormat(String hours, String minutes) {
    return '$hours h $minutes min';
  }

  @override
  String hourOnlyFormat(String hours) {
    return '$hours h';
  }

  @override
  String minuteFormat(String minutes) {
    return '$minutes min';
  }

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões',
      one: '$count sessão',
    );
    return '$_temp0';
  }

  @override
  String get workPhases => 'Fases de trabalho';

  @override
  String get averageLength => 'Duração média';

  @override
  String get mostProductive => 'Mais produtivo';

  @override
  String get work => 'Trabalho';

  @override
  String get breaks => 'Pausas';

  @override
  String get none => 'Nenhum';

  @override
  String minuteShortFormat(String minutes) {
    return '${minutes}m';
  }

  @override
  String get importTheme => 'Importar tema';

  @override
  String get exportTheme => 'Exportar tema';

  @override
  String get import => 'Importar';

  @override
  String get export => 'Exportar';

  @override
  String get chooseExportMethod => 'Escolha como exportar seu tema:';

  @override
  String get saveAsFile => 'Salvar como arquivo';

  @override
  String get saveThemeAsJSONFile =>
      'Salvar o tema como arquivo JSON no seu dispositivo';

  @override
  String get copyToClipboard => 'Copiar para a área de transferência';

  @override
  String get copyThemeJSONToClipboard =>
      'Copiar dados do tema para a área de transferência';

  @override
  String get share => 'Compartilhar';

  @override
  String get shareThemeViaSystemSheet =>
      'Compartilhar tema usando a folha de compartilhamento do sistema';

  @override
  String get chooseImportMethod => 'Escolha como importar um tema:';

  @override
  String get loadFromFile => 'Carregar de arquivo';

  @override
  String get selectJSONFileFromDevice =>
      'Selecione um arquivo JSON de tema do seu dispositivo';

  @override
  String get pasteFromClipboard => 'Colar da área de transferência';

  @override
  String get importFromClipboardJSON =>
      'Importar tema dos dados JSON da área de transferência';

  @override
  String get importFromFile => 'Importar tema de um arquivo';

  @override
  String get themeCreatedSuccessfully => 'Tema criado com sucesso!';

  @override
  String get themeUpdatedSuccessfully => 'Tema atualizado com sucesso!';

  @override
  String get themeDeletedSuccessfully => 'Tema excluído com sucesso!';

  @override
  String get themeExportedSuccessfully => 'Tema exportado com sucesso!';

  @override
  String get themeCopiedToClipboard =>
      'Tema copiado para a área de transferência!';

  @override
  String themeImportedSuccessfully(String themeName) {
    return 'Tema \"$themeName\" importado com sucesso!';
  }

  @override
  String get noThemeDataFound => 'Nenhum dado de tema encontrado';

  @override
  String get invalidThemeFormat =>
      'Formato de tema inválido. Por favor, verifique os dados JSON.';

  @override
  String get trackingModeTitle => 'Modo de Rastreamento';

  @override
  String get trackingModeDescription =>
      'Escolha como o uso do aplicativo é rastreado';

  @override
  String get trackingModePolling => 'Padrão (Baixo Consumo)';

  @override
  String get trackingModePrecise => 'Preciso (Alta Precisão)';

  @override
  String get trackingModePollingHint =>
      'Verifica a cada minuto - menor uso de recursos';

  @override
  String get trackingModePreciseHint =>
      'Rastreamento em tempo real - maior precisão, mais recursos';

  @override
  String get trackingModeChangeError =>
      'Falha ao alterar o modo de rastreamento. Por favor, tente novamente.';

  @override
  String get errorTitle => 'Erro';

  @override
  String get monitorKeyboardTitle => 'Monitorar Teclado';

  @override
  String get monitorKeyboardDescription =>
      'Rastrear atividade do teclado para detectar presença do usuário';

  @override
  String get changelogWhatsNew => 'Novidades';

  @override
  String changelogReleasedOn(String date) {
    return 'Lançado em $date';
  }

  @override
  String get changelogNoContent =>
      'Nenhum registro de alterações disponível para esta versão.';

  @override
  String get changelogUnableToLoad =>
      'Não foi possível carregar o registro de alterações';

  @override
  String get changelogErrorDescription =>
      'Não foi possível recuperar o registro de alterações desta versão. Verifique sua conexão com a internet ou visite a página de lançamentos do GitHub.';

  @override
  String get allTracking => 'Todos os apps';

  @override
  String get notTracking => 'Não monitorados';

  @override
  String get allVisibility => 'Todos';

  @override
  String get visible => 'Visíveis';

  @override
  String get hidden => 'Ocultos';

  @override
  String get todaysLimitUsage => 'Uso do limite de hoje';

  @override
  String get thisWeekAtAGlance => 'Resumo desta semana';

  @override
  String get hourlyActivityHeatmap => 'Mapa de calor de atividade por hora';

  @override
  String get productivityScore => 'Pontuação de produtividade';

  @override
  String get streaks => 'Sequências';

  @override
  String get weekOverWeek => 'Semana a semana';

  @override
  String get sameAsLastWeek => 'Igual à semana passada';

  @override
  String moreUsageThanLastWeek(String percent) {
    return '$percent% a mais que a semana passada';
  }

  @override
  String lessUsageThanLastWeek(String percent) {
    return '$percent% a menos que a semana passada';
  }

  @override
  String limitExceededBy(String duration) {
    return 'Limite excedido em $duration';
  }

  @override
  String timeRemaining(String duration) {
    return '$duration restante';
  }

  @override
  String get totalSessions => 'Total de sessões';

  @override
  String get avgSession => 'Sessão média';

  @override
  String get mostActive => 'Mais ativo';

  @override
  String get peakUsage => 'Pico de uso';

  @override
  String get dailyAverage => 'Média diária';

  @override
  String get daysUsedInARow => 'Dias de uso consecutivos';

  @override
  String get daysSingular => 'dia';

  @override
  String get daysPlural => 'dias';

  @override
  String get daysOverLimitInARow => 'Dias consecutivos acima do limite';

  @override
  String get withinLimitAllWeek => 'Dentro do limite a semana toda';

  @override
  String get productivityScoreGreat => 'Ótimo';

  @override
  String get productivityScoreModerate => 'Moderado';

  @override
  String get productivityScoreNeedsAttention => 'Precisa de atenção';

  @override
  String get productiveAppMotivation => 'App produtivo — continue assim';

  @override
  String get nonProductiveAppSuggestion =>
      'Não produtivo — considere reduzir o uso';

  @override
  String get legendUsage => 'Uso';

  @override
  String get legendAverage => 'Média';

  @override
  String get legendLimit => 'Limite';

  @override
  String get chartPeak => 'Pico';

  @override
  String overLimitBy(String duration) {
    return '+$duration acima do limite';
  }

  @override
  String get noData => 'Sem dados';

  @override
  String get yesterday => 'Ontem';

  @override
  String get changelog => 'Changelog';
}
