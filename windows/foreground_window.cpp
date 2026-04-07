#include "include/foreground_window/foreground_window_plugin.h"

#include <windows.h>
#include <psapi.h>
#include <tlhelp32.h>
#include <string>
#include <vector>
#include <algorithm>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/encodable_value.h>

class ForegroundWindowPlugin : public flutter::Plugin {
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(),
            "foreground_window_plugin",
            &flutter::StandardMethodCodec::GetInstance()
        );
        auto plugin = std::make_unique<ForegroundWindowPlugin>();
        channel->SetMethodCallHandler(
            [plugin = plugin.get()](const flutter::MethodCall<flutter::EncodableValue>& call,
               std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
                plugin->HandleMethodCall(call, std::move(result));
            }
        );
        registrar->AddPlugin(std::move(plugin));
    }

    ForegroundWindowPlugin() {}

private:
    // Get parent process ID
    DWORD GetParentProcessId(DWORD processId) {
        DWORD parentProcessId = 0;
        HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        
        if (hSnapshot != INVALID_HANDLE_VALUE) {
            PROCESSENTRY32 pe32;
            pe32.dwSize = sizeof(PROCESSENTRY32);
            
            if (Process32First(hSnapshot, &pe32)) {
                do {
                    if (pe32.th32ProcessID == processId) {
                        parentProcessId = pe32.th32ParentProcessID;
                        break;
                    }
                } while (Process32Next(hSnapshot, &pe32));
            }
            CloseHandle(hSnapshot);
        }
        
        return parentProcessId;
    }

    // Check if app is registered for auto-start
    bool IsRegisteredForAutoStart() {
        bool result = false;

        
        // Get current executable path
        char exePath[MAX_PATH] = {0};
        GetModuleFileNameA(NULL, exePath, MAX_PATH);
        
        // Helper lambda: enumerate a Run key and check if any value contains exePath.
        auto checkRunKey = [&](HKEY root, const char* subkey) -> bool {
            HKEY hRunKey;
            if (RegOpenKeyExA(root, subkey, 0, KEY_READ, &hRunKey) != ERROR_SUCCESS)
                return false;

            // Query the key to find the maximum value-data size so we can
            // allocate a buffer large enough (registry values can exceed MAX_PATH).
            DWORD maxValueDataLen = 0;
            RegQueryInfoKeyA(hRunKey, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, &maxValueDataLen, NULL, NULL);
            if (maxValueDataLen == 0) maxValueDataLen = MAX_PATH;
            maxValueDataLen += 1; // null terminator

            std::vector<char> valueData(maxValueDataLen, 0);
            char valueName[MAX_PATH];
            DWORD valueNameSize = MAX_PATH;
            DWORD valueDataSize = maxValueDataLen;
            DWORD index = 0;
            bool found = false;

            while (RegEnumValueA(hRunKey, index, valueName, &valueNameSize,
                                 NULL, NULL, (LPBYTE)valueData.data(), &valueDataSize) == ERROR_SUCCESS) {
                valueData[valueDataSize < maxValueDataLen ? valueDataSize : maxValueDataLen - 1] = '\0';
                if (strstr(valueData.data(), exePath) != NULL) {
                    found = true;
                    break;
                }
                valueNameSize = MAX_PATH;
                valueDataSize = maxValueDataLen;
                index++;
            }

            RegCloseKey(hRunKey);
            return found;
        };

        // Check HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
        if (checkRunKey(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"))
            result = true;

        // Also check HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
        if (!result && checkRunKey(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"))
            result = true;
        
        return result;
    }

    // Check process start time relative to system boot
    bool WasStartedWithSystem() {
        FILETIME processTime, systemTime, exitTime, kernelTime, userTime;
        
        // Get process creation time
        HANDLE hProcess = GetCurrentProcess();
        GetProcessTimes(hProcess, &processTime, &exitTime, &kernelTime, &userTime);
        
        // Get current system time
        GetSystemTimeAsFileTime(&systemTime);
        
        // Get system uptime in milliseconds
        ULARGE_INTEGER uptime;
        uptime.QuadPart = GetTickCount64();
        
        // Calculate system boot time by subtracting uptime from current time
        ULARGE_INTEGER ulSystemTime, ulProcessTime, ulBootTime;
        ulSystemTime.LowPart = systemTime.dwLowDateTime;
        ulSystemTime.HighPart = systemTime.dwHighDateTime;
        
        ulProcessTime.LowPart = processTime.dwLowDateTime;
        ulProcessTime.HighPart = processTime.dwHighDateTime;
        
        // Convert uptime from milliseconds to 100-nanosecond intervals (FILETIME units)
        uptime.QuadPart *= 10000;
        ulBootTime.QuadPart = ulSystemTime.QuadPart - uptime.QuadPart;
        
        // If process started within 60 seconds of boot, it's likely auto-started
        // Calculate time difference in seconds
        ULONGLONG diffInSeconds = (ulProcessTime.QuadPart - ulBootTime.QuadPart) / 10000000;
        
        return diffInSeconds < 60;
    }

    // Get command line arguments
    std::vector<std::string> GetCommandLineArgs() {
        std::vector<std::string> args;
        LPWSTR commandLine = GetCommandLineW();
        int argc;
        LPWSTR* argv = CommandLineToArgvW(commandLine, &argc);
        
        if (argv) {
            for (int i = 0; i < argc; i++) {
                int size = WideCharToMultiByte(CP_UTF8, 0, argv[i], -1, nullptr, 0, nullptr, nullptr);
                std::string arg(size, 0);
                WideCharToMultiByte(CP_UTF8, 0, argv[i], -1, &arg[0], size, nullptr, nullptr);
                arg.resize(size - 1);  // Remove null terminator
                args.push_back(arg);
            }
            LocalFree(argv);
        }
        
        return args;
    }

    // Get program name from executable path
    // Enhanced version of GetProgramName
std::string GetProgramName(const std::string& fullProcessPath) {
    // Extract executable name from the full path
    std::string executableName = fullProcessPath;
    size_t lastSlash = fullProcessPath.find_last_of("\\/");
    if (lastSlash != std::string::npos) {
        executableName = fullProcessPath.substr(lastSlash + 1);
    }

    // Remove .exe extension if present for a cleaner fallback
    std::string cleanName = executableName;
    size_t dotPos = cleanName.rfind(".exe");
    if (dotPos != std::string::npos) {
        cleanName = cleanName.substr(0, dotPos);
    }

    // First try: Get program name from version info
    std::string programName = ""; // Will be set to a non-empty value if we find version info
    DWORD versionInfoSize = GetFileVersionInfoSizeA(fullProcessPath.c_str(), NULL);
    if (versionInfoSize > 0) {
        std::vector<BYTE> versionInfo(versionInfoSize);
        if (GetFileVersionInfoA(fullProcessPath.c_str(), 0, versionInfoSize, versionInfo.data())) {
            LPVOID fileDescription = NULL;
            UINT descriptionLen = 0;
            bool foundName = false;
            
            // Structure to hold language and codepage information
            struct LANGANDCODEPAGE {
                WORD wLanguage;
                WORD wCodePage;
            } *lpTranslate;
            UINT cbTranslate = 0;
            
            // Get language info
            if (VerQueryValueA(versionInfo.data(), "\\VarFileInfo\\Translation", 
                            (LPVOID*)&lpTranslate, &cbTranslate)) {
                
                // Try each language and codepage
                for (UINT i = 0; i < (cbTranslate / sizeof(LANGANDCODEPAGE)); i++) {
                    // Create strings for the queries
                    char subBlock[128];
                    
                    // Try FileDescription first (usually the most user-friendly)
                    sprintf_s(subBlock, "\\StringFileInfo\\%04x%04x\\FileDescription", 
                            lpTranslate[i].wLanguage, lpTranslate[i].wCodePage);
                    
                    if (VerQueryValueA(versionInfo.data(), subBlock, &fileDescription, &descriptionLen) && 
                        descriptionLen > 0 && fileDescription != NULL) {
                        programName = std::string(static_cast<char*>(fileDescription));
                        foundName = true;
                        break;
                    }
                    
                    // If FileDescription not found, try ProductName
                    sprintf_s(subBlock, "\\StringFileInfo\\%04x%04x\\ProductName", 
                            lpTranslate[i].wLanguage, lpTranslate[i].wCodePage);
                    
                    if (VerQueryValueA(versionInfo.data(), subBlock, &fileDescription, &descriptionLen) && 
                        descriptionLen > 0 && fileDescription != NULL) {
                        programName = std::string(static_cast<char*>(fileDescription));
                        foundName = true;
                        break;
                    }
                }
            }
            
            // If we didn't find any name using dynamic language detection, 
            // try the common language codes as a fallback
            if (!foundName) {
                // List of common language identifiers to try
                const char* languageCodes[] = {
                    "\\StringFileInfo\\040904E4\\", // English US
                    "\\StringFileInfo\\040904B0\\", // English US (alternate)
                    "\\StringFileInfo\\080404B0\\", // Chinese PRC
                    "\\StringFileInfo\\040704B0\\", // German
                    "\\StringFileInfo\\040C04B0\\", // French
                    "\\StringFileInfo\\041904B0\\", // Russian
                    "\\StringFileInfo\\040A04B0\\", // Spanish
                    "\\StringFileInfo\\041604B0\\", // Portuguese
                    "\\StringFileInfo\\041104B0\\"  // Japanese
                };
                
                for (const char* langCode : languageCodes) {
                    std::string fileDescPath = std::string(langCode) + "FileDescription";
                    std::string productNamePath = std::string(langCode) + "ProductName";
                    
                    if (VerQueryValueA(versionInfo.data(), fileDescPath.c_str(), 
                                    &fileDescription, &descriptionLen) && 
                        descriptionLen > 0 && fileDescription != NULL) {
                        programName = std::string(static_cast<char*>(fileDescription));
                        foundName = true;
                        break;
                    }
                    else if (VerQueryValueA(versionInfo.data(), productNamePath.c_str(), 
                                    &fileDescription, &descriptionLen) && 
                            descriptionLen > 0 && fileDescription != NULL) {
                        programName = std::string(static_cast<char*>(fileDescription));
                        foundName = true;
                        break;
                    }
                }
            }
        }
    }
    
    // Second try: Check for manifest embedded in the executable or next to it
    if (programName.empty()) {
        // First check for embedded manifest
        HMODULE hModule = LoadLibraryExA(fullProcessPath.c_str(), NULL, LOAD_LIBRARY_AS_DATAFILE);
        if (hModule != NULL) {
            // Fix: Use proper constant for RT_MANIFEST
            HRSRC hResInfo = FindResourceA(hModule, MAKEINTRESOURCEA(1), MAKEINTRESOURCEA(24)); // 24 is RT_MANIFEST
            if (hResInfo != NULL) {
                HGLOBAL hResData = LoadResource(hModule, hResInfo);
                if (hResData != NULL) {
                    DWORD size = SizeofResource(hModule, hResInfo);
                    const char* manifest = static_cast<const char*>(LockResource(hResData));
                    if (manifest != NULL && size > 0) {
                        std::string manifestStr(manifest, size);
                        
                        // Look for product name in manifest
                        size_t namePos = manifestStr.find("<name>");
                        if (namePos != std::string::npos) {
                            size_t nameEndPos = manifestStr.find("</name>", namePos);
                            if (nameEndPos != std::string::npos) {
                                programName = manifestStr.substr(
                                    namePos + 6, // Length of "<name>"
                                    nameEndPos - (namePos + 6)
                                );
                            }
                        }
                        
                        // Look for description in manifest if name not found
                        if (programName.empty()) {
                            size_t descPos = manifestStr.find("<description>");
                            if (descPos != std::string::npos) {
                                size_t descEndPos = manifestStr.find("</description>", descPos);
                                if (descEndPos != std::string::npos) {
                                    programName = manifestStr.substr(
                                        descPos + 13, // Length of "<description>"
                                        descEndPos - (descPos + 13)
                                    );
                                }
                            }
                        }
                    }
                }
            }
            FreeLibrary(hModule);
        }
        
        // If embedded manifest didn't work, check for external manifest file
        if (programName.empty()) {
            std::string manifestPath = fullProcessPath + ".manifest";
            HANDLE hFile = CreateFileA(manifestPath.c_str(), GENERIC_READ, FILE_SHARE_READ, 
                                      NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
            
            if (hFile != INVALID_HANDLE_VALUE) {
                DWORD fileSize = GetFileSize(hFile, NULL);
                if (fileSize != INVALID_FILE_SIZE && fileSize > 0) {
                    std::vector<char> buffer(fileSize + 1);
                    DWORD bytesRead;
                    
                    if (ReadFile(hFile, buffer.data(), fileSize, &bytesRead, NULL) && bytesRead > 0) {
                        buffer[bytesRead] = '\0';
                        std::string manifestStr(buffer.data());
                        
                        // Look for product name in manifest
                        size_t namePos = manifestStr.find("<name>");
                        if (namePos != std::string::npos) {
                            size_t nameEndPos = manifestStr.find("</name>", namePos);
                            if (nameEndPos != std::string::npos) {
                                programName = manifestStr.substr(
                                    namePos + 6, // Length of "<name>"
                                    nameEndPos - (namePos + 6)
                                );
                            }
                        }
                        
                        // Look for description in manifest if name not found
                        if (programName.empty()) {
                            size_t descPos = manifestStr.find("<description>");
                            if (descPos != std::string::npos) {
                                size_t descEndPos = manifestStr.find("</description>", descPos);
                                if (descEndPos != std::string::npos) {
                                    programName = manifestStr.substr(
                                        descPos + 13, // Length of "<description>"
                                        descEndPos - (descPos + 13)
                                    );
                                }
                            }
                        }
                    }
                }
                CloseHandle(hFile);
            }
        }
    }
    
    // Final fallback: Use the clean executable name
    if (programName.empty()) {
        // Use the cleaned executable name (without .exe)
        programName = cleanName;
        
        // Attempt to make it more readable
        if (!programName.empty()) {
            // Fix: Properly handle char conversion to avoid warnings
            // Capitalize first letter
            if (!programName.empty() && islower(static_cast<unsigned char>(programName[0]))) {
                programName[0] = static_cast<char>(toupper(static_cast<unsigned char>(programName[0])));
            }
            
            // Convert underscores to spaces and capitalize words
            for (size_t i = 1; i < programName.length(); i++) {
                if (programName[i-1] == '_' || programName[i-1] == '-') {
                    if (islower(static_cast<unsigned char>(programName[i]))) {
                        programName[i] = static_cast<char>(toupper(static_cast<unsigned char>(programName[i])));
                    }
                }
            }
            
            // Replace underscores and hyphens with spaces
            std::replace(programName.begin(), programName.end(), '_', ' ');
            std::replace(programName.begin(), programName.end(), '-', ' ');
        }
    }
    
    return programName;
}

    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) 
    {
        if (call.method_name() == "getForegroundWindow") {
            HWND hwnd = GetForegroundWindow();
            if (hwnd == NULL) {
                result->Error("NO_WINDOW", "No foreground window found");
                return;
            }
            
            // Get process ID
            DWORD processID = 0;
            GetWindowThreadProcessId(hwnd, &processID);
            if (processID == 0) {
                result->Error("PROCESS_ERROR", "Failed to get process ID for foreground window");
                return;
            }

            // Get window title
            char windowTitle[256] = {0};
            GetWindowTextA(hwnd, windowTitle, sizeof(windowTitle));

            // Open the process
            HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processID);
            if (hProcess == NULL) {
                result->Error("PROCESS_ERROR", "Failed to open process");
                return;
            }
            
            // Get process name
            char processName[MAX_PATH] = {0};
            DWORD processNameLength = GetModuleFileNameExA(hProcess, NULL, processName, sizeof(processName));
            
            // Get parent process ID
            DWORD parentProcessId = GetParentProcessId(processID);
            
            // Get parent process name
            char parentProcessName[MAX_PATH] = {0};
            HANDLE hParentProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, parentProcessId);
            if (hParentProcess != NULL) {
                GetModuleFileNameExA(hParentProcess, NULL, parentProcessName, sizeof(parentProcessName));
                CloseHandle(hParentProcess);
            }
            
            // Extract executable name from the full path
            std::string fullProcessPath = processNameLength > 0 ? std::string(processName) : "Unknown";
            std::string executableName = fullProcessPath;
            size_t lastSlash = fullProcessPath.find_last_of("\\/");
            if (lastSlash != std::string::npos) {
                executableName = fullProcessPath.substr(lastSlash + 1);
            }
            
            // Get program name from version info
            std::string programName = GetProgramName(fullProcessPath);
            
            // Close process handle
            CloseHandle(hProcess);
            
            // Prepare result
            flutter::EncodableMap resultMap = {
                {"windowTitle", std::string(windowTitle)},
                {"processName", fullProcessPath},
                {"executableName", executableName},
                {"programName", programName},
                {"processId", static_cast<int>(processID)},
                {"parentProcessId", static_cast<int>(parentProcessId)},
                {"parentProcessName", std::string(parentProcessName)}
            };
            
            result->Success(resultMap);
        } 
        else if (call.method_name() == "getAppLaunchInfo") {
            // Get current process ID
            DWORD processId = GetCurrentProcessId();
            
            // Get parent process details
            DWORD parentProcessId = GetParentProcessId(processId);
            char parentProcessName[MAX_PATH] = {0};
            HANDLE hParentProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, parentProcessId);
            if (hParentProcess != NULL) {
                GetModuleFileNameExA(hParentProcess, NULL, parentProcessName, sizeof(parentProcessName));
                CloseHandle(hParentProcess);
            }
            
            // Check auto-start registry
            bool isRegisteredAutoStart = IsRegisteredForAutoStart();
            
            // Check if started with system
            bool wasStartedWithSystem = WasStartedWithSystem();
            
            // Get command line args
            std::vector<std::string> args = GetCommandLineArgs();
            flutter::EncodableList argsList;
            for (const auto& arg : args) {
                argsList.push_back(arg);
            }
            
            // Make a launch type determination
            std::string launchType = "USER_LAUNCHED";
            
            // Check for common auto-start parent processes
            std::string parentName = std::string(parentProcessName);
            for (auto& c : parentName) {
                c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
            }
            
            bool hasAutoStartParent = 
                parentName.find("explorer.exe") == std::string::npos && // Not launched by explorer (user click)
                (parentName.find("svchost.exe") != std::string::npos ||
                 parentName.find("winlogon.exe") != std::string::npos ||
                 parentName.find("userinit.exe") != std::string::npos ||
                 parentName.find("taskeng.exe") != std::string::npos ||
                 parentName.find("startmenuexperiencehost.exe") != std::string::npos);
            
            if (wasStartedWithSystem || isRegisteredAutoStart || hasAutoStartParent) {
                launchType = "SYSTEM_LAUNCHED";
            }
            
            // Prepare result
            flutter::EncodableMap resultMap = {
                {"processId", static_cast<int>(processId)},
                {"parentProcessId", static_cast<int>(parentProcessId)},
                {"parentProcessName", std::string(parentProcessName)},
                {"isRegisteredAutoStart", isRegisteredAutoStart},
                {"wasStartedWithSystem", wasStartedWithSystem},
                {"commandLineArgs", argsList},
                {"launchType", launchType}
            };
            
            result->Success(resultMap);
        }
        else {
            result->NotImplemented();
        }
    }
};

void ForegroundWindowPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ForegroundWindowPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}