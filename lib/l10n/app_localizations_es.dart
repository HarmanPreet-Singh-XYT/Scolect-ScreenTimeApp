// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appWindowTitle =>
      'Scolect - Seguimiento de Tiempo de Pantalla y Uso de Aplicaciones';

  @override
  String get appName => 'Scolect';

  @override
  String get appTitle => 'Tiempo de Pantalla Productivo';

  @override
  String get sidebarTitle => 'Tiempo de Pantalla';

  @override
  String get sidebarSubtitle => 'Código Abierto';

  @override
  String get trayShowWindow => 'Mostrar Ventana';

  @override
  String get trayStartFocusMode => 'Iniciar Modo Enfoque';

  @override
  String get trayStopFocusMode => 'Detener Modo Enfoque';

  @override
  String get trayReports => 'Informes';

  @override
  String get trayAlertsLimits => 'Alertas y Límites';

  @override
  String get trayApplications => 'Aplicaciones';

  @override
  String get trayDisableNotifications => 'Desactivar Notificaciones';

  @override
  String get trayEnableNotifications => 'Activar Notificaciones';

  @override
  String get trayVersionPrefix => 'Versión: ';

  @override
  String trayVersion(String version) {
    return 'Versión: $version';
  }

  @override
  String get trayExit => 'Salir';

  @override
  String get navOverview => 'Resumen';

  @override
  String get navApplications => 'Aplicaciones';

  @override
  String get navAlertsLimits => 'Alertas y Límites';

  @override
  String get navReports => 'Informes';

  @override
  String get navFocusMode => 'Modo Enfoque';

  @override
  String get navSettings => 'Configuración';

  @override
  String get navHelp => 'Ayuda';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get faqCategoryGeneral => 'Preguntas Generales';

  @override
  String get faqCategoryApplications => 'Gestión de Aplicaciones';

  @override
  String get faqCategoryReports => 'Análisis de Uso e Informes';

  @override
  String get faqCategoryAlerts => 'Alertas y Límites';

  @override
  String get faqCategoryFocusMode => 'Modo Enfoque y Temporizador Pomodoro';

  @override
  String get faqCategorySettings => 'Configuración y Personalización';

  @override
  String get faqCategoryTroubleshooting => 'Solución de Problemas';

  @override
  String get faqGeneralQ1 =>
      '¿Cómo rastrea esta aplicación el tiempo de pantalla?';

  @override
  String get faqGeneralA1 =>
      'La aplicación monitorea el uso de tu dispositivo en tiempo real, rastreando el tiempo dedicado a diferentes aplicaciones. Proporciona información completa sobre tus hábitos digitales, incluyendo tiempo total de pantalla, tiempo productivo y uso específico por aplicación.';

  @override
  String get faqGeneralQ2 => '¿Qué hace que una aplicación sea \'Productiva\'?';

  @override
  String get faqGeneralA2 =>
      'Puedes marcar manualmente las aplicaciones como productivas en la sección \'Aplicaciones\'. Las aplicaciones productivas contribuyen a tu Puntuación de Productividad, que calcula el porcentaje de tiempo de pantalla dedicado a aplicaciones relacionadas con el trabajo o beneficiosas.';

  @override
  String get faqGeneralQ3 =>
      '¿Qué tan preciso es el seguimiento del tiempo de pantalla?';

  @override
  String get faqGeneralA3 =>
      'La aplicación utiliza seguimiento a nivel del sistema para proporcionar una medición precisa del uso de tu dispositivo. Captura el tiempo en primer plano de cada aplicación con un impacto mínimo en la batería.';

  @override
  String get faqGeneralQ4 =>
      '¿Puedo personalizar la categorización de mis aplicaciones?';

  @override
  String get faqGeneralA4 =>
      '¡Por supuesto! Puedes crear categorías personalizadas, asignar aplicaciones a categorías específicas y modificar fácilmente estas asignaciones en la sección \'Aplicaciones\'. Esto ayuda a crear análisis de uso más significativos.';

  @override
  String get faqGeneralQ5 =>
      '¿Qué información puedo obtener de esta aplicación?';

  @override
  String get faqGeneralA5 =>
      'La aplicación ofrece información completa que incluye Puntuación de Productividad, patrones de uso por hora del día, uso detallado de aplicaciones, seguimiento de sesiones de enfoque y análisis visuales como gráficos y diagramas circulares para ayudarte a entender y mejorar tus hábitos digitales.';

  @override
  String get faqAppsQ1 =>
      '¿Cómo oculto aplicaciones específicas del seguimiento?';

  @override
  String get faqAppsA1 =>
      'En la sección \'Aplicaciones\', puedes alternar la visibilidad de las aplicaciones.';

  @override
  String get faqAppsQ2 => '¿Puedo buscar y filtrar mis aplicaciones?';

  @override
  String get faqAppsA2 =>
      'Sí, la sección de Aplicaciones incluye funcionalidad de búsqueda y opciones de filtrado. Puedes filtrar aplicaciones por categoría, estado de productividad, estado de seguimiento y visibilidad.';

  @override
  String get faqAppsQ3 =>
      '¿Qué opciones de edición están disponibles para las aplicaciones?';

  @override
  String get faqAppsA3 =>
      'Para cada aplicación, puedes editar: asignación de categoría, estado de productividad, seguimiento de uso, visibilidad en informes y establecer límites de tiempo diarios individuales.';

  @override
  String get faqAppsQ4 =>
      '¿Cómo se determinan las categorías de las aplicaciones?';

  @override
  String get faqAppsA4 =>
      'Las categorías iniciales son sugeridas por el sistema, pero tienes control total para crear, modificar y asignar categorías personalizadas según tu flujo de trabajo y preferencias.';

  @override
  String get faqReportsQ1 => '¿Qué tipos de informes están disponibles?';

  @override
  String get faqReportsA1 =>
      'Los informes incluyen: Tiempo total de pantalla, Tiempo productivo, Aplicaciones más usadas, Sesiones de enfoque, Gráfico de tiempo de pantalla diario, Gráfico circular de desglose por categoría, Uso detallado de aplicaciones, Tendencias de uso semanal y Análisis de patrones de uso por hora del día.';

  @override
  String get faqReportsQ2 =>
      '¿Qué tan detallados son los informes de uso de aplicaciones?';

  @override
  String get faqReportsA2 =>
      'Los informes detallados de uso de aplicaciones muestran: Nombre de la aplicación, Categoría, Tiempo total dedicado, Estado de productividad, y ofrecen una sección de \'Acciones\' con información más profunda como resumen de uso, límites diarios, tendencias de uso y métricas de productividad.';

  @override
  String get faqReportsQ3 =>
      '¿Puedo analizar mis tendencias de uso a lo largo del tiempo?';

  @override
  String get faqReportsA3 =>
      '¡Sí! La aplicación proporciona comparaciones semana a semana, mostrando gráficos de uso de semanas anteriores, uso diario promedio, sesiones más largas y totales semanales para ayudarte a rastrear tus hábitos digitales.';

  @override
  String get faqReportsQ4 => '¿Qué es el análisis de \'Patrón de Uso\'?';

  @override
  String get faqReportsA4 =>
      'El Patrón de Uso desglosa tu tiempo de pantalla en segmentos de mañana, tarde, noche y noche. Esto te ayuda a entender cuándo estás más activo en tu dispositivo e identificar áreas potenciales de mejora.';

  @override
  String get faqAlertsQ1 =>
      '¿Qué tan detallados son los límites de tiempo de pantalla?';

  @override
  String get faqAlertsA1 =>
      'Puedes establecer límites generales de tiempo de pantalla diario y límites individuales por aplicación. Los límites se pueden configurar en horas y minutos, con opciones para restablecer o ajustar según sea necesario.';

  @override
  String get faqAlertsQ2 => '¿Qué opciones de notificación están disponibles?';

  @override
  String get faqAlertsA2 =>
      'La aplicación ofrece múltiples tipos de notificaciones: Alertas del sistema cuando excedes el tiempo de pantalla, Alertas frecuentes a intervalos personalizables (1, 5, 15, 30 o 60 minutos), y opciones para modo enfoque, tiempo de pantalla y notificaciones específicas de aplicaciones.';

  @override
  String get faqAlertsQ3 => '¿Puedo personalizar las alertas de límites?';

  @override
  String get faqAlertsA3 =>
      'Sí, puedes personalizar la frecuencia de alertas, activar/desactivar tipos específicos de alertas y establecer diferentes límites para el tiempo de pantalla general y aplicaciones individuales.';

  @override
  String get faqFocusQ1 => '¿Qué tipos de Modos de Enfoque están disponibles?';

  @override
  String get faqFocusA1 =>
      'Los modos disponibles incluyen Trabajo Profundo (sesiones de enfoque más largas), Tareas Rápidas (ráfagas cortas de trabajo) y Modo Lectura. Cada modo te ayuda a estructurar tu trabajo y tiempos de descanso de manera efectiva.';

  @override
  String get faqFocusQ2 => '¿Qué tan flexible es el Temporizador Pomodoro?';

  @override
  String get faqFocusA2 =>
      'El temporizador es altamente personalizable. Puedes ajustar la duración del trabajo, la duración del descanso corto y la duración del descanso largo. Las opciones adicionales incluyen inicio automático para las siguientes sesiones y configuración de notificaciones.';

  @override
  String get faqFocusQ3 => '¿Qué muestra el historial del Modo Enfoque?';

  @override
  String get faqFocusA3 =>
      'El historial del Modo Enfoque rastrea las sesiones de enfoque diarias, mostrando el número de sesiones por día, gráfico de tendencias, duración promedio de sesión, tiempo total de enfoque y un gráfico circular de distribución del tiempo que desglosa sesiones de trabajo, descansos cortos y descansos largos.';

  @override
  String get faqFocusQ4 =>
      '¿Puedo rastrear el progreso de mis sesiones de enfoque?';

  @override
  String get faqFocusA4 =>
      'La aplicación cuenta con una interfaz de temporizador circular con botones de reproducir/pausar, reiniciar y configuración. Puedes rastrear y gestionar fácilmente tus sesiones de enfoque con controles intuitivos.';

  @override
  String get faqSettingsQ1 =>
      '¿Qué opciones de personalización están disponibles?';

  @override
  String get faqSettingsA1 =>
      'La personalización incluye selección de tema (Sistema, Claro, Oscuro), configuración de idioma, comportamiento de inicio, controles completos de notificaciones y opciones de gestión de datos como borrar datos o restablecer configuración.';

  @override
  String get faqSettingsQ2 =>
      '¿Cómo proporciono comentarios o informo problemas?';

  @override
  String get faqSettingsA2 =>
      'En la parte inferior de la sección de Configuración, encontrarás botones para Reportar un Error, Enviar Comentarios o Contactar Soporte. Estos te redirigirán a los canales de soporte apropiados.';

  @override
  String get faqSettingsQ3 => '¿Qué sucede cuando borro mis datos?';

  @override
  String get faqSettingsA3 =>
      'Borrar datos restablecerá todas tus estadísticas de uso, historial de sesiones de enfoque y configuración personalizada. Esto es útil para empezar de nuevo o solucionar problemas.';

  @override
  String get faqTroubleQ1 =>
      'Los datos no se muestran, error de que hive no se abre';

  @override
  String get faqTroubleA1 =>
      'El problema es conocido, la solución temporal es borrar los datos a través de configuración y si no funciona, ve a Documentos y elimina los siguientes archivos si existen - harman_screentime_app_usage_box.hive y harman_screentime_app_usage.lock, también se te sugiere actualizar la aplicación a la última versión.';

  @override
  String get faqTroubleQ2 =>
      'La aplicación se abre en cada inicio, ¿qué hacer?';

  @override
  String get faqTroubleA2 =>
      'Este es un problema conocido que ocurre en Windows 10, la solución temporal es habilitar Iniciar como Minimizado en la configuración para que se inicie minimizado.';

  @override
  String get usageAnalytics => 'Análisis de Uso';

  @override
  String get last7Days => 'Últimos 7 Días';

  @override
  String get lastMonth => 'Último Mes';

  @override
  String get last3Months => 'Últimos 3 Meses';

  @override
  String get lifetime => 'Todo el Tiempo';

  @override
  String get custom => 'Personalizado';

  @override
  String get loadingAnalyticsData => 'Cargando datos de análisis...';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get failedToInitialize =>
      'Error al inicializar análisis. Por favor reinicie la aplicación.';

  @override
  String unexpectedError(String error) {
    return 'Ocurrió un error inesperado: $error. Por favor intente más tarde.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Error al cargar datos de análisis: $error. Por favor verifique su conexión e intente de nuevo.';
  }

  @override
  String get customDialogTitle => 'Personalizado';

  @override
  String get dateRange => 'Rango de Fechas:';

  @override
  String get specificDate => 'Fecha Específica';

  @override
  String get startDate => 'Fecha de Inicio: ';

  @override
  String get endDate => 'Fecha de Fin: ';

  @override
  String get date => 'Fecha';

  @override
  String get cancel => 'Cancelar';

  @override
  String get apply => 'Aplicar';

  @override
  String get ok => 'Aceptar';

  @override
  String get invalidDateRange => 'Rango de Fechas Inválido';

  @override
  String get startDateBeforeEndDate =>
      'La fecha de inicio debe ser anterior o igual a la fecha de fin.';

  @override
  String get totalScreenTime => 'Tiempo de Pantalla Total';

  @override
  String get productiveTime => 'Tiempo Productivo';

  @override
  String get mostUsedApp => 'App Más Usada';

  @override
  String get focusSessions => 'Sesiones de Enfoque';

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
    return 'Icono de $title';
  }

  @override
  String get dailyScreenTime => 'TIEMPO DE PANTALLA DIARIO';

  @override
  String get categoryBreakdown => 'DESGLOSE POR CATEGORÍA';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String sectionLabel(String title) {
    return 'Sección $title';
  }

  @override
  String get detailedApplicationUsage => 'Uso Detallado de Aplicaciones';

  @override
  String get searchApplications => 'Buscar aplicaciones';

  @override
  String get nameHeader => 'Nombre';

  @override
  String get categoryHeader => 'Categoría';

  @override
  String get totalTimeHeader => 'Tiempo Total';

  @override
  String get productivityHeader => 'Productividad';

  @override
  String get actionsHeader => 'Acciones';

  @override
  String sortByOption(String option) {
    return 'Ordenar por: $option';
  }

  @override
  String get sortByName => 'Nombre';

  @override
  String get sortByCategory => 'Categoría';

  @override
  String get sortByUsage => 'Uso';

  @override
  String get productive => 'Productivo';

  @override
  String get nonProductive => 'No Productivo';

  @override
  String get noApplicationsMatch =>
      'Ninguna aplicación coincide con tus criterios de búsqueda';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get usageSummary => 'Resumen de Uso';

  @override
  String get usageOverPastWeek => 'Uso Durante la Semana Pasada';

  @override
  String get usagePatternByTimeOfDay => 'Patrón de Uso por Hora del Día';

  @override
  String get patternAnalysis => 'Análisis de Patrones';

  @override
  String get today => 'Hoy';

  @override
  String get dailyLimit => 'Límite Diario';

  @override
  String get noLimit => 'Sin límite';

  @override
  String get usageTrend => 'Tendencia de Uso';

  @override
  String get productivity => 'Productividad';

  @override
  String get increasing => 'Aumentando';

  @override
  String get decreasing => 'Disminuyendo';

  @override
  String get stable => 'Estable';

  @override
  String get avgDailyUsage => 'Uso Diario Prom.';

  @override
  String get longestSession => 'Sesión más larga';

  @override
  String get weeklyTotal => 'Total Semanal';

  @override
  String get noHistoricalData => 'No hay datos históricos disponibles';

  @override
  String get morning => 'Mañana (6-12)';

  @override
  String get afternoon => 'Tarde (12-5)';

  @override
  String get evening => 'Noche (5-9)';

  @override
  String get night => 'Madrugada (9-6)';

  @override
  String get usageInsights => 'Información de Uso';

  @override
  String get limitStatus => 'Estado del Límite';

  @override
  String get close => 'Cerrar';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'Usas principalmente $appName durante $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Tu uso ha aumentado significativamente ($percentage%) en comparación con el período anterior.';
  }

  @override
  String get trendingUpward =>
      'Tu uso está tendiendo al alza en comparación con el período anterior.';

  @override
  String significantDecrease(String percentage) {
    return 'Tu uso ha disminuido significativamente ($percentage%) en comparación con el período anterior.';
  }

  @override
  String get trendingDownward =>
      'Tu uso está tendiendo a la baja en comparación con el período anterior.';

  @override
  String get consistentUsage =>
      'Tu uso ha sido consistente en comparación con el período anterior.';

  @override
  String get markedAsProductive =>
      'Esta está marcada como una aplicación productiva en tu configuración.';

  @override
  String get markedAsNonProductive =>
      'Esta está marcada como una aplicación no productiva en tu configuración.';

  @override
  String mostActiveTime(String time) {
    return 'Tu hora más activa es alrededor de las $time.';
  }

  @override
  String get noLimitSet =>
      'No se ha establecido límite de uso para esta aplicación.';

  @override
  String get limitReached =>
      'Has alcanzado tu límite diario para esta aplicación.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'Estás a punto de alcanzar tu límite diario con solo $remainingTime restante.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'Has usado el $percent% de tu límite diario con $remainingTime restante.';
  }

  @override
  String remainingTime(String time) {
    return 'Te quedan $time de tu límite diario.';
  }

  @override
  String get todayChart => 'Hoy';

  @override
  String hourPeriodAM(int hour) {
    return '$hour AM';
  }

  @override
  String hourPeriodPM(int hour) {
    return '$hour PM';
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
  String get alertsLimitsTitle => 'Alertas y Límites';

  @override
  String get notificationsSettings => 'Configuración de Notificaciones';

  @override
  String get overallScreenTimeLimit => 'Límite General de Tiempo de Pantalla';

  @override
  String get applicationLimits => 'Límites de Aplicaciones';

  @override
  String get popupAlerts => 'Alertas Emergentes';

  @override
  String get frequentAlerts => 'Alertas Frecuentes';

  @override
  String get soundAlerts => 'Alertas de Sonido';

  @override
  String get systemAlerts => 'Alertas del Sistema';

  @override
  String get dailyTotalLimit => 'Límite Diario Total: ';

  @override
  String get hours => 'Horas';

  @override
  String get minutes => 'Minutos';

  @override
  String get currentUsage => 'Uso Actual: ';

  @override
  String get tableName => 'Nombre';

  @override
  String get tableCategory => 'Categoría';

  @override
  String get tableDailyLimit => 'Límite Diario';

  @override
  String get tableCurrentUsage => 'Uso Actual';

  @override
  String get tableStatus => 'Estado';

  @override
  String get tableActions => 'Acciones';

  @override
  String get addLimit => 'Agregar Límite';

  @override
  String get noApplicationsToDisplay => 'No hay aplicaciones para mostrar';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusOff => 'Desactivado';

  @override
  String get durationNone => 'Ninguno';

  @override
  String get addApplicationLimit => 'Agregar Límite de Aplicación';

  @override
  String get selectApplication => 'Seleccionar Aplicación';

  @override
  String get selectApplicationPlaceholder => 'Selecciona una aplicación';

  @override
  String get enableLimit => 'Habilitar Límite: ';

  @override
  String editLimitTitle(String appName) {
    return 'Editar Límite: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Error al cargar datos: $error';
  }

  @override
  String get resetSettingsTitle => '¿Restablecer Configuración?';

  @override
  String get resetSettingsContent =>
      'Si restableces la configuración, no podrás recuperarla. ¿Deseas restablecerla?';

  @override
  String get resetAll => 'Restablecer Todo';

  @override
  String get refresh => 'Actualizar';

  @override
  String get save => 'Guardar';

  @override
  String get add => 'Agregar';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get applicationsTitle => 'Aplicaciones';

  @override
  String get searchApplication => 'Buscar Aplicación';

  @override
  String get tracking => 'En seguimiento';

  @override
  String get hiddenVisible => 'Oculto/Visible';

  @override
  String get selectCategory => 'Seleccionar una Categoría';

  @override
  String get allCategories => 'Todas';

  @override
  String get tableScreenTime => 'Tiempo de Pantalla';

  @override
  String get tableTracking => 'Seguimiento';

  @override
  String get tableHidden => 'Oculto';

  @override
  String get tableEdit => 'Editar';

  @override
  String editAppTitle(String appName) {
    return 'Editar $appName';
  }

  @override
  String get categorySection => 'Categoría';

  @override
  String get customCategory => 'Personalizada';

  @override
  String get customCategoryPlaceholder =>
      'Ingresa nombre de categoría personalizada';

  @override
  String get uncategorized => 'Sin Categoría';

  @override
  String get isProductive => 'Es Productiva';

  @override
  String get trackUsage => 'Rastrear Uso';

  @override
  String get visibleInReports => 'Visible en Informes';

  @override
  String get timeLimitsSection => 'Límites de Tiempo';

  @override
  String get enableDailyLimit => 'Habilitar Límite Diario';

  @override
  String get setDailyTimeLimit => 'Establecer límite de tiempo diario:';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String errorLoadingData(String error) {
    return 'Error al cargar datos del resumen: $error';
  }

  @override
  String get focusModeTitle => 'Modo Enfoque';

  @override
  String get historySection => 'Historial';

  @override
  String get trendsSection => 'Tendencias';

  @override
  String get timeDistributionSection => 'Distribución del Tiempo';

  @override
  String get sessionHistorySection => 'Historial de Sesiones';

  @override
  String get workSession => 'Sesión de Trabajo';

  @override
  String get shortBreak => 'Descanso Corto';

  @override
  String get longBreak => 'Descanso Largo';

  @override
  String get dateHeader => 'Fecha';

  @override
  String get durationHeader => 'Duración';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get focusModeSettingsTitle => 'Configuración del Modo Enfoque';

  @override
  String get modeCustom => 'Personalizado';

  @override
  String get modeDeepWork => 'Trabajo Profundo (60 min)';

  @override
  String get modeQuickTasks => 'Tareas Rápidas (25 min)';

  @override
  String get modeReading => 'Lectura (45 min)';

  @override
  String workDurationLabel(int minutes) {
    return 'Duración del Trabajo: $minutes min';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Descanso Corto';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Descanso Largo';
  }

  @override
  String get autoStartNextSession =>
      'Iniciar automáticamente la siguiente sesión';

  @override
  String get blockDistractions =>
      'Bloquear distracciones durante el modo enfoque';

  @override
  String get enableNotifications => 'Habilitar notificaciones';

  @override
  String get saved => 'Guardado';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Error al cargar datos del modo enfoque: $error';
  }

  @override
  String get overviewTitle => 'Resumen de Hoy';

  @override
  String get startFocusMode => 'Iniciar Modo Enfoque';

  @override
  String get loadingProductivityData =>
      'Cargando tus datos de productividad...';

  @override
  String get noActivityDataAvailable =>
      'Aún no hay datos de actividad disponibles';

  @override
  String get startUsingApplications =>
      'Comienza a usar tus aplicaciones para rastrear el tiempo de pantalla y la productividad.';

  @override
  String get refreshData => 'Actualizar Datos';

  @override
  String get topApplications => 'Aplicaciones Principales';

  @override
  String get noAppUsageDataAvailable =>
      'Aún no hay datos de uso de aplicaciones disponibles';

  @override
  String get noApplicationDataAvailable =>
      'No hay datos de aplicaciones disponibles';

  @override
  String get noCategoryDataAvailable =>
      'No hay datos de categorías disponibles';

  @override
  String get noApplicationLimitsSet =>
      'No se han establecido límites de aplicaciones';

  @override
  String get screenLabel => 'Tiempo de';

  @override
  String get timeLabel => 'Pantalla';

  @override
  String get productiveLabel => 'Puntuación';

  @override
  String get scoreLabel => 'Productiva';

  @override
  String get defaultNone => 'Ninguno';

  @override
  String get defaultTime => '0h 0m';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Desconocido';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get generalSection => 'General';

  @override
  String get notificationsSection => 'Notificaciones';

  @override
  String get dataSection => 'Datos';

  @override
  String get versionSection => 'Versión';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageDescription => 'Idioma de la aplicación';

  @override
  String get startupBehaviourTitle => 'Comportamiento de Inicio';

  @override
  String get startupBehaviourDescription => 'Iniciar con el sistema operativo';

  @override
  String get launchMinimizedTitle => 'Iniciar Minimizado';

  @override
  String get launchMinimizedDescription =>
      'Iniciar la aplicación en la Bandeja del Sistema (Recomendado para Windows 10)';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsAllDescription =>
      'Todas las notificaciones de la aplicación';

  @override
  String get focusModeNotificationsTitle => 'Modo Enfoque';

  @override
  String get focusModeNotificationsDescription =>
      'Todas las notificaciones del modo enfoque';

  @override
  String get screenTimeNotificationsTitle => 'Tiempo de Pantalla';

  @override
  String get screenTimeNotificationsDescription =>
      'Todas las notificaciones de restricción de tiempo de pantalla';

  @override
  String get appScreenTimeNotificationsTitle =>
      'Tiempo de Pantalla por Aplicación';

  @override
  String get appScreenTimeNotificationsDescription =>
      'Todas las notificaciones de restricción de tiempo de pantalla por aplicación';

  @override
  String get frequentAlertsTitle => 'Intervalo de Alertas Frecuentes';

  @override
  String get frequentAlertsDescription =>
      'Establecer intervalo para notificaciones frecuentes (minutos)';

  @override
  String get clearDataTitle => 'Borrar Datos';

  @override
  String get clearDataDescription =>
      'Borrar todo el historial y otros datos relacionados';

  @override
  String get resetSettingsTitle2 => 'Restablecer Configuración';

  @override
  String get resetSettingsDescription => 'Restablecer toda la configuración';

  @override
  String get versionTitle => 'Versión';

  @override
  String get versionDescription => 'Versión actual de la aplicación';

  @override
  String get contactButton => 'Contacto';

  @override
  String get reportBugButton => 'Reportar Error';

  @override
  String get submitFeedbackButton => 'Enviar Comentarios';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => '¿Borrar Datos?';

  @override
  String get clearDataDialogContent =>
      'Esto borrará todo el historial y datos relacionados. No podrás recuperarlos. ¿Deseas continuar?';

  @override
  String get clearDataButtonLabel => 'Borrar Datos';

  @override
  String get resetSettingsDialogTitle => '¿Restablecer Configuración?';

  @override
  String get resetSettingsDialogContent =>
      'Esto restablecerá toda la configuración a sus valores predeterminados. ¿Deseas continuar?';

  @override
  String get resetButtonLabel => 'Restablecer';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String couldNotLaunchUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get chart_focusTrends => 'Tendencias de Enfoque';

  @override
  String get chart_sessionCount => 'Cantidad de Sesiones';

  @override
  String get chart_avgDuration => 'Duración Prom.';

  @override
  String get chart_totalFocus => 'Enfoque Total';

  @override
  String get chart_yAxis_sessions => 'Sesiones';

  @override
  String get chart_yAxis_minutes => 'Minutos';

  @override
  String get chart_yAxis_value => 'Valor';

  @override
  String get chart_monthOverMonthChange => 'Cambio mes a mes: ';

  @override
  String get chart_customRange => 'Rango Personalizado';

  @override
  String get day_monday => 'Lunes';

  @override
  String get day_mondayShort => 'Lun';

  @override
  String get day_mondayAbbr => 'Lu';

  @override
  String get day_tuesday => 'Martes';

  @override
  String get day_tuesdayShort => 'Mar';

  @override
  String get day_tuesdayAbbr => 'Ma';

  @override
  String get day_wednesday => 'Miércoles';

  @override
  String get day_wednesdayShort => 'Mié';

  @override
  String get day_wednesdayAbbr => 'Mi';

  @override
  String get day_thursday => 'Jueves';

  @override
  String get day_thursdayShort => 'Jue';

  @override
  String get day_thursdayAbbr => 'Ju';

  @override
  String get day_friday => 'Viernes';

  @override
  String get day_fridayShort => 'Vie';

  @override
  String get day_fridayAbbr => 'Vi';

  @override
  String get day_saturday => 'Sábado';

  @override
  String get day_saturdayShort => 'Sáb';

  @override
  String get day_saturdayAbbr => 'Sá';

  @override
  String get day_sunday => 'Domingo';

  @override
  String get day_sundayShort => 'Dom';

  @override
  String get day_sundayAbbr => 'Do';

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
  String get month_january => 'Enero';

  @override
  String get month_januaryShort => 'Ene';

  @override
  String get month_february => 'Febrero';

  @override
  String get month_februaryShort => 'Feb';

  @override
  String get month_march => 'Marzo';

  @override
  String get month_marchShort => 'Mar';

  @override
  String get month_april => 'Abril';

  @override
  String get month_aprilShort => 'Abr';

  @override
  String get month_may => 'Mayo';

  @override
  String get month_mayShort => 'May';

  @override
  String get month_june => 'Junio';

  @override
  String get month_juneShort => 'Jun';

  @override
  String get month_july => 'Julio';

  @override
  String get month_julyShort => 'Jul';

  @override
  String get month_august => 'Agosto';

  @override
  String get month_augustShort => 'Ago';

  @override
  String get month_september => 'Septiembre';

  @override
  String get month_septemberShort => 'Sep';

  @override
  String get month_october => 'Octubre';

  @override
  String get month_octoberShort => 'Oct';

  @override
  String get month_november => 'Noviembre';

  @override
  String get month_novemberShort => 'Nov';

  @override
  String get month_december => 'Diciembre';

  @override
  String get month_decemberShort => 'Dic';

  @override
  String get categoryAll => 'Todas';

  @override
  String get categoryProductivity => 'Productividad';

  @override
  String get categoryDevelopment => 'Desarrollo';

  @override
  String get categorySocialMedia => 'Redes Sociales';

  @override
  String get categoryEntertainment => 'Entretenimiento';

  @override
  String get categoryGaming => 'Juegos';

  @override
  String get categoryCommunication => 'Comunicación';

  @override
  String get categoryWebBrowsing => 'Navegación Web';

  @override
  String get categoryCreative => 'Creatividad';

  @override
  String get categoryEducation => 'Educación';

  @override
  String get categoryUtility => 'Utilidades';

  @override
  String get categoryUncategorized => 'Sin Categoría';

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
  String get appGoogleCalendar => 'Google Calendar';

  @override
  String get appAppleCalendar => 'Calendario';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'Terminal';

  @override
  String get appCommandPrompt => 'Símbolo del Sistema';

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
  String get appSystemPreferences => 'Preferencias del Sistema';

  @override
  String get appTaskManager => 'Administrador de Tareas';

  @override
  String get appFileExplorer => 'Explorador de Archivos';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';

  @override
  String get loadingApplication => 'Cargando la aplicación...';

  @override
  String get loadingData => 'Cargando datos...';

  @override
  String get reportsError => 'Error';

  @override
  String get reportsRetry => 'Reintentar';

  @override
  String get backupRestoreSection => 'Copia de seguridad y restauración';

  @override
  String get backupRestoreTitle => 'Copia de seguridad y restauración';

  @override
  String get exportDataTitle => 'Exportar datos';

  @override
  String get exportDataDescription =>
      'Crear una copia de seguridad de todos tus datos';

  @override
  String get importDataTitle => 'Importar datos';

  @override
  String get importDataDescription =>
      'Restaurar desde un archivo de copia de seguridad';

  @override
  String get exportButton => 'Exportar';

  @override
  String get importButton => 'Importar';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get noButton => 'No';

  @override
  String get shareButton => 'Compartir';

  @override
  String get exportStarting => 'Iniciando exportación...';

  @override
  String get exportSuccessful => 'Exportación Exitosa';

  @override
  String get exportFailed => 'Exportación Fallida';

  @override
  String get exportComplete => 'Exportación completada';

  @override
  String get shareBackupQuestion =>
      '¿Te gustaría compartir el archivo de copia de seguridad?';

  @override
  String get importStarting => 'Iniciando importación...';

  @override
  String get importSuccessful => '¡Importación exitosa!';

  @override
  String get importFailed => 'Error en la importación';

  @override
  String get importOptionsTitle => 'Opciones de importación';

  @override
  String get importOptionsQuestion => '¿Cómo te gustaría importar los datos?';

  @override
  String get replaceModeTitle => 'Reemplazar';

  @override
  String get replaceModeDescription => 'Reemplazar todos los datos existentes';

  @override
  String get mergeModeTitle => 'Fusionar';

  @override
  String get mergeModeDescription => 'Combinar con los datos existentes';

  @override
  String get appendModeTitle => 'Añadir';

  @override
  String get appendModeDescription => 'Solo agregar nuevos registros';

  @override
  String get warningTitle => '⚠️ Advertencia';

  @override
  String get replaceWarningMessage =>
      'Esto reemplazará TODOS tus datos existentes. ¿Estás seguro de que deseas continuar?';

  @override
  String get replaceAllButton => 'Reemplazar todo';

  @override
  String get fileLabel => 'Archivo';

  @override
  String get sizeLabel => 'Tamaño';

  @override
  String get recordsLabel => 'Registros';

  @override
  String get usageRecordsLabel => 'Registros de uso';

  @override
  String get focusSessionsLabel => 'Sesiones de concentración';

  @override
  String get appMetadataLabel => 'Metadatos de la aplicación';

  @override
  String get updatedLabel => 'Actualizado';

  @override
  String get skippedLabel => 'Omitido';

  @override
  String get faqSettingsQ4 => '¿Cómo puedo restaurar o exportar mis datos?';

  @override
  String get faqSettingsA4 =>
      'Puedes ir a configuración, y allí encontrarás la sección de Copia de seguridad y restauración. Puedes exportar o importar datos desde aquí. Ten en cuenta que el archivo de datos exportado se guarda en Documentos en la carpeta Scolect-Backups y solo este archivo puede ser usado para restaurar datos, ningún otro archivo.';

  @override
  String get faqGeneralQ6 =>
      '¿Cómo puedo cambiar el idioma y qué idiomas están disponibles? ¿Y si encuentro que la traducción es incorrecta?';

  @override
  String get faqGeneralA6 =>
      'El idioma se puede cambiar en la sección General de configuración, todos los idiomas disponibles están listados allí. Puedes solicitar una traducción haciendo clic en Contacto y enviando tu solicitud con el idioma deseado. Ten en cuenta que la traducción puede ser incorrecta ya que es generada por IA desde el inglés. Si deseas reportar un error, puedes hacerlo a través de reportar error, contacto, o si eres desarrollador, abrir un problema en Github. ¡Las contribuciones relacionadas con idiomas también son bienvenidas!';

  @override
  String get faqGeneralQ7 => '¿Y si encuentro que la traducción es incorrecta?';

  @override
  String get faqGeneralA7 =>
      'La traducción puede ser incorrecta ya que es generada por IA desde el inglés. Si deseas reportar un error, puedes hacerlo a través de reportar error, contacto, o si eres desarrollador, abrir un problema en Github. ¡Las contribuciones relacionadas con idiomas también son bienvenidas!';

  @override
  String get activityTrackingSection => 'Seguimiento de Actividad';

  @override
  String get idleDetectionTitle => 'Detección de Inactividad';

  @override
  String get idleDetectionDescription =>
      'Dejar de rastrear cuando esté inactivo';

  @override
  String get idleTimeoutTitle => 'Tiempo de Inactividad';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'Tiempo antes de considerarte inactivo ($timeout)';
  }

  @override
  String get advancedWarning =>
      'Las funciones avanzadas pueden aumentar el uso de recursos. Habilitar solo si es necesario.';

  @override
  String get monitorAudioTitle => 'Monitorear Audio del Sistema';

  @override
  String get monitorAudioDescription =>
      'Detectar actividad por reproducción de audio';

  @override
  String get audioSensitivityTitle => 'Sensibilidad de Audio';

  @override
  String audioSensitivityDescription(String value) {
    return 'Umbral de detección ($value)';
  }

  @override
  String get monitorControllersTitle => 'Monitorear Controladores de Juego';

  @override
  String get monitorControllersDescription =>
      'Detectar controladores Xbox/XInput';

  @override
  String get monitorHIDTitle => 'Monitorear Dispositivos HID';

  @override
  String get monitorHIDDescription =>
      'Detectar volantes, tabletas, dispositivos personalizados';

  @override
  String get setIdleTimeoutTitle => 'Establecer Tiempo de Inactividad';

  @override
  String get idleTimeoutDialogDescription =>
      'Elige cuánto tiempo esperar antes de considerarte inactivo:';

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
  String get customDurationTitle => 'Duración Personalizada';

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
    return 'El mínimo es $value';
  }

  @override
  String maximumError(String value) {
    return 'El máximo es $value';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'Rango: $min - $max';
  }

  @override
  String get saveButton => 'Guardar';

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
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeDescription => 'Tema de color de la aplicación';

  @override
  String get voiceGenderTitle => 'Género de voz';

  @override
  String get voiceGenderDescription =>
      'Elige el género de voz para las notificaciones del temporizador';

  @override
  String get voiceGenderMale => 'Masculino';

  @override
  String get voiceGenderFemale => 'Femenino';

  @override
  String get alertsLimitsSubtitle =>
      'Gestiona tus límites de tiempo de pantalla y notificaciones';

  @override
  String get applicationsSubtitle => 'Gestiona tus aplicaciones rastreadas';

  @override
  String applicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aplicaciones',
      one: '1 aplicación',
    );
    return '$_temp0';
  }

  @override
  String get noApplicationsFound => 'No se encontraron aplicaciones';

  @override
  String get tryAdjustingFilters => 'Intenta ajustar tus filtros';

  @override
  String get configureAppSettings => 'Configurar ajustes de la aplicación';

  @override
  String get behaviorSection => 'Comportamiento';

  @override
  String helpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preguntas en 7 categorías',
      one: '1 pregunta en 7 categorías',
    );
    return '$_temp0';
  }

  @override
  String get searchForHelp => 'Buscar ayuda...';

  @override
  String get quickNavGeneral => 'General';

  @override
  String get quickNavApps => 'Aplicaciones';

  @override
  String get quickNavReports => 'Informes';

  @override
  String get quickNavFocus => 'Enfoque';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get tryDifferentKeywords =>
      'Intenta buscar con diferentes palabras clave';

  @override
  String get clearSearch => 'Limpiar Búsqueda';

  @override
  String get greetingMorning =>
      '¡Buenos días! Aquí está tu resumen de actividad.';

  @override
  String get greetingAfternoon =>
      '¡Buenas tardes! Aquí está tu resumen de actividad.';

  @override
  String get greetingEvening =>
      '¡Buenas noches! Aquí está tu resumen de actividad.';

  @override
  String get screenTimeProgress => 'Tiempo de\nPantalla';

  @override
  String get productiveScoreProgress => 'Puntuación\nProductiva';

  @override
  String get focusModeSubtitle => 'Mantén el enfoque, sé productivo';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get sessions => 'Sesiones';

  @override
  String get totalTime => 'Tiempo total';

  @override
  String get avgLength => 'Duración Media';

  @override
  String get focusTime => 'Tiempo de Enfoque';

  @override
  String get paused => 'Pausado';

  @override
  String get shortBreakStatus => 'Descanso Corto';

  @override
  String get longBreakStatus => 'Descanso Largo';

  @override
  String get readyToFocus => 'Listo para Enfocar';

  @override
  String get focus => 'Enfoque';

  @override
  String get restartSession => 'Reiniciar Sesión';

  @override
  String get skipToNext => 'Saltar al Siguiente';

  @override
  String get settings => 'Configuración';

  @override
  String sessionsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones completadas',
      one: '1 sesión completada',
    );
    return '$_temp0';
  }

  @override
  String get focusModePreset => 'Preset de Modo de Enfoque';

  @override
  String get focusDuration => 'Duración de Enfoque';

  @override
  String minutesFormat(int minutes) {
    return '$minutes min';
  }

  @override
  String get shortBreakDuration => 'Descanso Corto';

  @override
  String get longBreakDuration => 'Descanso Largo';

  @override
  String get enableSounds => 'Activar Sonidos';

  @override
  String get focus_mode_this_week => 'Esta Semana';

  @override
  String get focus_mode_best_day => 'Mejor Día';

  @override
  String focus_mode_sessions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones',
      one: '1 sesión',
      zero: '0 sesiones',
    );
    return '$_temp0';
  }

  @override
  String get focus_mode_no_data_yet => 'Sin datos aún';

  @override
  String get chart_current => 'Actual';

  @override
  String get chart_previous => 'Anterior';

  @override
  String get permission_error => 'Error de Permiso';

  @override
  String get notification_permission_denied =>
      'Permiso de Notificación Denegado';

  @override
  String get notification_permission_denied_message =>
      'ScreenTime necesita permiso de notificación para enviarle alertas y recordatorios.\n\n¿Desea abrir la Configuración del Sistema para habilitar las notificaciones?';

  @override
  String get notification_permission_denied_hint =>
      'Abra la Configuración del Sistema para habilitar las notificaciones de ScreenTime.';

  @override
  String get notification_permission_required =>
      'Permiso de Notificación Requerido';

  @override
  String get notification_permission_required_message =>
      'ScreenTime necesita permiso para enviarle notificaciones.';

  @override
  String get open_settings => 'Abrir Configuración';

  @override
  String get allow_notifications => 'Permitir Notificaciones';

  @override
  String get permission_allowed => 'Permitido';

  @override
  String get permission_denied => 'Denegado';

  @override
  String get permission_not_set => 'No Configurado';

  @override
  String get on => 'Activado';

  @override
  String get off => 'Desactivado';

  @override
  String get enable_notification_permission_hint =>
      'Habilite el permiso de notificación para recibir alertas';

  @override
  String minutes_format(int minutes) {
    return '$minutes min';
  }

  @override
  String get chart_average => 'Promedio';

  @override
  String get chart_peak => 'Pico';

  @override
  String get chart_lowest => 'Más bajo';

  @override
  String get active => 'Activo';

  @override
  String get disabled => 'Deshabilitado';

  @override
  String get advanced_options => 'Opciones Avanzadas';

  @override
  String get sync_ready => 'Sincronización Lista';

  @override
  String get success => 'Éxito';

  @override
  String get destructive_badge => 'Destructivo';

  @override
  String get recommended_badge => 'Recomendado';

  @override
  String get safe_badge => 'Seguro';

  @override
  String get overview => 'Resumen';

  @override
  String get patterns => 'Patrones';

  @override
  String get apps => 'Aplicaciones';

  @override
  String get sortAscending => 'Ordenar Ascendente';

  @override
  String get sortDescending => 'Ordenar Descendente';

  @override
  String applicationsShowing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aplicaciones mostrando',
      one: '1 aplicación mostrando',
      zero: '0 aplicaciones mostrando',
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
      other: '$count aplicaciones',
      one: '1 aplicación',
      zero: '0 aplicaciones',
    );
    return '$_temp0';
  }

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categorías',
      one: '1 categoría',
      zero: '0 categorías',
    );
    return '$_temp0';
  }

  @override
  String get systemNotificationsDisabled =>
      'Las notificaciones del sistema están deshabilitadas. Habilítalas en Configuración del sistema para las alertas de enfoque.';

  @override
  String get openSystemSettings => 'Abrir Configuración del Sistema';

  @override
  String get appNotificationsDisabled =>
      'Las notificaciones están deshabilitadas en la configuración de la aplicación. Habilítalas para recibir alertas de enfoque.';

  @override
  String get goToSettings => 'Ir a Configuración';

  @override
  String get focusModeNotificationsDisabled =>
      'Las notificaciones del modo de enfoque están deshabilitadas. Habilítalas para recibir alertas de sesión.';

  @override
  String get notificationsDisabled => 'Notificaciones Deshabilitadas';

  @override
  String get dontShowAgain => 'No volver a mostrar';

  @override
  String get systemSettingsRequired => 'Configuración del Sistema Requerida';

  @override
  String get notificationsDisabledSystemLevel =>
      'Las notificaciones están deshabilitadas a nivel del sistema. Para habilitar:';

  @override
  String get step1OpenSystemSettings =>
      '1. Abrir Configuración del Sistema (Preferencias del Sistema)';

  @override
  String get step2GoToNotifications => '2. Ir a Notificaciones';

  @override
  String get step3FindApp => '3. Buscar y seleccionar Scolect';

  @override
  String get step4EnableNotifications =>
      '4. Habilitar \"Permitir notificaciones\"';

  @override
  String get returnToAppMessage =>
      'Luego regresa a esta aplicación y las notificaciones funcionarán.';

  @override
  String get gotIt => 'Entendido';

  @override
  String get noSessionsYet => 'Aún no hay sesiones';

  @override
  String applicationsTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aplicaciones rastreadas',
      one: '1 aplicación rastreada',
      zero: '0 aplicaciones rastreadas',
    );
    return '$_temp0';
  }

  @override
  String get applicationHeader => 'Aplicación';

  @override
  String get currentUsageHeader => 'Uso Actual';

  @override
  String get dailyLimitHeader => 'Límite Diario';

  @override
  String get edit => 'Editar';

  @override
  String get showPopupNotifications => 'Mostrar notificaciones emergentes';

  @override
  String get moreFrequentReminders => 'Recordatorios más frecuentes';

  @override
  String get playSoundWithAlerts => 'Reproducir sonido con alertas';

  @override
  String get systemTrayNotifications =>
      'Notificaciones en la bandeja del sistema';

  @override
  String screenTimeUsed(String current, String limit) {
    return '$current / $limit usado';
  }

  @override
  String get todaysScreenTime => 'Tiempo de Pantalla de Hoy';

  @override
  String get activeLimits => 'Límites Activos';

  @override
  String get nearLimit => 'Cerca del Límite';

  @override
  String get colorPickerSpectrum => 'Espectro';

  @override
  String get colorPickerPresets => 'Preajustes';

  @override
  String get colorPickerSliders => 'Deslizadores';

  @override
  String get colorPickerBasicColors => 'Colores Básicos';

  @override
  String get colorPickerExtendedPalette => 'Paleta Extendida';

  @override
  String get colorPickerRed => 'Rojo';

  @override
  String get colorPickerGreen => 'Verde';

  @override
  String get colorPickerBlue => 'Azul';

  @override
  String get colorPickerHue => 'Matiz';

  @override
  String get colorPickerSaturation => 'Saturación';

  @override
  String get colorPickerBrightness => 'Brillo';

  @override
  String get colorPickerHexColor => 'Color Hexadecimal';

  @override
  String get colorPickerHexPlaceholder => 'RRGGBB';

  @override
  String get colorPickerRGB => 'RGB';

  @override
  String get select => 'Seleccionar';

  @override
  String get themeCustomization => 'Personalización de Tema';

  @override
  String get chooseThemePreset => 'Elegir un Tema Predefinido';

  @override
  String get yourCustomThemes => 'Tus Temas Personalizados';

  @override
  String get createCustomTheme => 'Crear Tema Personalizado';

  @override
  String get designOwnColorScheme => 'Diseña tu propio esquema de colores';

  @override
  String get newTheme => 'Nuevo Tema';

  @override
  String get editCurrentTheme => 'Editar Tema Actual';

  @override
  String customizeColorsFor(String themeName) {
    return 'Personalizar colores para $themeName';
  }

  @override
  String customThemeNumber(int number) {
    return 'Tema Personalizado $number';
  }

  @override
  String get deleteCustomTheme => 'Eliminar Tema Personalizado';

  @override
  String confirmDeleteTheme(String themeName) {
    return '¿Estás seguro de que quieres eliminar \"$themeName\"?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get customizeTheme => 'Personalizar Tema';

  @override
  String get preview => 'Vista Previa';

  @override
  String get themeName => 'Nombre del Tema';

  @override
  String get brandColors => 'Colores de Marca';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Oscuro';

  @override
  String get reset => 'Restablecer';

  @override
  String get saveTheme => 'Guardar Tema';

  @override
  String get customTheme => 'Tema Personalizado';

  @override
  String get primaryColors => 'Colores Primarios';

  @override
  String get primaryColorsDesc =>
      'Colores de acento principales utilizados en toda la aplicación';

  @override
  String get primaryAccent => 'Acento Primario';

  @override
  String get primaryAccentDesc => 'Color principal de marca, botones, enlaces';

  @override
  String get secondaryAccent => 'Acento Secundario';

  @override
  String get secondaryAccentDesc => 'Acento complementario para degradados';

  @override
  String get semanticColors => 'Colores Semánticos';

  @override
  String get semanticColorsDesc =>
      'Colores que transmiten significado y estado';

  @override
  String get successColor => 'Color de Éxito';

  @override
  String get successColorDesc => 'Acciones positivas, confirmaciones';

  @override
  String get warningColor => 'Color de Advertencia';

  @override
  String get warningColorDesc => 'Precaución, estados pendientes';

  @override
  String get errorColor => 'Color de Error';

  @override
  String get errorColorDesc => 'Errores, acciones destructivas';

  @override
  String get backgroundColors => 'Colores de Fondo';

  @override
  String get backgroundColorsLightDesc =>
      'Superficies de fondo principales para modo claro';

  @override
  String get backgroundColorsDarkDesc =>
      'Superficies de fondo principales para modo oscuro';

  @override
  String get background => 'Fondo';

  @override
  String get backgroundDesc => 'Fondo principal de la aplicación';

  @override
  String get surface => 'Superficie';

  @override
  String get surfaceDesc => 'Tarjetas, diálogos, superficies elevadas';

  @override
  String get surfaceSecondary => 'Superficie Secundaria';

  @override
  String get surfaceSecondaryDesc => 'Tarjetas secundarias, barras laterales';

  @override
  String get border => 'Borde';

  @override
  String get borderDesc => 'Divisores, bordes de tarjetas';

  @override
  String get textColors => 'Colores de Texto';

  @override
  String get textColorsLightDesc => 'Colores de tipografía para modo claro';

  @override
  String get textColorsDarkDesc => 'Colores de tipografía para modo oscuro';

  @override
  String get textPrimary => 'Texto Primario';

  @override
  String get textPrimaryDesc => 'Encabezados, texto importante';

  @override
  String get textSecondary => 'Texto Secundario';

  @override
  String get textSecondaryDesc => 'Descripciones, subtítulos';

  @override
  String previewMode(String mode) {
    return 'Vista previa: Modo $mode';
  }

  @override
  String get dark => 'Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get sampleCardTitle => 'Título de Tarjeta de Ejemplo';

  @override
  String get sampleSecondaryText =>
      'Este es el texto secundario que aparece debajo.';

  @override
  String get primary => 'Primario';

  @override
  String get secondary => 'Secundario';

  @override
  String get warning => 'Advertencia';

  @override
  String get launchAtStartupTitle => 'Iniciar al arrancar';

  @override
  String get launchAtStartupDescription =>
      'Iniciar Scolect automáticamente al iniciar sesión en tu computadora';

  @override
  String get inputMonitoringPermissionTitle =>
      'Supervisión del teclado no disponible';

  @override
  String get inputMonitoringPermissionDescription =>
      'Activa el permiso de supervisión de entrada para registrar la actividad del teclado. Actualmente solo se supervisa el ratón.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get permissionGrantedTitle => 'Permiso concedido';

  @override
  String get permissionGrantedDescription =>
      'La aplicación necesita reiniciarse para que la supervisión de entrada tenga efecto.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get restartRequiredTitle => 'Reinicio necesario';

  @override
  String get restartRequiredDescription =>
      'Para activar la supervisión del teclado, la aplicación debe reiniciarse. Esto es obligatorio en macOS.';

  @override
  String get restartNote =>
      'La aplicación se volverá a abrir automáticamente después del reinicio.';

  @override
  String get restartNow => 'Reiniciar ahora';

  @override
  String get restartLater => 'Reiniciar más tarde';

  @override
  String get restartFailedTitle => 'Error al reiniciar';

  @override
  String get restartFailedMessage =>
      'No se pudo reiniciar la aplicación automáticamente. Sal (Cmd+Q) y ábrela de nuevo manualmente.';

  @override
  String get exportAnalyticsReport => 'Exportar Informe de Análisis';

  @override
  String get chooseExportFormat => 'Elige el formato de exportación:';

  @override
  String get beautifulExcelReport => 'Hermoso Informe Excel';

  @override
  String get beautifulExcelReportDescription =>
      'Hoja de cálculo colorida y hermosa con gráficos, emojis e información ✨';

  @override
  String get excelReportIncludes => 'El informe Excel incluye:';

  @override
  String get summarySheetDescription =>
      '📊 Hoja de Resumen - Métricas clave con tendencias';

  @override
  String get dailyBreakdownDescription =>
      '📅 Desglose Diario - Patrones de uso visual';

  @override
  String get appsSheetDescription =>
      '📱 Hoja de Apps - Rankings detallados de aplicaciones';

  @override
  String get insightsDescription =>
      '💡 Perspectivas - Recomendaciones inteligentes';

  @override
  String get beautifulExcelExportSuccess =>
      '¡Hermoso informe Excel exportado con éxito! 🎉';

  @override
  String failedToExportReport(String error) {
    return 'Error al exportar informe: $error';
  }

  @override
  String get exporting => 'Exportando...';

  @override
  String get exportExcel => 'Exportar Excel';

  @override
  String get saveAnalyticsReport => 'Guardar Informe de Análisis';

  @override
  String analyticsReportFileName(String timestamp) {
    return 'informe_analitico_$timestamp.xlsx';
  }

  @override
  String get usageAnalyticsReportTitle => 'INFORME DE ANÁLISIS DE USO';

  @override
  String get generated => 'Generado:';

  @override
  String get period => 'Período:';

  @override
  String dateRangeValue(String startDate, String endDate) {
    return '$startDate a $endDate';
  }

  @override
  String get keyMetrics => 'MÉTRICAS CLAVE';

  @override
  String get metric => 'Métrica';

  @override
  String get value => 'Valor';

  @override
  String get change => 'Cambio';

  @override
  String get trend => 'Tendencia';

  @override
  String get productivityRate => 'Tasa de Productividad';

  @override
  String get trendUp => 'Subió';

  @override
  String get trendDown => 'Bajó';

  @override
  String get trendExcellent => 'Excelente';

  @override
  String get trendGood => 'Bueno';

  @override
  String get trendNeedsImprovement => 'Necesita Mejorar';

  @override
  String get trendActive => 'Activo';

  @override
  String get trendNone => 'Ninguno';

  @override
  String get trendTop => 'Top';

  @override
  String get category => 'Categoría';

  @override
  String get percentage => 'Porcentaje';

  @override
  String get visual => 'Visual';

  @override
  String get statistics => 'ESTADÍSTICAS';

  @override
  String get averageDaily => 'Promedio Diario';

  @override
  String get highestDay => 'Día Más Alto';

  @override
  String get lowestDay => 'Día Más Bajo';

  @override
  String get day => 'Día';

  @override
  String get applicationUsageDetails => 'DETALLES DE USO DE APLICACIONES';

  @override
  String get totalApps => 'Total de Apps:';

  @override
  String get productiveApps => 'Apps Productivas:';

  @override
  String get rank => 'Puesto';

  @override
  String get application => 'Aplicación';

  @override
  String get time => 'Tiempo';

  @override
  String get percentOfTotal => '% del Total';

  @override
  String get type => 'Tipo';

  @override
  String get usageLevel => 'Nivel de Uso';

  @override
  String get leisure => 'Ocio';

  @override
  String get usageLevelVeryHigh => 'Muy Alto ||||||||';

  @override
  String get usageLevelHigh => 'Alto ||||||';

  @override
  String get usageLevelMedium => 'Medio ||||';

  @override
  String get usageLevelLow => 'Bajo ||';

  @override
  String get keyInsightsTitle => 'PERSPECTIVAS Y RECOMENDACIONES CLAVE';

  @override
  String get personalizedRecommendations => 'RECOMENDACIONES PERSONALIZADAS';

  @override
  String insightHighDailyUsage(String hours) {
    return 'Alto Uso Diario: Promediando $hours horas diarias de tiempo de pantalla';
  }

  @override
  String insightLowDailyUsage(String hours) {
    return 'Bajo Uso Diario: Promediando $hours horas diarias - ¡excelente equilibrio!';
  }

  @override
  String insightModerateUsage(String hours) {
    return 'Uso Moderado: Promediando $hours horas diarias de tiempo de pantalla';
  }

  @override
  String insightExcellentProductivity(String percentage) {
    return 'Productividad Excelente: ¡$percentage% de tu tiempo de pantalla es trabajo productivo!';
  }

  @override
  String insightGoodProductivity(String percentage) {
    return 'Buena Productividad: $percentage% de tu tiempo de pantalla es productivo';
  }

  @override
  String insightLowProductivity(String percentage) {
    return 'Alerta de Baja Productividad: Solo $percentage% del tiempo de pantalla es productivo';
  }

  @override
  String insightFocusSessions(int count, String avgPerDay) {
    return 'Sesiones de Enfoque: Completadas $count sesiones ($avgPerDay por día en promedio)';
  }

  @override
  String insightGreatFocusHabit(int count) {
    return 'Gran Hábito de Enfoque: ¡Has construido una increíble rutina de enfoque con $count sesiones completadas!';
  }

  @override
  String get insightNoFocusSessions =>
      'Sin Sesiones de Enfoque: Considera usar el modo enfoque para aumentar tu productividad';

  @override
  String insightScreenTimeTrend(String direction, String percentage) {
    return 'Tendencia de Tiempo de Pantalla: Tu uso ha $direction un $percentage% comparado con el período anterior';
  }

  @override
  String insightProductiveTimeTrend(String direction, String percentage) {
    return 'Tendencia de Tiempo Productivo: Tu tiempo productivo ha $direction un $percentage% comparado con el período anterior';
  }

  @override
  String get directionIncreased => 'aumentado';

  @override
  String get directionDecreased => 'disminuido';

  @override
  String insightTopCategory(String category, String percentage) {
    return 'Categoría Principal: $category domina con $percentage% de tu tiempo total';
  }

  @override
  String insightMostUsedApp(
      String appName, String percentage, String duration) {
    return 'App Más Usada: $appName representa $percentage% de tu tiempo ($duration)';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return 'El Uso Varía Significativamente: $highDay tuvo ${multiplier}x más uso que $lowDay';
  }

  @override
  String get insightNoInsights =>
      'No hay perspectivas significativas disponibles';

  @override
  String get recScheduleFocusSessions =>
      'Intenta programar más sesiones de enfoque durante el día para aumentar la productividad';

  @override
  String get recSetAppLimits =>
      'Considera establecer límites en aplicaciones de ocio';

  @override
  String get recAimForFocusSessions =>
      'Apunta a al menos 1-2 sesiones de enfoque por día para construir un hábito consistente';

  @override
  String get recTakeBreaks =>
      'Tu tiempo de pantalla diario es bastante alto. Intenta tomar descansos regulares usando la regla 20-20-20';

  @override
  String get recSetDailyGoals =>
      'Considera establecer metas diarias de tiempo de pantalla para reducir gradualmente el uso';

  @override
  String get recBalanceEntertainment =>
      'Las apps de entretenimiento ocupan gran parte de tu tiempo. Considera equilibrar con actividades más productivas';

  @override
  String get recReviewUsagePatterns =>
      'Tu tiempo de pantalla ha aumentado significativamente. Revisa tus patrones de uso y establece límites';

  @override
  String get recScheduleFocusedWork =>
      'Tu tiempo productivo ha disminuido. Intenta programar bloques de trabajo enfocado en tu calendario';

  @override
  String get recKeepUpGreatWork =>
      '¡Sigue así! Tus hábitos de tiempo de pantalla se ven saludables';

  @override
  String get recContinueFocusSessions =>
      'Continúa usando sesiones de enfoque para mantener la productividad';

  @override
  String get sheetSummary => 'Resumen';

  @override
  String get sheetDailyBreakdown => 'Desglose Diario';

  @override
  String get sheetApps => 'Apps';

  @override
  String get sheetInsights => 'Perspectivas';

  @override
  String get statusHeader => 'Estado';

  @override
  String workSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones de trabajo',
      one: '$count sesión de trabajo',
    );
    return '$_temp0';
  }

  @override
  String get complete => 'Completado';

  @override
  String get inProgress => 'En progreso';

  @override
  String get workTime => 'Tiempo de trabajo';

  @override
  String get breakTime => 'Tiempo de descanso';

  @override
  String get phasesCompleted => 'Fases completadas';

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
      other: '$count sesiones',
      one: '$count sesión',
    );
    return '$_temp0';
  }

  @override
  String get workPhases => 'Fases de trabajo';

  @override
  String get averageLength => 'Duración promedio';

  @override
  String get mostProductive => 'Más productivo';

  @override
  String get work => 'Trabajo';

  @override
  String get breaks => 'Descansos';

  @override
  String get none => 'Ninguno';

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
  String get chooseExportMethod => 'Elige cómo exportar tu tema:';

  @override
  String get saveAsFile => 'Guardar como archivo';

  @override
  String get saveThemeAsJSONFile =>
      'Guardar el tema como archivo JSON en tu dispositivo';

  @override
  String get copyToClipboard => 'Copiar al portapapeles';

  @override
  String get copyThemeJSONToClipboard =>
      'Copiar datos del tema al portapapeles';

  @override
  String get share => 'Compartir';

  @override
  String get shareThemeViaSystemSheet =>
      'Compartir tema usando la hoja de compartir del sistema';

  @override
  String get chooseImportMethod => 'Elige cómo importar un tema:';

  @override
  String get loadFromFile => 'Cargar desde archivo';

  @override
  String get selectJSONFileFromDevice =>
      'Selecciona un archivo JSON de tema de tu dispositivo';

  @override
  String get pasteFromClipboard => 'Pegar desde portapapeles';

  @override
  String get importFromClipboardJSON =>
      'Importar tema desde datos JSON del portapapeles';

  @override
  String get importFromFile => 'Importar tema desde un archivo';

  @override
  String get themeCreatedSuccessfully => '¡Tema creado exitosamente!';

  @override
  String get themeUpdatedSuccessfully => '¡Tema actualizado exitosamente!';

  @override
  String get themeDeletedSuccessfully => '¡Tema eliminado exitosamente!';

  @override
  String get themeExportedSuccessfully => '¡Tema exportado exitosamente!';

  @override
  String get themeCopiedToClipboard => '¡Tema copiado al portapapeles!';

  @override
  String themeImportedSuccessfully(String themeName) {
    return '¡Tema \"$themeName\" importado exitosamente!';
  }

  @override
  String get noThemeDataFound => 'No se encontraron datos del tema';

  @override
  String get invalidThemeFormat =>
      'Formato de tema inválido. Por favor, verifica los datos JSON.';

  @override
  String get trackingModeTitle => 'Modo de seguimiento';

  @override
  String get trackingModeDescription =>
      'Elige cómo se rastrea el uso de la aplicación';

  @override
  String get trackingModePolling => 'Estándar (Bajo consumo)';

  @override
  String get trackingModePrecise => 'Preciso (Alta precisión)';

  @override
  String get trackingModePollingHint =>
      'Comprueba cada minuto - menor uso de recursos';

  @override
  String get trackingModePreciseHint =>
      'Seguimiento en tiempo real - mayor precisión, más recursos';

  @override
  String get trackingModeChangeError =>
      'Error al cambiar el modo de seguimiento. Por favor, inténtalo de nuevo.';

  @override
  String get errorTitle => 'Error';

  @override
  String get monitorKeyboardTitle => 'Monitorear Teclado';

  @override
  String get monitorKeyboardDescription =>
      'Rastrear la actividad del teclado para detectar la presencia del usuario';

  @override
  String get changelogWhatsNew => 'Novedades';

  @override
  String changelogReleasedOn(String date) {
    return 'Publicado el $date';
  }

  @override
  String get changelogNoContent =>
      'No hay registro de cambios disponible para esta versión.';

  @override
  String get changelogUnableToLoad =>
      'No se puede cargar el registro de cambios';

  @override
  String get changelogErrorDescription =>
      'No se pudo recuperar el registro de cambios de esta versión. Comprueba tu conexión a internet o visita la página de versiones de GitHub.';

  @override
  String get allTracking => 'Todas las apps';

  @override
  String get notTracking => 'No rastreadas';

  @override
  String get allVisibility => 'Todas';

  @override
  String get visible => 'Visibles';

  @override
  String get hidden => 'Ocultas';

  @override
  String get todaysLimitUsage => 'Uso del límite de hoy';

  @override
  String get thisWeekAtAGlance => 'Esta semana de un vistazo';

  @override
  String get hourlyActivityHeatmap => 'Mapa de calor de actividad por hora';

  @override
  String get productivityScore => 'Puntuación de productividad';

  @override
  String get streaks => 'Rachas';

  @override
  String get weekOverWeek => 'Semana a semana';

  @override
  String get sameAsLastWeek => 'Igual que la semana pasada';

  @override
  String moreUsageThanLastWeek(String percent) {
    return '$percent% más que la semana pasada';
  }

  @override
  String lessUsageThanLastWeek(String percent) {
    return '$percent% menos que la semana pasada';
  }

  @override
  String limitExceededBy(String duration) {
    return 'Límite excedido por $duration';
  }

  @override
  String timeRemaining(String duration) {
    return '$duration restante';
  }

  @override
  String get totalSessions => 'Sesiones totales';

  @override
  String get avgSession => 'Sesión promedio';

  @override
  String get mostActive => 'Más activo';

  @override
  String get peakUsage => 'Uso máximo';

  @override
  String get dailyAverage => 'Promedio diario';

  @override
  String get daysUsedInARow => 'Días de uso consecutivos';

  @override
  String get daysSingular => 'día';

  @override
  String get daysPlural => 'días';

  @override
  String get daysOverLimitInARow => 'Días consecutivos por encima del límite';

  @override
  String get withinLimitAllWeek => 'Dentro del límite toda la semana';

  @override
  String get productivityScoreGreat => 'Excelente';

  @override
  String get productivityScoreModerate => 'Moderado';

  @override
  String get productivityScoreNeedsAttention => 'Necesita atención';

  @override
  String get productiveAppMotivation => 'App productiva — sigue así';

  @override
  String get nonProductiveAppSuggestion =>
      'No productiva — considera reducir su uso';

  @override
  String get legendUsage => 'Uso';

  @override
  String get legendAverage => 'Promedio';

  @override
  String get legendLimit => 'Límite';

  @override
  String get chartPeak => 'Máximo';

  @override
  String overLimitBy(String duration) {
    return '+$duration por encima del límite';
  }

  @override
  String get noData => 'Sin datos';

  @override
  String get yesterday => 'Ayer';

  @override
  String get changelog => 'Registro de cambios';
}
