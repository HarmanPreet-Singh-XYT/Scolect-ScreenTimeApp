// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appWindowTitle =>
      'Scolect - Suivi du Temps d\'Écran et de l\'Utilisation des Applications';

  @override
  String get appName => 'Scolect';

  @override
  String get appTitle => 'Temps d\'Écran Productif';

  @override
  String get sidebarTitle => 'Temps d\'Écran';

  @override
  String get sidebarSubtitle => 'Open Source';

  @override
  String get trayShowWindow => 'Afficher la Fenêtre';

  @override
  String get trayStartFocusMode => 'Démarrer le Mode Concentration';

  @override
  String get trayStopFocusMode => 'Arrêter le Mode Concentration';

  @override
  String get trayReports => 'Rapports';

  @override
  String get trayAlertsLimits => 'Alertes et Limites';

  @override
  String get trayApplications => 'Applications';

  @override
  String get trayDisableNotifications => 'Désactiver les Notifications';

  @override
  String get trayEnableNotifications => 'Activer les Notifications';

  @override
  String get trayVersionPrefix => 'Version : ';

  @override
  String trayVersion(String version) {
    return 'Version : $version';
  }

  @override
  String get trayExit => 'Quitter';

  @override
  String get navOverview => 'Aperçu';

  @override
  String get navApplications => 'Applications';

  @override
  String get navAlertsLimits => 'Alertes et Limites';

  @override
  String get navReports => 'Rapports';

  @override
  String get navFocusMode => 'Mode Concentration';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navHelp => 'Aide';

  @override
  String get helpTitle => 'Aide';

  @override
  String get faqCategoryGeneral => 'Questions Générales';

  @override
  String get faqCategoryApplications => 'Gestion des Applications';

  @override
  String get faqCategoryReports => 'Analyses et Rapports d\'Utilisation';

  @override
  String get faqCategoryAlerts => 'Alertes et Limites';

  @override
  String get faqCategoryFocusMode => 'Mode Concentration et Minuteur Pomodoro';

  @override
  String get faqCategorySettings => 'Paramètres et Personnalisation';

  @override
  String get faqCategoryTroubleshooting => 'Dépannage';

  @override
  String get faqGeneralQ1 =>
      'Comment cette application suit-elle le temps d\'écran ?';

  @override
  String get faqGeneralA1 =>
      'L\'application surveille l\'utilisation de votre appareil en temps réel, en suivant le temps passé sur différentes applications. Elle fournit des informations complètes sur vos habitudes numériques, y compris le temps d\'écran total, le temps productif et l\'utilisation spécifique des applications.';

  @override
  String get faqGeneralQ2 =>
      'Qu\'est-ce qui rend une application \'Productive\' ?';

  @override
  String get faqGeneralA2 =>
      'Vous pouvez marquer manuellement les applications comme productives dans la section \'Applications\'. Les applications productives contribuent à votre Score de Productivité, qui calcule le pourcentage de temps d\'écran consacré aux applications liées au travail ou bénéfiques.';

  @override
  String get faqGeneralQ3 =>
      'Quelle est la précision du suivi du temps d\'écran ?';

  @override
  String get faqGeneralA3 =>
      'L\'application utilise un suivi au niveau du système pour fournir une mesure précise de l\'utilisation de votre appareil. Elle capture le temps au premier plan pour chaque application avec un impact minimal sur la batterie.';

  @override
  String get faqGeneralQ4 =>
      'Puis-je personnaliser la catégorisation de mes applications ?';

  @override
  String get faqGeneralA4 =>
      'Absolument ! Vous pouvez créer des catégories personnalisées, attribuer des applications à des catégories spécifiques et modifier facilement ces attributions dans la section \'Applications\'. Cela aide à créer des analyses d\'utilisation plus significatives.';

  @override
  String get faqGeneralQ5 =>
      'Quelles informations puis-je obtenir de cette application ?';

  @override
  String get faqGeneralA5 =>
      'L\'application offre des informations complètes, notamment le Score de Productivité, les modèles d\'utilisation par moment de la journée, l\'utilisation détaillée des applications, le suivi des sessions de concentration, et des analyses visuelles comme des graphiques et des diagrammes circulaires pour vous aider à comprendre et améliorer vos habitudes numériques.';

  @override
  String get faqAppsQ1 =>
      'Comment masquer des applications spécifiques du suivi ?';

  @override
  String get faqAppsA1 =>
      'Dans la section \'Applications\', vous pouvez basculer la visibilité des applications.';

  @override
  String get faqAppsQ2 => 'Puis-je rechercher et filtrer mes applications ?';

  @override
  String get faqAppsA2 =>
      'Oui, la section Applications comprend une fonctionnalité de recherche et des options de filtrage. Vous pouvez filtrer les applications par catégorie, statut de productivité, statut de suivi et visibilité.';

  @override
  String get faqAppsQ3 =>
      'Quelles options d\'édition sont disponibles pour les applications ?';

  @override
  String get faqAppsA3 =>
      'Pour chaque application, vous pouvez modifier : l\'attribution de catégorie, le statut de productivité, le suivi d\'utilisation, la visibilité dans les rapports et définir des limites de temps quotidiennes individuelles.';

  @override
  String get faqAppsQ4 =>
      'Comment les catégories d\'applications sont-elles déterminées ?';

  @override
  String get faqAppsA4 =>
      'Les catégories initiales sont suggérées par le système, mais vous avez un contrôle total pour créer, modifier et attribuer des catégories personnalisées selon votre flux de travail et vos préférences.';

  @override
  String get faqReportsQ1 => 'Quels types de rapports sont disponibles ?';

  @override
  String get faqReportsA1 =>
      'Les rapports incluent : Temps d\'écran total, Temps productif, Applications les plus utilisées, Sessions de concentration, Graphique du temps d\'écran quotidien, Diagramme circulaire de répartition par catégorie, Utilisation détaillée des applications, Tendances d\'utilisation hebdomadaires et Analyse des modèles d\'utilisation par moment de la journée.';

  @override
  String get faqReportsQ2 =>
      'Quelle est la précision des rapports d\'utilisation des applications ?';

  @override
  String get faqReportsA2 =>
      'Les rapports d\'utilisation détaillés des applications montrent : Nom de l\'application, Catégorie, Temps total passé, Statut de productivité, et offrent une section \'Actions\' avec des informations plus approfondies comme le résumé d\'utilisation, les limites quotidiennes, les tendances d\'utilisation et les métriques de productivité.';

  @override
  String get faqReportsQ3 =>
      'Puis-je analyser mes tendances d\'utilisation au fil du temps ?';

  @override
  String get faqReportsA3 =>
      'Oui ! L\'application fournit des comparaisons semaine après semaine, montrant des graphiques d\'utilisation sur les semaines passées, l\'utilisation quotidienne moyenne, les sessions les plus longues et les totaux hebdomadaires pour vous aider à suivre vos habitudes numériques.';

  @override
  String get faqReportsQ4 =>
      'Qu\'est-ce que l\'analyse du \'Modèle d\'Utilisation\' ?';

  @override
  String get faqReportsA4 =>
      'Le Modèle d\'Utilisation décompose votre temps d\'écran en segments matin, après-midi, soir et nuit. Cela vous aide à comprendre quand vous êtes le plus actif sur votre appareil et à identifier les domaines potentiels d\'amélioration.';

  @override
  String get faqAlertsQ1 =>
      'Quelle est la granularité des limites de temps d\'écran ?';

  @override
  String get faqAlertsA1 =>
      'Vous pouvez définir des limites globales de temps d\'écran quotidien et des limites individuelles par application. Les limites peuvent être configurées en heures et minutes, avec des options pour réinitialiser ou ajuster selon les besoins.';

  @override
  String get faqAlertsQ2 =>
      'Quelles options de notification sont disponibles ?';

  @override
  String get faqAlertsA2 =>
      'L\'application offre plusieurs types de notifications : Alertes système lorsque vous dépassez le temps d\'écran, Alertes fréquentes à intervalles personnalisables (1, 5, 15, 30 ou 60 minutes), et des bascules pour le mode concentration, le temps d\'écran et les notifications spécifiques aux applications.';

  @override
  String get faqAlertsQ3 => 'Puis-je personnaliser les alertes de limite ?';

  @override
  String get faqAlertsA3 =>
      'Oui, vous pouvez personnaliser la fréquence des alertes, activer/désactiver des types spécifiques d\'alertes et définir différentes limites pour le temps d\'écran global et les applications individuelles.';

  @override
  String get faqFocusQ1 =>
      'Quels types de Modes Concentration sont disponibles ?';

  @override
  String get faqFocusA1 =>
      'Les modes disponibles incluent Travail Approfondi (sessions de concentration plus longues), Tâches Rapides (courtes périodes de travail) et Mode Lecture. Chaque mode vous aide à structurer efficacement votre travail et vos temps de pause.';

  @override
  String get faqFocusQ2 => 'Quelle est la flexibilité du Minuteur Pomodoro ?';

  @override
  String get faqFocusA2 =>
      'Le minuteur est hautement personnalisable. Vous pouvez ajuster la durée de travail, la durée de la pause courte et la durée de la pause longue. Des options supplémentaires incluent le démarrage automatique des sessions suivantes et les paramètres de notification.';

  @override
  String get faqFocusQ3 => 'Que montre l\'historique du Mode Concentration ?';

  @override
  String get faqFocusA3 =>
      'L\'historique du Mode Concentration suit les sessions de concentration quotidiennes, montrant le nombre de sessions par jour, le graphique des tendances, la durée moyenne des sessions, le temps total de concentration et un diagramme circulaire de distribution du temps décomposant les sessions de travail, les pauses courtes et les pauses longues.';

  @override
  String get faqFocusQ4 =>
      'Puis-je suivre la progression de mes sessions de concentration ?';

  @override
  String get faqFocusA4 =>
      'L\'application dispose d\'une interface de minuteur circulaire avec des boutons lecture/pause, recharger et paramètres. Vous pouvez facilement suivre et gérer vos sessions de concentration avec des contrôles intuitifs.';

  @override
  String get faqSettingsQ1 =>
      'Quelles options de personnalisation sont disponibles ?';

  @override
  String get faqSettingsA1 =>
      'La personnalisation comprend la sélection du thème (Système, Clair, Sombre), les paramètres de langue, le comportement au démarrage, des contrôles de notification complets et des options de gestion des données comme effacer les données ou réinitialiser les paramètres.';

  @override
  String get faqSettingsQ2 =>
      'Comment puis-je donner mon avis ou signaler des problèmes ?';

  @override
  String get faqSettingsA2 =>
      'En bas de la section Paramètres, vous trouverez des boutons pour Signaler un Bug, Soumettre un Commentaire ou Contacter le Support. Ceux-ci vous redirigeront vers les canaux de support appropriés.';

  @override
  String get faqSettingsQ3 =>
      'Que se passe-t-il lorsque j\'efface mes données ?';

  @override
  String get faqSettingsA3 =>
      'Effacer les données réinitialisera toutes vos statistiques d\'utilisation, l\'historique des sessions de concentration et les paramètres personnalisés. C\'est utile pour repartir de zéro ou pour le dépannage.';

  @override
  String get faqTroubleQ1 =>
      'Les données ne s\'affichent pas, erreur d\'ouverture de hive';

  @override
  String get faqTroubleA1 =>
      'Le problème est connu, la solution temporaire est d\'effacer les données via les paramètres et si cela ne fonctionne pas, allez dans Documents et supprimez les fichiers suivants s\'ils existent - harman_screentime_app_usage_box.hive et harman_screentime_app_usage.lock, il est également suggéré de mettre à jour l\'application vers la dernière version.';

  @override
  String get faqTroubleQ2 =>
      'L\'application s\'ouvre à chaque démarrage, que faire ?';

  @override
  String get faqTroubleA2 =>
      'C\'est un problème connu qui se produit sur Windows 10, la solution temporaire est d\'activer Lancer en Minimisé dans les paramètres pour qu\'elle se lance en minimisé.';

  @override
  String get usageAnalytics => 'Analyses d\'Utilisation';

  @override
  String get last7Days => '7 Derniers Jours';

  @override
  String get lastMonth => 'Dernier Mois';

  @override
  String get last3Months => '3 Derniers Mois';

  @override
  String get lifetime => 'Depuis le Début';

  @override
  String get custom => 'Personnalisé';

  @override
  String get loadingAnalyticsData => 'Chargement des données d\'analyse...';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get failedToInitialize =>
      'Échec de l\'initialisation des analyses. Veuillez redémarrer l\'application.';

  @override
  String unexpectedError(String error) {
    return 'Une erreur inattendue s\'est produite : $error. Veuillez réessayer plus tard.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Erreur lors du chargement des données d\'analyse : $error. Veuillez vérifier votre connexion et réessayer.';
  }

  @override
  String get customDialogTitle => 'Personnalisé';

  @override
  String get dateRange => 'Plage de Dates :';

  @override
  String get specificDate => 'Date Spécifique';

  @override
  String get startDate => 'Date de Début : ';

  @override
  String get endDate => 'Date de Fin : ';

  @override
  String get date => 'Date';

  @override
  String get cancel => 'Annuler';

  @override
  String get apply => 'Appliquer';

  @override
  String get ok => 'OK';

  @override
  String get invalidDateRange => 'Plage de Dates Invalide';

  @override
  String get startDateBeforeEndDate =>
      'La date de début doit être antérieure ou égale à la date de fin.';

  @override
  String get totalScreenTime => 'Temps d\'Écran Total';

  @override
  String get productiveTime => 'Temps Productif';

  @override
  String get mostUsedApp => 'App la Plus Utilisée';

  @override
  String get focusSessions => 'Sessions de Concentration';

  @override
  String positiveComparison(String percent) {
    return '+$percent% vs période précédente';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% vs période précédente';
  }

  @override
  String iconLabel(String title) {
    return 'Icône $title';
  }

  @override
  String get dailyScreenTime => 'TEMPS D\'ÉCRAN QUOTIDIEN';

  @override
  String get categoryBreakdown => 'RÉPARTITION PAR CATÉGORIE';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String sectionLabel(String title) {
    return 'Section $title';
  }

  @override
  String get detailedApplicationUsage =>
      'Utilisation Détaillée des Applications';

  @override
  String get searchApplications => 'Rechercher des applications';

  @override
  String get nameHeader => 'Nom';

  @override
  String get categoryHeader => 'Catégorie';

  @override
  String get totalTimeHeader => 'Temps Total';

  @override
  String get productivityHeader => 'Productivité';

  @override
  String get actionsHeader => 'Actions';

  @override
  String sortByOption(String option) {
    return 'Trier par : $option';
  }

  @override
  String get sortByName => 'Nom';

  @override
  String get sortByCategory => 'Catégorie';

  @override
  String get sortByUsage => 'Utilisation';

  @override
  String get productive => 'Productif';

  @override
  String get nonProductive => 'Non-Productif';

  @override
  String get noApplicationsMatch =>
      'Aucune application ne correspond à vos critères de recherche';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get usageSummary => 'Résumé d\'Utilisation';

  @override
  String get usageOverPastWeek => 'Utilisation de la Semaine Passée';

  @override
  String get usagePatternByTimeOfDay =>
      'Modèle d\'Utilisation par Moment de la Journée';

  @override
  String get patternAnalysis => 'Analyse des Modèles';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get dailyLimit => 'Limite Quotidienne';

  @override
  String get noLimit => 'Aucune limite';

  @override
  String get usageTrend => 'Tendance d\'Utilisation';

  @override
  String get productivity => 'Productivité';

  @override
  String get increasing => 'En Hausse';

  @override
  String get decreasing => 'En Baisse';

  @override
  String get stable => 'Stable';

  @override
  String get avgDailyUsage => 'Utilisation Quotidienne Moy.';

  @override
  String get longestSession => 'Session la plus longue';

  @override
  String get weeklyTotal => 'Total Hebdomadaire';

  @override
  String get noHistoricalData => 'Aucune donnée historique disponible';

  @override
  String get morning => 'Matin (6h-12h)';

  @override
  String get afternoon => 'Après-midi (12h-17h)';

  @override
  String get evening => 'Soir (17h-21h)';

  @override
  String get night => 'Nuit (21h-6h)';

  @override
  String get usageInsights => 'Aperçus d\'Utilisation';

  @override
  String get limitStatus => 'Statut de la Limite';

  @override
  String get close => 'Fermer';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'Vous utilisez principalement $appName pendant $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Votre utilisation a augmenté de manière significative ($percentage%) par rapport à la période précédente.';
  }

  @override
  String get trendingUpward =>
      'Votre utilisation est en hausse par rapport à la période précédente.';

  @override
  String significantDecrease(String percentage) {
    return 'Votre utilisation a diminué de manière significative ($percentage%) par rapport à la période précédente.';
  }

  @override
  String get trendingDownward =>
      'Votre utilisation est en baisse par rapport à la période précédente.';

  @override
  String get consistentUsage =>
      'Votre utilisation est restée constante par rapport à la période précédente.';

  @override
  String get markedAsProductive =>
      'Cette application est marquée comme productive dans vos paramètres.';

  @override
  String get markedAsNonProductive =>
      'Cette application est marquée comme non-productive dans vos paramètres.';

  @override
  String mostActiveTime(String time) {
    return 'Votre moment le plus actif est autour de $time.';
  }

  @override
  String get noLimitSet =>
      'Aucune limite d\'utilisation n\'a été définie pour cette application.';

  @override
  String get limitReached =>
      'Vous avez atteint votre limite quotidienne pour cette application.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'Vous êtes sur le point d\'atteindre votre limite quotidienne avec seulement $remainingTime restant.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'Vous avez utilisé $percent% de votre limite quotidienne avec $remainingTime restant.';
  }

  @override
  String remainingTime(String time) {
    return 'Il vous reste $time sur votre limite quotidienne.';
  }

  @override
  String get todayChart => 'Aujourd\'hui';

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
  String get alertsLimitsTitle => 'Alertes et Limites';

  @override
  String get notificationsSettings => 'Paramètres de Notifications';

  @override
  String get overallScreenTimeLimit => 'Limite Globale de Temps d\'Écran';

  @override
  String get applicationLimits => 'Limites des Applications';

  @override
  String get popupAlerts => 'Alertes Pop-up';

  @override
  String get frequentAlerts => 'Alertes Fréquentes';

  @override
  String get soundAlerts => 'Alertes Sonores';

  @override
  String get systemAlerts => 'Alertes Système';

  @override
  String get dailyTotalLimit => 'Limite Quotidienne Totale : ';

  @override
  String get hours => 'Heures';

  @override
  String get minutes => 'Minutes';

  @override
  String get currentUsage => 'Utilisation Actuelle : ';

  @override
  String get tableName => 'Nom';

  @override
  String get tableCategory => 'Catégorie';

  @override
  String get tableDailyLimit => 'Limite Quotidienne';

  @override
  String get tableCurrentUsage => 'Utilisation Actuelle';

  @override
  String get tableStatus => 'Statut';

  @override
  String get tableActions => 'Actions';

  @override
  String get addLimit => 'Ajouter une Limite';

  @override
  String get noApplicationsToDisplay => 'Aucune application à afficher';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusOff => 'Désactivé';

  @override
  String get durationNone => 'Aucune';

  @override
  String get addApplicationLimit => 'Ajouter une Limite d\'Application';

  @override
  String get selectApplication => 'Sélectionner une Application';

  @override
  String get selectApplicationPlaceholder => 'Sélectionnez une application';

  @override
  String get enableLimit => 'Activer la Limite : ';

  @override
  String editLimitTitle(String appName) {
    return 'Modifier la Limite : $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Échec du chargement des données : $error';
  }

  @override
  String get resetSettingsTitle => 'Réinitialiser les Paramètres ?';

  @override
  String get resetSettingsContent =>
      'Si vous réinitialisez les paramètres, vous ne pourrez pas les récupérer. Voulez-vous les réinitialiser ?';

  @override
  String get resetAll => 'Tout Réinitialiser';

  @override
  String get refresh => 'Actualiser';

  @override
  String get save => 'Enregistrer';

  @override
  String get add => 'Ajouter';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Réessayer';

  @override
  String get applicationsTitle => 'Applications';

  @override
  String get searchApplication => 'Rechercher une Application';

  @override
  String get tracking => 'Suivies';

  @override
  String get hiddenVisible => 'Masqué/Visible';

  @override
  String get selectCategory => 'Sélectionner une Catégorie';

  @override
  String get allCategories => 'Toutes';

  @override
  String get tableScreenTime => 'Temps d\'Écran';

  @override
  String get tableTracking => 'Suivi';

  @override
  String get tableHidden => 'Masqué';

  @override
  String get tableEdit => 'Modifier';

  @override
  String editAppTitle(String appName) {
    return 'Modifier $appName';
  }

  @override
  String get categorySection => 'Catégorie';

  @override
  String get customCategory => 'Personnalisée';

  @override
  String get customCategoryPlaceholder =>
      'Entrez le nom de la catégorie personnalisée';

  @override
  String get uncategorized => 'Non catégorisé';

  @override
  String get isProductive => 'Est Productif';

  @override
  String get trackUsage => 'Suivre l\'Utilisation';

  @override
  String get visibleInReports => 'Visible dans les Rapports';

  @override
  String get timeLimitsSection => 'Limites de Temps';

  @override
  String get enableDailyLimit => 'Activer la Limite Quotidienne';

  @override
  String get setDailyTimeLimit => 'Définir la limite de temps quotidienne :';

  @override
  String get saveChanges => 'Enregistrer les Modifications';

  @override
  String errorLoadingData(String error) {
    return 'Erreur lors du chargement des données d\'aperçu : $error';
  }

  @override
  String get focusModeTitle => 'Mode Concentration';

  @override
  String get historySection => 'Historique';

  @override
  String get trendsSection => 'Tendances';

  @override
  String get timeDistributionSection => 'Répartition du Temps';

  @override
  String get sessionHistorySection => 'Historique des Sessions';

  @override
  String get workSession => 'Session de Travail';

  @override
  String get shortBreak => 'Pause Courte';

  @override
  String get longBreak => 'Pause Longue';

  @override
  String get dateHeader => 'Date';

  @override
  String get durationHeader => 'Durée';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get focusModeSettingsTitle => 'Paramètres du Mode Concentration';

  @override
  String get modeCustom => 'Personnalisé';

  @override
  String get modeDeepWork => 'Travail Approfondi (60 min)';

  @override
  String get modeQuickTasks => 'Tâches Rapides (25 min)';

  @override
  String get modeReading => 'Lecture (45 min)';

  @override
  String workDurationLabel(int minutes) {
    return 'Durée de Travail : $minutes min';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Courte Pause';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Longue Pause';
  }

  @override
  String get autoStartNextSession =>
      'Démarrer automatiquement la session suivante';

  @override
  String get blockDistractions =>
      'Bloquer les distractions pendant le mode concentration';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get saved => 'Enregistré';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Erreur lors du chargement des données du mode concentration : $error';
  }

  @override
  String get overviewTitle => 'Aperçu d\'Aujourd\'hui';

  @override
  String get startFocusMode => 'Démarrer le Mode Concentration';

  @override
  String get loadingProductivityData =>
      'Chargement de vos données de productivité...';

  @override
  String get noActivityDataAvailable => 'Aucune donnée d\'activité disponible';

  @override
  String get startUsingApplications =>
      'Commencez à utiliser vos applications pour suivre le temps d\'écran et la productivité.';

  @override
  String get refreshData => 'Actualiser les Données';

  @override
  String get topApplications => 'Applications Principales';

  @override
  String get noAppUsageDataAvailable =>
      'Aucune donnée d\'utilisation d\'application disponible';

  @override
  String get noApplicationDataAvailable =>
      'Aucune donnée d\'application disponible';

  @override
  String get noCategoryDataAvailable => 'Aucune donnée de catégorie disponible';

  @override
  String get noApplicationLimitsSet => 'Aucune limite d\'application définie';

  @override
  String get screenLabel => 'Temps';

  @override
  String get timeLabel => 'd\'Écran';

  @override
  String get productiveLabel => 'Score';

  @override
  String get scoreLabel => 'Productif';

  @override
  String get defaultNone => 'Aucun';

  @override
  String get defaultTime => '0h 0m';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Inconnu';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get generalSection => 'Général';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get dataSection => 'Données';

  @override
  String get versionSection => 'Version';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageDescription => 'Langue de l\'application';

  @override
  String get startupBehaviourTitle => 'Comportement au Démarrage';

  @override
  String get startupBehaviourDescription => 'Lancer au démarrage du système';

  @override
  String get launchMinimizedTitle => 'Lancer en Minimisé';

  @override
  String get launchMinimizedDescription =>
      'Démarrer l\'application dans la barre système (Recommandé pour Windows 10)';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsAllDescription =>
      'Toutes les notifications de l\'application';

  @override
  String get focusModeNotificationsTitle => 'Mode Concentration';

  @override
  String get focusModeNotificationsDescription =>
      'Toutes les notifications du mode concentration';

  @override
  String get screenTimeNotificationsTitle => 'Temps d\'Écran';

  @override
  String get screenTimeNotificationsDescription =>
      'Toutes les notifications de restriction du temps d\'écran';

  @override
  String get appScreenTimeNotificationsTitle =>
      'Temps d\'Écran des Applications';

  @override
  String get appScreenTimeNotificationsDescription =>
      'Toutes les notifications de restriction du temps d\'écran des applications';

  @override
  String get frequentAlertsTitle => 'Intervalle des Alertes Fréquentes';

  @override
  String get frequentAlertsDescription =>
      'Définir l\'intervalle pour les notifications fréquentes (minutes)';

  @override
  String get clearDataTitle => 'Effacer les Données';

  @override
  String get clearDataDescription =>
      'Effacer tout l\'historique et les données associées';

  @override
  String get resetSettingsTitle2 => 'Réinitialiser les Paramètres';

  @override
  String get resetSettingsDescription => 'Réinitialiser tous les paramètres';

  @override
  String get versionTitle => 'Version';

  @override
  String get versionDescription => 'Version actuelle de l\'application';

  @override
  String get contactButton => 'Contact';

  @override
  String get reportBugButton => 'Signaler un Bug';

  @override
  String get submitFeedbackButton => 'Soumettre un Commentaire';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'Effacer les Données ?';

  @override
  String get clearDataDialogContent =>
      'Cela effacera tout l\'historique et les données associées. Vous ne pourrez pas les récupérer. Voulez-vous continuer ?';

  @override
  String get clearDataButtonLabel => 'Effacer les Données';

  @override
  String get resetSettingsDialogTitle => 'Réinitialiser les Paramètres ?';

  @override
  String get resetSettingsDialogContent =>
      'Cela réinitialisera tous les paramètres à leurs valeurs par défaut. Voulez-vous continuer ?';

  @override
  String get resetButtonLabel => 'Réinitialiser';

  @override
  String get cancelButton => 'Annuler';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String errorMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get chart_focusTrends => 'Tendances de Concentration';

  @override
  String get chart_sessionCount => 'Nombre de Sessions';

  @override
  String get chart_avgDuration => 'Durée Moyenne';

  @override
  String get chart_totalFocus => 'Concentration Totale';

  @override
  String get chart_yAxis_sessions => 'Sessions';

  @override
  String get chart_yAxis_minutes => 'Minutes';

  @override
  String get chart_yAxis_value => 'Valeur';

  @override
  String get chart_monthOverMonthChange => 'Variation mensuelle : ';

  @override
  String get chart_customRange => 'Plage Personnalisée';

  @override
  String get day_monday => 'Lundi';

  @override
  String get day_mondayShort => 'Lun';

  @override
  String get day_mondayAbbr => 'Lu';

  @override
  String get day_tuesday => 'Mardi';

  @override
  String get day_tuesdayShort => 'Mar';

  @override
  String get day_tuesdayAbbr => 'Ma';

  @override
  String get day_wednesday => 'Mercredi';

  @override
  String get day_wednesdayShort => 'Mer';

  @override
  String get day_wednesdayAbbr => 'Me';

  @override
  String get day_thursday => 'Jeudi';

  @override
  String get day_thursdayShort => 'Jeu';

  @override
  String get day_thursdayAbbr => 'Je';

  @override
  String get day_friday => 'Vendredi';

  @override
  String get day_fridayShort => 'Ven';

  @override
  String get day_fridayAbbr => 'Ve';

  @override
  String get day_saturday => 'Samedi';

  @override
  String get day_saturdayShort => 'Sam';

  @override
  String get day_saturdayAbbr => 'Sa';

  @override
  String get day_sunday => 'Dimanche';

  @override
  String get day_sundayShort => 'Dim';

  @override
  String get day_sundayAbbr => 'Di';

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
    return '$date : ${hours}h ${minutes}m';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count heures';
  }

  @override
  String get month_january => 'Janvier';

  @override
  String get month_januaryShort => 'Jan';

  @override
  String get month_february => 'Février';

  @override
  String get month_februaryShort => 'Fév';

  @override
  String get month_march => 'Mars';

  @override
  String get month_marchShort => 'Mar';

  @override
  String get month_april => 'Avril';

  @override
  String get month_aprilShort => 'Avr';

  @override
  String get month_may => 'Mai';

  @override
  String get month_mayShort => 'Mai';

  @override
  String get month_june => 'Juin';

  @override
  String get month_juneShort => 'Juin';

  @override
  String get month_july => 'Juillet';

  @override
  String get month_julyShort => 'Juil';

  @override
  String get month_august => 'Août';

  @override
  String get month_augustShort => 'Août';

  @override
  String get month_september => 'Septembre';

  @override
  String get month_septemberShort => 'Sep';

  @override
  String get month_october => 'Octobre';

  @override
  String get month_octoberShort => 'Oct';

  @override
  String get month_november => 'Novembre';

  @override
  String get month_novemberShort => 'Nov';

  @override
  String get month_december => 'Décembre';

  @override
  String get month_decemberShort => 'Déc';

  @override
  String get categoryAll => 'Toutes';

  @override
  String get categoryProductivity => 'Productivité';

  @override
  String get categoryDevelopment => 'Développement';

  @override
  String get categorySocialMedia => 'Réseaux Sociaux';

  @override
  String get categoryEntertainment => 'Divertissement';

  @override
  String get categoryGaming => 'Jeux';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get categoryWebBrowsing => 'Navigation Web';

  @override
  String get categoryCreative => 'Créatif';

  @override
  String get categoryEducation => 'Éducation';

  @override
  String get categoryUtility => 'Utilitaire';

  @override
  String get categoryUncategorized => 'Non catégorisé';

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
  String get appAppleCalendar => 'Calendrier';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'Terminal';

  @override
  String get appCommandPrompt => 'Invite de Commandes';

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
  String get appCalculator => 'Calculatrice';

  @override
  String get appNotes => 'Notes';

  @override
  String get appSystemPreferences => 'Préférences Système';

  @override
  String get appTaskManager => 'Gestionnaire des Tâches';

  @override
  String get appFileExplorer => 'Explorateur de Fichiers';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';

  @override
  String get loadingApplication => 'Chargement de l’application...';

  @override
  String get loadingData => 'Chargement des données...';

  @override
  String get reportsError => 'Erreur';

  @override
  String get reportsRetry => 'Réessayer';

  @override
  String get backupRestoreSection => 'Sauvegarde et restauration';

  @override
  String get backupRestoreTitle => 'Sauvegarde et restauration';

  @override
  String get exportDataTitle => 'Exporter les données';

  @override
  String get exportDataDescription =>
      'Créer une sauvegarde de toutes vos données';

  @override
  String get importDataTitle => 'Importer les données';

  @override
  String get importDataDescription =>
      'Restaurer à partir d\'un fichier de sauvegarde';

  @override
  String get exportButton => 'Exporter';

  @override
  String get importButton => 'Importer';

  @override
  String get closeButton => 'Fermer';

  @override
  String get noButton => 'Non';

  @override
  String get shareButton => 'Partager';

  @override
  String get exportStarting => 'Démarrage de l\'exportation...';

  @override
  String get exportSuccessful => 'Exportation Réussie';

  @override
  String get exportFailed => 'Exportation Échouée';

  @override
  String get exportComplete => 'Exportation terminée';

  @override
  String get shareBackupQuestion =>
      'Souhaitez-vous partager le fichier de sauvegarde ?';

  @override
  String get importStarting => 'Démarrage de l\'importation...';

  @override
  String get importSuccessful => 'Importation réussie !';

  @override
  String get importFailed => 'Échec de l\'importation';

  @override
  String get importOptionsTitle => 'Options d\'importation';

  @override
  String get importOptionsQuestion =>
      'Comment souhaitez-vous importer les données ?';

  @override
  String get replaceModeTitle => 'Remplacer';

  @override
  String get replaceModeDescription =>
      'Remplacer toutes les données existantes';

  @override
  String get mergeModeTitle => 'Fusionner';

  @override
  String get mergeModeDescription => 'Combiner avec les données existantes';

  @override
  String get appendModeTitle => 'Ajouter';

  @override
  String get appendModeDescription =>
      'Ajouter uniquement les nouveaux enregistrements';

  @override
  String get warningTitle => '⚠️ Avertissement';

  @override
  String get replaceWarningMessage =>
      'Cela remplacera TOUTES vos données existantes. Êtes-vous sûr de vouloir continuer ?';

  @override
  String get replaceAllButton => 'Tout remplacer';

  @override
  String get fileLabel => 'Fichier';

  @override
  String get sizeLabel => 'Taille';

  @override
  String get recordsLabel => 'Enregistrements';

  @override
  String get usageRecordsLabel => 'Enregistrements d\'utilisation';

  @override
  String get focusSessionsLabel => 'Sessions de concentration';

  @override
  String get appMetadataLabel => 'Métadonnées de l\'application';

  @override
  String get updatedLabel => 'Mis à jour';

  @override
  String get skippedLabel => 'Ignoré';

  @override
  String get faqSettingsQ4 =>
      'Comment puis-je restaurer ou exporter mes données ?';

  @override
  String get faqSettingsA4 =>
      'Vous pouvez aller dans les paramètres, et vous y trouverez la section Sauvegarde et restauration. Vous pouvez exporter ou importer des données à partir d\'ici. Notez que le fichier de données exporté est stocké dans Documents dans le dossier Scolect-Backups et seul ce fichier peut être utilisé pour restaurer les données, aucun autre fichier.';

  @override
  String get faqGeneralQ6 =>
      'Comment puis-je changer la langue et quelles langues sont disponibles ? Et si je trouve que la traduction est incorrecte ?';

  @override
  String get faqGeneralA6 =>
      'La langue peut être changée dans la section Général des paramètres, toutes les langues disponibles y sont listées. Vous pouvez demander une traduction en cliquant sur Contact et en envoyant votre demande avec la langue souhaitée. Sachez que la traduction peut être incorrecte car elle est générée par IA à partir de l\'anglais. Si vous souhaitez signaler une erreur, vous pouvez le faire via signaler un bug, contact, ou si vous êtes développeur, ouvrir un problème sur Github. Les contributions concernant les langues sont également les bienvenues !';

  @override
  String get faqGeneralQ7 =>
      'Et si je trouve que la traduction est incorrecte ?';

  @override
  String get faqGeneralA7 =>
      'La traduction peut être incorrecte car elle est générée par IA à partir de l\'anglais. Si vous souhaitez signaler une erreur, vous pouvez le faire via signaler un bug, contact, ou si vous êtes développeur, ouvrir un problème sur Github. Les contributions concernant les langues sont également les bienvenues !';

  @override
  String get activityTrackingSection => 'Suivi d\'Activité';

  @override
  String get idleDetectionTitle => 'Détection d\'Inactivité';

  @override
  String get idleDetectionDescription =>
      'Arrêter le suivi en cas d\'inactivité';

  @override
  String get idleTimeoutTitle => 'Délai d\'Inactivité';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'Temps avant de vous considérer inactif ($timeout)';
  }

  @override
  String get advancedWarning =>
      'Les fonctionnalités avancées peuvent augmenter l\'utilisation des ressources. Activez uniquement si nécessaire.';

  @override
  String get monitorAudioTitle => 'Surveiller l\'Audio Système';

  @override
  String get monitorAudioDescription =>
      'Détecter l\'activité par la lecture audio';

  @override
  String get audioSensitivityTitle => 'Sensibilité Audio';

  @override
  String audioSensitivityDescription(String value) {
    return 'Seuil de détection ($value)';
  }

  @override
  String get monitorControllersTitle => 'Surveiller les Manettes de Jeu';

  @override
  String get monitorControllersDescription =>
      'Détecter les manettes Xbox/XInput';

  @override
  String get monitorHIDTitle => 'Surveiller les Périphériques HID';

  @override
  String get monitorHIDDescription =>
      'Détecter volants, tablettes, périphériques personnalisés';

  @override
  String get setIdleTimeoutTitle => 'Définir le Délai d\'Inactivité';

  @override
  String get idleTimeoutDialogDescription =>
      'Choisissez combien de temps attendre avant de vous considérer inactif :';

  @override
  String get seconds30 => '30 secondes';

  @override
  String get minute1 => '1 minute';

  @override
  String get minutes2 => '2 minutes';

  @override
  String get minutes5 => '5 minutes';

  @override
  String get minutes10 => '10 minutes';

  @override
  String get customOption => 'Personnalisé';

  @override
  String get customDurationTitle => 'Durée Personnalisée';

  @override
  String get minutesLabel => 'Minutes';

  @override
  String get secondsLabel => 'Secondes';

  @override
  String get minAbbreviation => 'min';

  @override
  String get secAbbreviation => 'sec';

  @override
  String totalLabel(String duration) {
    return 'Total : $duration';
  }

  @override
  String minimumError(String value) {
    return 'Le minimum est $value';
  }

  @override
  String maximumError(String value) {
    return 'Le maximum est $value';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'Plage : $min - $max';
  }

  @override
  String get saveButton => 'Enregistrer';

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
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeTitle => 'Thème';

  @override
  String get themeDescription => 'Thème de couleur de l\'application';

  @override
  String get voiceGenderTitle => 'Genre de la voix';

  @override
  String get voiceGenderDescription =>
      'Choisissez le genre de la voix pour les notifications du minuteur';

  @override
  String get voiceGenderMale => 'Homme';

  @override
  String get voiceGenderFemale => 'Femme';

  @override
  String get alertsLimitsSubtitle =>
      'Gérez vos limites de temps d\'écran et vos notifications';

  @override
  String get applicationsSubtitle => 'Gérez vos applications suivies';

  @override
  String applicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications',
      one: '1 application',
    );
    return '$_temp0';
  }

  @override
  String get noApplicationsFound => 'Aucune application trouvée';

  @override
  String get tryAdjustingFilters => 'Essayez d\'ajuster vos filtres';

  @override
  String get configureAppSettings =>
      'Configurer les paramètres de l\'application';

  @override
  String get behaviorSection => 'Comportement';

  @override
  String helpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions dans 7 catégories',
      one: '1 question dans 7 catégories',
    );
    return '$_temp0';
  }

  @override
  String get searchForHelp => 'Rechercher de l\'aide...';

  @override
  String get quickNavGeneral => 'Général';

  @override
  String get quickNavApps => 'Applications';

  @override
  String get quickNavReports => 'Rapports';

  @override
  String get quickNavFocus => 'Focus';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get tryDifferentKeywords =>
      'Essayez de rechercher avec différents mots-clés';

  @override
  String get clearSearch => 'Effacer la Recherche';

  @override
  String get greetingMorning => 'Bonjour ! Voici votre résumé d\'activité.';

  @override
  String get greetingAfternoon =>
      'Bon après-midi ! Voici votre résumé d\'activité.';

  @override
  String get greetingEvening => 'Bonsoir ! Voici votre résumé d\'activité.';

  @override
  String get screenTimeProgress => 'Temps\nd\'Écran';

  @override
  String get productiveScoreProgress => 'Score de\nProductivité';

  @override
  String get focusModeSubtitle => 'Restez concentré, soyez productif';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get sessions => 'Sessions';

  @override
  String get totalTime => 'Temps total';

  @override
  String get avgLength => 'Durée Moyenne';

  @override
  String get focusTime => 'Temps de Concentration';

  @override
  String get paused => 'En Pause';

  @override
  String get shortBreakStatus => 'Courte Pause';

  @override
  String get longBreakStatus => 'Longue Pause';

  @override
  String get readyToFocus => 'Prêt à se Concentrer';

  @override
  String get focus => 'Concentration';

  @override
  String get restartSession => 'Redémarrer la Session';

  @override
  String get skipToNext => 'Passer au Suivant';

  @override
  String get settings => 'Paramètres';

  @override
  String sessionsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions terminées',
      one: '1 session terminée',
    );
    return '$_temp0';
  }

  @override
  String get focusModePreset => 'Préréglage du Mode Focus';

  @override
  String get focusDuration => 'Durée de Concentration';

  @override
  String minutesFormat(int minutes) {
    return '$minutes min';
  }

  @override
  String get shortBreakDuration => 'Courte Pause';

  @override
  String get longBreakDuration => 'Longue Pause';

  @override
  String get enableSounds => 'Activer les Sons';

  @override
  String get focus_mode_this_week => 'Cette Semaine';

  @override
  String get focus_mode_best_day => 'Meilleur Jour';

  @override
  String focus_mode_sessions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: '0 session',
    );
    return '$_temp0';
  }

  @override
  String get focus_mode_no_data_yet => 'Aucune donnée pour le moment';

  @override
  String get chart_current => 'Actuel';

  @override
  String get chart_previous => 'Précédent';

  @override
  String get permission_error => 'Erreur d\'Autorisation';

  @override
  String get notification_permission_denied =>
      'Autorisation de Notification Refusée';

  @override
  String get notification_permission_denied_message =>
      'ScreenTime a besoin de l\'autorisation de notification pour vous envoyer des alertes et des rappels.\n\nSouhaitez-vous ouvrir les Paramètres Système pour activer les notifications?';

  @override
  String get notification_permission_denied_hint =>
      'Ouvrez les Paramètres Système pour activer les notifications de ScreenTime.';

  @override
  String get notification_permission_required =>
      'Autorisation de Notification Requise';

  @override
  String get notification_permission_required_message =>
      'ScreenTime a besoin de l\'autorisation pour vous envoyer des notifications.';

  @override
  String get open_settings => 'Ouvrir les Paramètres';

  @override
  String get allow_notifications => 'Autoriser les Notifications';

  @override
  String get permission_allowed => 'Autorisé';

  @override
  String get permission_denied => 'Refusé';

  @override
  String get permission_not_set => 'Non Défini';

  @override
  String get on => 'Activé';

  @override
  String get off => 'Désactivé';

  @override
  String get enable_notification_permission_hint =>
      'Activez l\'autorisation de notification pour recevoir des alertes';

  @override
  String minutes_format(int minutes) {
    return '$minutes min';
  }

  @override
  String get chart_average => 'Moyenne';

  @override
  String get chart_peak => 'Pic';

  @override
  String get chart_lowest => 'Le plus bas';

  @override
  String get active => 'Actif';

  @override
  String get disabled => 'Désactivé';

  @override
  String get advanced_options => 'Options Avancées';

  @override
  String get sync_ready => 'Synchronisation Prête';

  @override
  String get success => 'Succès';

  @override
  String get destructive_badge => 'Destructif';

  @override
  String get recommended_badge => 'Recommandé';

  @override
  String get safe_badge => 'Sûr';

  @override
  String get overview => 'Aperçu';

  @override
  String get patterns => 'Modèles';

  @override
  String get apps => 'Applications';

  @override
  String get sortAscending => 'Trier Croissant';

  @override
  String get sortDescending => 'Trier Décroissant';

  @override
  String applicationsShowing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications affichées',
      one: '1 application affichée',
      zero: '0 application affichée',
    );
    return '$_temp0';
  }

  @override
  String valueLabel(String value) {
    return 'Valeur : $value';
  }

  @override
  String appsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications',
      one: '1 application',
      zero: '0 application',
    );
    return '$_temp0';
  }

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catégories',
      one: '1 catégorie',
      zero: '0 catégorie',
    );
    return '$_temp0';
  }

  @override
  String get systemNotificationsDisabled =>
      'Les notifications système sont désactivées. Activez-les dans les Réglages système pour les alertes de concentration.';

  @override
  String get openSystemSettings => 'Ouvrir les Réglages Système';

  @override
  String get appNotificationsDisabled =>
      'Les notifications sont désactivées dans les paramètres de l\'application. Activez-les pour recevoir des alertes de concentration.';

  @override
  String get goToSettings => 'Aller aux Paramètres';

  @override
  String get focusModeNotificationsDisabled =>
      'Les notifications du mode concentration sont désactivées. Activez-les pour recevoir des alertes de session.';

  @override
  String get notificationsDisabled => 'Notifications Désactivées';

  @override
  String get dontShowAgain => 'Ne plus afficher';

  @override
  String get systemSettingsRequired => 'Réglages Système Requis';

  @override
  String get notificationsDisabledSystemLevel =>
      'Les notifications sont désactivées au niveau du système. Pour activer :';

  @override
  String get step1OpenSystemSettings =>
      '1. Ouvrir les Réglages Système (Préférences Système)';

  @override
  String get step2GoToNotifications => '2. Aller aux Notifications';

  @override
  String get step3FindApp => '3. Trouver et sélectionner Scolect';

  @override
  String get step4EnableNotifications =>
      '4. Activer \"Autoriser les notifications\"';

  @override
  String get returnToAppMessage =>
      'Puis revenez à cette application et les notifications fonctionneront.';

  @override
  String get gotIt => 'Compris';

  @override
  String get noSessionsYet => 'Aucune session pour le moment';

  @override
  String applicationsTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications suivies',
      one: '1 application suivie',
      zero: '0 application suivie',
    );
    return '$_temp0';
  }

  @override
  String get applicationHeader => 'Application';

  @override
  String get currentUsageHeader => 'Utilisation Actuelle';

  @override
  String get dailyLimitHeader => 'Limite Quotidienne';

  @override
  String get edit => 'Modifier';

  @override
  String get showPopupNotifications =>
      'Afficher les notifications contextuelles';

  @override
  String get moreFrequentReminders => 'Rappels plus fréquents';

  @override
  String get playSoundWithAlerts => 'Jouer un son avec les alertes';

  @override
  String get systemTrayNotifications => 'Notifications dans la barre système';

  @override
  String screenTimeUsed(String current, String limit) {
    return '$current / $limit utilisé';
  }

  @override
  String get todaysScreenTime => 'Temps d\'Écran Aujourd\'hui';

  @override
  String get activeLimits => 'Limites Actives';

  @override
  String get nearLimit => 'Proche de la Limite';

  @override
  String get colorPickerSpectrum => 'Spectre';

  @override
  String get colorPickerPresets => 'Préréglages';

  @override
  String get colorPickerSliders => 'Curseurs';

  @override
  String get colorPickerBasicColors => 'Couleurs de Base';

  @override
  String get colorPickerExtendedPalette => 'Palette Étendue';

  @override
  String get colorPickerRed => 'Rouge';

  @override
  String get colorPickerGreen => 'Vert';

  @override
  String get colorPickerBlue => 'Bleu';

  @override
  String get colorPickerHue => 'Teinte';

  @override
  String get colorPickerSaturation => 'Saturation';

  @override
  String get colorPickerBrightness => 'Luminosité';

  @override
  String get colorPickerHexColor => 'Couleur Hexadécimale';

  @override
  String get colorPickerHexPlaceholder => 'RRVVBB';

  @override
  String get colorPickerRGB => 'RVB';

  @override
  String get select => 'Sélectionner';

  @override
  String get themeCustomization => 'Personnalisation du Thème';

  @override
  String get chooseThemePreset => 'Choisir un Thème Prédéfini';

  @override
  String get yourCustomThemes => 'Vos Thèmes Personnalisés';

  @override
  String get createCustomTheme => 'Créer un Thème Personnalisé';

  @override
  String get designOwnColorScheme =>
      'Concevez votre propre palette de couleurs';

  @override
  String get newTheme => 'Nouveau Thème';

  @override
  String get editCurrentTheme => 'Modifier le Thème Actuel';

  @override
  String customizeColorsFor(String themeName) {
    return 'Personnaliser les couleurs pour $themeName';
  }

  @override
  String customThemeNumber(int number) {
    return 'Thème Personnalisé $number';
  }

  @override
  String get deleteCustomTheme => 'Supprimer le Thème Personnalisé';

  @override
  String confirmDeleteTheme(String themeName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$themeName\" ?';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get customizeTheme => 'Personnaliser le Thème';

  @override
  String get preview => 'Aperçu';

  @override
  String get themeName => 'Nom du Thème';

  @override
  String get brandColors => 'Couleurs de Marque';

  @override
  String get lightTheme => 'Thème Clair';

  @override
  String get darkTheme => 'Thème Sombre';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get saveTheme => 'Enregistrer le Thème';

  @override
  String get customTheme => 'Thème Personnalisé';

  @override
  String get primaryColors => 'Couleurs Principales';

  @override
  String get primaryColorsDesc =>
      'Couleurs d\'accentuation principales utilisées dans toute l\'application';

  @override
  String get primaryAccent => 'Accent Principal';

  @override
  String get primaryAccentDesc =>
      'Couleur de marque principale, boutons, liens';

  @override
  String get secondaryAccent => 'Accent Secondaire';

  @override
  String get secondaryAccentDesc => 'Accent complémentaire pour les dégradés';

  @override
  String get semanticColors => 'Couleurs Sémantiques';

  @override
  String get semanticColorsDesc =>
      'Couleurs qui transmettent un sens et un état';

  @override
  String get successColor => 'Couleur de Succès';

  @override
  String get successColorDesc => 'Actions positives, confirmations';

  @override
  String get warningColor => 'Couleur d\'Avertissement';

  @override
  String get warningColorDesc => 'Prudence, états en attente';

  @override
  String get errorColor => 'Couleur d\'Erreur';

  @override
  String get errorColorDesc => 'Erreurs, actions destructrices';

  @override
  String get backgroundColors => 'Couleurs d\'Arrière-plan';

  @override
  String get backgroundColorsLightDesc =>
      'Surfaces d\'arrière-plan principales pour le mode clair';

  @override
  String get backgroundColorsDarkDesc =>
      'Surfaces d\'arrière-plan principales pour le mode sombre';

  @override
  String get background => 'Arrière-plan';

  @override
  String get backgroundDesc => 'Arrière-plan principal de l\'application';

  @override
  String get surface => 'Surface';

  @override
  String get surfaceDesc => 'Cartes, dialogues, surfaces élevées';

  @override
  String get surfaceSecondary => 'Surface Secondaire';

  @override
  String get surfaceSecondaryDesc => 'Cartes secondaires, barres latérales';

  @override
  String get border => 'Bordure';

  @override
  String get borderDesc => 'Diviseurs, bordures de cartes';

  @override
  String get textColors => 'Couleurs de Texte';

  @override
  String get textColorsLightDesc =>
      'Couleurs de typographie pour le mode clair';

  @override
  String get textColorsDarkDesc =>
      'Couleurs de typographie pour le mode sombre';

  @override
  String get textPrimary => 'Texte Principal';

  @override
  String get textPrimaryDesc => 'Titres, texte important';

  @override
  String get textSecondary => 'Texte Secondaire';

  @override
  String get textSecondaryDesc => 'Descriptions, légendes';

  @override
  String previewMode(String mode) {
    return 'Aperçu : Mode $mode';
  }

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get sampleCardTitle => 'Titre de Carte Exemple';

  @override
  String get sampleSecondaryText =>
      'Ceci est un texte secondaire qui apparaît en dessous.';

  @override
  String get primary => 'Principal';

  @override
  String get secondary => 'Secondaire';

  @override
  String get warning => 'Avertissement';

  @override
  String get launchAtStartupTitle => 'Lancer au démarrage';

  @override
  String get launchAtStartupDescription =>
      'Démarrer automatiquement Scolect lorsque vous vous connectez à votre ordinateur';

  @override
  String get inputMonitoringPermissionTitle =>
      'Surveillance du clavier indisponible';

  @override
  String get inputMonitoringPermissionDescription =>
      'Activez l’autorisation de surveillance des entrées pour suivre l’activité du clavier. Actuellement, seule la souris est surveillée.';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get permissionGrantedTitle => 'Autorisation accordée';

  @override
  String get permissionGrantedDescription =>
      'L’application doit redémarrer pour que la surveillance des entrées soit effective.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get restartRequiredTitle => 'Redémarrage requis';

  @override
  String get restartRequiredDescription =>
      'Pour activer la surveillance du clavier, l’application doit redémarrer. Ceci est requis par macOS.';

  @override
  String get restartNote =>
      'L’application se relancera automatiquement après le redémarrage.';

  @override
  String get restartNow => 'Redémarrer maintenant';

  @override
  String get restartLater => 'Redémarrer plus tard';

  @override
  String get restartFailedTitle => 'Échec du redémarrage';

  @override
  String get restartFailedMessage =>
      'Impossible de redémarrer automatiquement l’application. Quittez-la (Cmd+Q) et relancez-la manuellement.';

  @override
  String get exportAnalyticsReport => 'Exporter le Rapport d\'Analyse';

  @override
  String get chooseExportFormat => 'Choisissez le format d\'exportation :';

  @override
  String get beautifulExcelReport => 'Magnifique Rapport Excel';

  @override
  String get beautifulExcelReportDescription =>
      'Feuille de calcul colorée et magnifique avec graphiques, emojis et insights ✨';

  @override
  String get excelReportIncludes => 'Le rapport Excel comprend :';

  @override
  String get summarySheetDescription =>
      '📊 Feuille de Résumé - Métriques clés avec tendances';

  @override
  String get dailyBreakdownDescription =>
      '📅 Détail Quotidien - Modèles d\'utilisation visuels';

  @override
  String get appsSheetDescription =>
      '📱 Feuille Apps - Classements détaillés des applications';

  @override
  String get insightsDescription =>
      '💡 Insights - Recommandations intelligentes';

  @override
  String get beautifulExcelExportSuccess =>
      'Magnifique rapport Excel exporté avec succès ! 🎉';

  @override
  String failedToExportReport(String error) {
    return 'Échec de l\'exportation du rapport : $error';
  }

  @override
  String get exporting => 'Exportation...';

  @override
  String get exportExcel => 'Exporter Excel';

  @override
  String get saveAnalyticsReport => 'Enregistrer le Rapport d\'Analyse';

  @override
  String analyticsReportFileName(String timestamp) {
    return 'rapport_analytique_$timestamp.xlsx';
  }

  @override
  String get usageAnalyticsReportTitle => 'RAPPORT D\'ANALYSE D\'UTILISATION';

  @override
  String get generated => 'Généré :';

  @override
  String get period => 'Période :';

  @override
  String dateRangeValue(String startDate, String endDate) {
    return '$startDate au $endDate';
  }

  @override
  String get keyMetrics => 'MÉTRIQUES CLÉS';

  @override
  String get metric => 'Métrique';

  @override
  String get value => 'Valeur';

  @override
  String get change => 'Changement';

  @override
  String get trend => 'Tendance';

  @override
  String get productivityRate => 'Taux de Productivité';

  @override
  String get trendUp => 'Hausse';

  @override
  String get trendDown => 'Baisse';

  @override
  String get trendExcellent => 'Excellent';

  @override
  String get trendGood => 'Bon';

  @override
  String get trendNeedsImprovement => 'À Améliorer';

  @override
  String get trendActive => 'Actif';

  @override
  String get trendNone => 'Aucun';

  @override
  String get trendTop => 'Top';

  @override
  String get category => 'Catégorie';

  @override
  String get percentage => 'Pourcentage';

  @override
  String get visual => 'Visuel';

  @override
  String get statistics => 'STATISTIQUES';

  @override
  String get averageDaily => 'Moyenne Quotidienne';

  @override
  String get highestDay => 'Jour le Plus Élevé';

  @override
  String get lowestDay => 'Jour le Plus Bas';

  @override
  String get day => 'Jour';

  @override
  String get applicationUsageDetails =>
      'DÉTAILS D\'UTILISATION DES APPLICATIONS';

  @override
  String get totalApps => 'Total des Apps :';

  @override
  String get productiveApps => 'Apps Productives :';

  @override
  String get rank => 'Rang';

  @override
  String get application => 'Application';

  @override
  String get time => 'Temps';

  @override
  String get percentOfTotal => '% du Total';

  @override
  String get type => 'Type';

  @override
  String get usageLevel => 'Niveau d\'Utilisation';

  @override
  String get leisure => 'Loisir';

  @override
  String get usageLevelVeryHigh => 'Très Élevé ||||||||';

  @override
  String get usageLevelHigh => 'Élevé ||||||';

  @override
  String get usageLevelMedium => 'Moyen ||||';

  @override
  String get usageLevelLow => 'Faible ||';

  @override
  String get keyInsightsTitle => 'PERSPECTIVES ET RECOMMANDATIONS CLÉS';

  @override
  String get personalizedRecommendations => 'RECOMMANDATIONS PERSONNALISÉES';

  @override
  String insightHighDailyUsage(String hours) {
    return 'Utilisation Quotidienne Élevée : Vous utilisez en moyenne $hours heures par jour';
  }

  @override
  String insightLowDailyUsage(String hours) {
    return 'Faible Utilisation Quotidienne : En moyenne $hours heures par jour - excellent équilibre !';
  }

  @override
  String insightModerateUsage(String hours) {
    return 'Utilisation Modérée : En moyenne $hours heures de temps d\'écran par jour';
  }

  @override
  String insightExcellentProductivity(String percentage) {
    return 'Excellente Productivité : $percentage% de votre temps d\'écran est du travail productif !';
  }

  @override
  String insightGoodProductivity(String percentage) {
    return 'Bonne Productivité : $percentage% de votre temps d\'écran est productif';
  }

  @override
  String insightLowProductivity(String percentage) {
    return 'Alerte Faible Productivité : Seulement $percentage% du temps d\'écran est productif';
  }

  @override
  String insightFocusSessions(int count, String avgPerDay) {
    return 'Sessions de Concentration : $count sessions complétées ($avgPerDay par jour en moyenne)';
  }

  @override
  String insightGreatFocusHabit(int count) {
    return 'Excellente Habitude de Concentration : Vous avez construit une routine incroyable avec $count sessions complétées !';
  }

  @override
  String get insightNoFocusSessions =>
      'Aucune Session de Concentration : Pensez à utiliser le mode concentration pour augmenter votre productivité';

  @override
  String insightScreenTimeTrend(String direction, String percentage) {
    return 'Tendance Temps d\'Écran : Votre utilisation a $direction de $percentage% par rapport à la période précédente';
  }

  @override
  String insightProductiveTimeTrend(String direction, String percentage) {
    return 'Tendance Temps Productif : Votre temps productif a $direction de $percentage% par rapport à la période précédente';
  }

  @override
  String get directionIncreased => 'augmenté';

  @override
  String get directionDecreased => 'diminué';

  @override
  String insightTopCategory(String category, String percentage) {
    return 'Catégorie Principale : $category domine avec $percentage% de votre temps total';
  }

  @override
  String insightMostUsedApp(
      String appName, String percentage, String duration) {
    return 'App la Plus Utilisée : $appName représente $percentage% de votre temps ($duration)';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return 'L\'Utilisation Varie Significativement : $highDay avait ${multiplier}x plus d\'utilisation que $lowDay';
  }

  @override
  String get insightNoInsights => 'Aucune perspective significative disponible';

  @override
  String get recScheduleFocusSessions =>
      'Essayez de planifier plus de sessions de concentration tout au long de la journée pour augmenter la productivité';

  @override
  String get recSetAppLimits =>
      'Envisagez de définir des limites sur les applications de loisir';

  @override
  String get recAimForFocusSessions =>
      'Visez au moins 1-2 sessions de concentration par jour pour créer une habitude constante';

  @override
  String get recTakeBreaks =>
      'Votre temps d\'écran quotidien est assez élevé. Essayez de prendre des pauses régulières en utilisant la règle 20-20-20';

  @override
  String get recSetDailyGoals =>
      'Envisagez de définir des objectifs quotidiens de temps d\'écran pour réduire progressivement l\'utilisation';

  @override
  String get recBalanceEntertainment =>
      'Les apps de divertissement occupent une grande partie de votre temps. Envisagez d\'équilibrer avec des activités plus productives';

  @override
  String get recReviewUsagePatterns =>
      'Votre temps d\'écran a considérablement augmenté. Examinez vos habitudes d\'utilisation et fixez des limites';

  @override
  String get recScheduleFocusedWork =>
      'Votre temps productif a diminué. Essayez de planifier des blocs de travail concentré dans votre calendrier';

  @override
  String get recKeepUpGreatWork =>
      'Continuez comme ça ! Vos habitudes de temps d\'écran semblent saines';

  @override
  String get recContinueFocusSessions =>
      'Continuez à utiliser les sessions de concentration pour maintenir la productivité';

  @override
  String get sheetSummary => 'Résumé';

  @override
  String get sheetDailyBreakdown => 'Détail Quotidien';

  @override
  String get sheetApps => 'Apps';

  @override
  String get sheetInsights => 'Perspectives';

  @override
  String get statusHeader => 'Statut';

  @override
  String workSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions de travail',
      one: '$count session de travail',
    );
    return '$_temp0';
  }

  @override
  String get complete => 'Terminé';

  @override
  String get inProgress => 'En cours';

  @override
  String get workTime => 'Temps de travail';

  @override
  String get breakTime => 'Temps de pause';

  @override
  String get phasesCompleted => 'Phases terminées';

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
      other: '$count sessions',
      one: '$count session',
    );
    return '$_temp0';
  }

  @override
  String get workPhases => 'Phases de travail';

  @override
  String get averageLength => 'Durée moyenne';

  @override
  String get mostProductive => 'Plus productif';

  @override
  String get work => 'Travail';

  @override
  String get breaks => 'Pauses';

  @override
  String get none => 'Aucun';

  @override
  String minuteShortFormat(String minutes) {
    return '${minutes}m';
  }

  @override
  String get importTheme => 'Importer le thème';

  @override
  String get exportTheme => 'Exporter le thème';

  @override
  String get import => 'Importer';

  @override
  String get export => 'Exporter';

  @override
  String get chooseExportMethod => 'Choisissez comment exporter votre thème :';

  @override
  String get saveAsFile => 'Enregistrer en fichier';

  @override
  String get saveThemeAsJSONFile =>
      'Enregistrer le thème en fichier JSON sur votre appareil';

  @override
  String get copyToClipboard => 'Copier dans le presse-papiers';

  @override
  String get copyThemeJSONToClipboard =>
      'Copier les données du thème dans le presse-papiers';

  @override
  String get share => 'Partager';

  @override
  String get shareThemeViaSystemSheet =>
      'Partager le thème via la feuille de partage système';

  @override
  String get chooseImportMethod => 'Choisissez comment importer un thème :';

  @override
  String get loadFromFile => 'Charger depuis un fichier';

  @override
  String get selectJSONFileFromDevice =>
      'Sélectionnez un fichier JSON de thème depuis votre appareil';

  @override
  String get pasteFromClipboard => 'Coller depuis le presse-papiers';

  @override
  String get importFromClipboardJSON =>
      'Importer le thème depuis les données JSON du presse-papiers';

  @override
  String get importFromFile => 'Importer le thème depuis un fichier';

  @override
  String get themeCreatedSuccessfully => 'Thème créé avec succès !';

  @override
  String get themeUpdatedSuccessfully => 'Thème mis à jour avec succès !';

  @override
  String get themeDeletedSuccessfully => 'Thème supprimé avec succès !';

  @override
  String get themeExportedSuccessfully => 'Thème exporté avec succès !';

  @override
  String get themeCopiedToClipboard => 'Thème copié dans le presse-papiers !';

  @override
  String themeImportedSuccessfully(String themeName) {
    return 'Thème « $themeName » importé avec succès !';
  }

  @override
  String get noThemeDataFound => 'Aucune donnée de thème trouvée';

  @override
  String get invalidThemeFormat =>
      'Format de thème invalide. Veuillez vérifier les données JSON.';

  @override
  String get trackingModeTitle => 'Mode de suivi';

  @override
  String get trackingModeDescription =>
      'Choisissez comment l\'utilisation de l\'application est suivie';

  @override
  String get trackingModePolling => 'Standard (Faibles ressources)';

  @override
  String get trackingModePrecise => 'Précis (Haute précision)';

  @override
  String get trackingModePollingHint =>
      'Vérifie chaque minute - faible utilisation des ressources';

  @override
  String get trackingModePreciseHint =>
      'Suivi en temps réel - plus de précision, plus de ressources';

  @override
  String get trackingModeChangeError =>
      'Échec du changement de mode de suivi. Veuillez réessayer.';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get monitorKeyboardTitle => 'Surveiller le Clavier';

  @override
  String get monitorKeyboardDescription =>
      'Suivre l\'activité du clavier pour détecter la présence de l\'utilisateur';

  @override
  String get changelogWhatsNew => 'Nouveautés';

  @override
  String changelogReleasedOn(String date) {
    return 'Publié le $date';
  }

  @override
  String get changelogNoContent =>
      'Aucun journal des modifications disponible pour cette version.';

  @override
  String get changelogUnableToLoad =>
      'Impossible de charger le journal des modifications';

  @override
  String get changelogErrorDescription =>
      'Impossible de récupérer le journal des modifications pour cette version. Veuillez vérifier votre connexion internet ou consulter la page des versions GitHub.';

  @override
  String get allTracking => 'Toutes les apps';

  @override
  String get notTracking => 'Non suivies';

  @override
  String get allVisibility => 'Toutes';

  @override
  String get visible => 'Visibles';

  @override
  String get hidden => 'Masquées';

  @override
  String get todaysLimitUsage => 'Utilisation de la limite du jour';

  @override
  String get thisWeekAtAGlance => 'Cette semaine en un coup d\'œil';

  @override
  String get hourlyActivityHeatmap => 'Carte thermique d\'activité horaire';

  @override
  String get productivityScore => 'Score de productivité';

  @override
  String get streaks => 'Séries';

  @override
  String get weekOverWeek => 'Semaine après semaine';

  @override
  String get sameAsLastWeek => 'Identique à la semaine dernière';

  @override
  String moreUsageThanLastWeek(String percent) {
    return '$percent% de plus que la semaine dernière';
  }

  @override
  String lessUsageThanLastWeek(String percent) {
    return '$percent% de moins que la semaine dernière';
  }

  @override
  String limitExceededBy(String duration) {
    return 'Limite dépassée de $duration';
  }

  @override
  String timeRemaining(String duration) {
    return '$duration restant';
  }

  @override
  String get totalSessions => 'Sessions totales';

  @override
  String get avgSession => 'Session moyenne';

  @override
  String get mostActive => 'Le plus actif';

  @override
  String get peakUsage => 'Utilisation maximale';

  @override
  String get dailyAverage => 'Moyenne quotidienne';

  @override
  String get daysUsedInARow => 'Jours d\'utilisation consécutifs';

  @override
  String get daysSingular => 'jour';

  @override
  String get daysPlural => 'jours';

  @override
  String get daysOverLimitInARow => 'Jours consécutifs au-dessus de la limite';

  @override
  String get withinLimitAllWeek => 'Dans la limite toute la semaine';

  @override
  String get productivityScoreGreat => 'Excellent';

  @override
  String get productivityScoreModerate => 'Modéré';

  @override
  String get productivityScoreNeedsAttention => 'Attention requise';

  @override
  String get productiveAppMotivation =>
      'Application productive — continuez ainsi';

  @override
  String get nonProductiveAppSuggestion =>
      'Non productive — envisagez de réduire';

  @override
  String get legendUsage => 'Utilisation';

  @override
  String get legendAverage => 'Moyenne';

  @override
  String get legendLimit => 'Limite';

  @override
  String get chartPeak => 'Maximum';

  @override
  String overLimitBy(String duration) {
    return '+$duration au-dessus de la limite';
  }

  @override
  String get noData => 'Aucune donnée';

  @override
  String get yesterday => 'Hier';

  @override
  String get changelog => 'Journal des modifications';

  @override
  String get exportingLabel => 'Exportation en cours...';

  @override
  String get exportExcelLabel => 'Exporter Excel';
}
