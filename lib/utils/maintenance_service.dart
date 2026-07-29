import 'dart:async';
import 'package:screentime/sections/controller/app_data_controller.dart';
class MaintenanceService {
  final AppDataStore _dataStore = AppDataStore();
  Timer? _maintenanceTimer;
  
  // Start periodic maintenance
  void startPeriodicMaintenance() {
    // Run maintenance once on startup
    _dataStore.checkAndRepairBoxes();
    
    // Set a timer to run maintenance every 8 hours
    _maintenanceTimer = Timer.periodic(
      Duration(hours: 8), 
      (_) => _dataStore.checkAndRepairBoxes()
    );
  }
  
  // Stop maintenance timer
  void stopPeriodicMaintenance() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = null;
  }
}