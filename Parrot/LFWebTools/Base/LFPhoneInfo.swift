import AVKit
import Network
import MachO
import CoreMotion
import CommonCrypto

class LFPhoneInfo {
    static func configRiskInfo(_ encryptKey: String) async throws -> String {
        let info = await LFPhoneInfo.getPhoneInfo()
        let params = await [StringDecrypt.Decrypt(.ext_data): info,
                            StringDecrypt.Decrypt(.platform): "iOS",
                            StringDecrypt.Decrypt(.pkg): Bundle.main.bundleIdentifier ?? "",
                            StringDecrypt.Decrypt(.ver) : Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "",
                            StringDecrypt.Decrypt(.platform_ver): UIDevice.current.systemVersion,
                            StringDecrypt.Decrypt(.model) : LFPhoneInfo.getHardwareIdentifier() ?? "",
                            StringDecrypt.Decrypt(.user_id): LFWebData.shared.userId,
                            StringDecrypt.Decrypt(.device_id): LFWebData.shared.uuid,
                            StringDecrypt.Decrypt(.system_language) : Locale.current.identifier,
                            StringDecrypt.Decrypt(.time_zone): TimeZone.current.identifier
        ] as [String: Any]
        return LFPhoneInfo.enfk(parameters: params, key: encryptKey) ?? ""
    }
    static func getPhoneInfo() async -> [String: Any] {
        var dict = [String: Any]()
        
        dict[StringDecrypt.Decrypt(.device_volume)] = getDeviceVolume()
        
        let (status, level) = getBatteryStatus()
        dict[StringDecrypt.Decrypt(.battery_status)] = status.rawValue
        dict[StringDecrypt.Decrypt(.battery_level)] = level < 0 ? 0 : level
        
        dict[StringDecrypt.Decrypt(.screen_active)] = isScreenAvailable()
        
        dict[StringDecrypt.Decrypt(.microphone_available)] = isMicrophoneAvailable()
        
        dict[StringDecrypt.Decrypt(.speaker_available)] = isSpeakerAvailable()
        
        dict[StringDecrypt.Decrypt(.camera_available)] = isCameraAvailable()
        
        let (addressV4, addressV6) = getIPAddress()
        if let v4 = addressV4 {
            dict[StringDecrypt.Decrypt(.ipv4_address)] = v4
        }
        if let v6 = addressV6 {
            dict[StringDecrypt.Decrypt(.ipv6_address)] = v6
        }
        
        let cpuInfo = getCPUInfo()
        dict[StringDecrypt.Decrypt(.cpu_info)] = cpuInfo
        
        let (totalMemory, _, freeMemory) = getMemoryInfo()
        dict[StringDecrypt.Decrypt(.memory_total)] = totalMemory
        dict[StringDecrypt.Decrypt(.memory_available)] = freeMemory
        
        async let getNetworkStatus = getNetworkStatus()
        dict[StringDecrypt.Decrypt(.network_status)] = await getNetworkStatus.rawValue
        
        async let getDeviceMotionData = getDeviceMotionData()
        let (accelerometerMax, gyroMax, magnetometerMax, accelerometerStatus, gyroStatus, magnetometerStatus) = await getDeviceMotionData
        if let _accelerometerMax = accelerometerMax {
            dict[StringDecrypt.Decrypt(.accelerometer_max_amplitude)] = doubleToString(_accelerometerMax)
        }
        if let _gyroMax = gyroMax {
            dict[StringDecrypt.Decrypt(.gyroscope_max_amplitude)] = doubleToString(_gyroMax)
        }
        if let _magnetometerMax = magnetometerMax {
            dict[StringDecrypt.Decrypt(.magnetometer_max_amplitude)] = doubleToString(_magnetometerMax)
        }
        dict[StringDecrypt.Decrypt(.accelerometer_status)] = accelerometerStatus.rawValue
        dict[StringDecrypt.Decrypt(.gyroscope_status)] = gyroStatus.rawValue
        dict[StringDecrypt.Decrypt(.magnetometer_status)] = magnetometerStatus.rawValue
        
        dict[StringDecrypt.Decrypt(.timestamp)] = String(Int(Date().timeIntervalSince1970))
        
        return dict
    }
    static func enfk(parameters: [String: Any], key: String) -> String? {
        guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES192 || key.count == kCCKeySizeAES256 else {
            return nil
        }
        guard let InputData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            return nil
        }
        let blockSize = kCCBlockSizeAES128
        let padding = blockSize - (InputData.count % blockSize)
        var paddedInputData = InputData
        paddedInputData.append(contentsOf: Array(repeating: UInt8(padding), count: padding))
        
        let encryptedDataLength = paddedInputData.count
        var encryptedBytes = [UInt8](repeating: 0, count: encryptedDataLength)
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = paddedInputData.withUnsafeBytes { InputBytes in
            key.data(using: .utf8)!.withUnsafeBytes { KeyBytes in
                CCCrypt(
                    CCOperation(kCCEncrypt),
                    CCAlgorithm(kCCAlgorithmAES),
                    CCOptions(kCCOptionECBMode),
                    KeyBytes.baseAddress,
                    key.count,
                    nil,
                    InputBytes.baseAddress,
                    paddedInputData.count,
                    &encryptedBytes,
                    encryptedDataLength,
                    &numBytesEncrypted
                )
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            return nil
        }
        
        let encryptedData = Data(bytes: encryptedBytes, count: numBytesEncrypted)
        
        return encryptedData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

extension LFPhoneInfo {
    // 获取音量信息
    private static func getDeviceVolume() -> String {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // 设置音频会话类别
            try audioSession.setActive(true)
            
            // 获取当前音量
            return floatToString(audioSession.outputVolume)
        } catch {
            print("\(error)")
            return "-1"
        }
    }
    
    // 获取电量信息
    private static func getBatteryStatus() -> (status: PhoneInfoBatteryStatus, level: Float) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        
        // 0.0 到 1.0 的值
        let battery_level = device.batteryLevel
        let battery_state = device.batteryState
        
        var status: PhoneInfoBatteryStatus
        
        switch battery_state {
        case .unknown:
            status = .unknown
        case .unplugged:
            status = .unplugged
        case .charging:
            status = .charging
        case .full:
            status = .full
        @unknown default:
            status = .unknown
        }
        
        return (status, battery_level * 100)
    }
    
    // 判断屏幕是否可用
    private static func isScreenAvailable() -> String {
        (UIScreen.main.bounds.size.width > 0 && UIScreen.main.bounds.size.height > 0) ? "1" : "0"
    }
    
    // 判断摄像头是否可用
    private static func isCameraAvailable() -> String {
        (AVCaptureDevice.default(for: .video) != nil) ? "1" : "0"
    }
    
    // 判断麦克风是否可用
    private static func isMicrophoneAvailable() -> String {
        (AVCaptureDevice.default(for: .audio) != nil) ? "1" : "0"
    }
    
    // 判断扬声器是否可用
    private static func isSpeakerAvailable() -> String {
        var isAvailable = false
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            let route = audioSession.currentRoute
            for output in route.outputs {
                if output.portType == .builtInSpeaker {
                    isAvailable = true
                    break
                }
            }
        } catch {
            isAvailable = false
        }
        return isAvailable ? "1" : "0"
    }
    
    // 获取IP地址
    private static func getIPAddress() -> (String?, String?) {
        var addressV4Arr = [String]()
        var addressV6Arr = [String]()
        var ifaddrsPointer: UnsafeMutablePointer<ifaddrs>? = nil
        
        
        // 获取所有网络接口
        if getifaddrs(&ifaddrsPointer) == 0 {
            var pointer = ifaddrsPointer
            
            while pointer != nil {
                defer { pointer = pointer?.pointee.ifa_next }
                guard let interface = pointer?.pointee else { continue }
                
                // 检查接口类型
                let flags = Int32(interface.ifa_flags)
                let isUp = (flags & IFF_UP) != 0
                let isRunning = (flags & IFF_RUNNING) != 0
                
                if isUp && isRunning {
                    let addrFamily = interface.ifa_addr.pointee.sa_family
                    
                    // IPv4 地址
                    if addrFamily == AF_INET {
                        let v4 = withUnsafePointer(to: &interface.ifa_addr.pointee) {
                            $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                                inet_ntoa($0.pointee.sin_addr)
                            }
                        }.map { String(cString: $0) }
                        
                        if let _v4 = v4 {
                            addressV4Arr.append(_v4)
                        }
                    }
                    
                    // IPv6 地址
                    if addrFamily == AF_INET6 {
                        var addressBuffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
                        let result = inet_ntop(AF_INET6, &interface.ifa_addr.pointee, &addressBuffer, socklen_t(addressBuffer.count))
                        if result != nil {
                            let v6 = String(cString: addressBuffer)
                            addressV6Arr.append(v6)
                        }
                    }
                }
            }
            freeifaddrs(ifaddrsPointer)
        }
        return (addressV4Arr.joined(separator: ","), addressV6Arr.joined(separator: ","))
    }
    // 获取内存信息
    private static func getMemoryInfo() -> (String, String, String) {
        
        // 内存信息，总内存，单位为字节
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        
        // 计算可用内存
        var usedMemory: Double = 0.0
        if let report = memoryReport() {
            usedMemory = report.usedMemory
        }
        
        // 可用内存
        let freeMemory = Double(totalMemory) - usedMemory
        
        return (String(calcMegabytes(Double(totalMemory))), doubleToString(calcMegabytes(usedMemory)), doubleToString(calcMegabytes(freeMemory)))
        
        // 辅助函数，用于获取内存使用情况（此处简化处理）
        func memoryReport() -> (usedMemory: Double, freeMemory: Double)? {
            var stats = vm_statistics64()
            var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size) / 4
            
            let result = withUnsafeMutablePointer(to: &stats) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
                }
            }
            
            if result == KERN_SUCCESS {
                let pageSize = vm_page_size
                let usedMemory = Double(stats.active_count + stats.inactive_count + stats.wire_count) * Double(pageSize)
                let freeMemory = Double(stats.free_count) * Double(pageSize)
                
                return (usedMemory, freeMemory)
            }
            
            return nil
        }
        
        func calcMegabytes(_ value: Double) -> Double {
            return value / (1024 * 1024)
        }
    }
    
    // 获取设备硬件标识符
    static func getHardwareIdentifier() -> String? {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    // 获取 CPU 信息
    private static func getCPUInfo() -> String {
        guard let identifier = getHardwareIdentifier() else {
            return "Unknown Device"
        }
        
        // 设备型号和芯片名称的映射表
        let deviceMapping: [String: (model: String, chip: String)] = [
            // iPhone 设备
            "iPhone8,1": ("iPhone 6s", "A9"),
            "iPhone8,2": ("iPhone 6s Plus", "A9"),
            "iPhone9,1": ("iPhone 7", "A10 Fusion"),
            "iPhone9,2": ("iPhone 7 Plus", "A10 Fusion"),
            "iPhone10,1": ("iPhone 8", "A11 Bionic"),
            "iPhone10,2": ("iPhone 8 Plus", "A11 Bionic"),
            "iPhone10,3": ("iPhone X", "A11 Bionic"),
            "iPhone11,2": ("iPhone XS", "A12 Bionic"),
            "iPhone11,4": ("iPhone XS Max", "A12 Bionic"),
            "iPhone11,8": ("iPhone XR", "A12 Bionic"),
            "iPhone12,1": ("iPhone 11", "A13 Bionic"),
            "iPhone12,3": ("iPhone 11 Pro", "A13 Bionic"),
            "iPhone12,5": ("iPhone 11 Pro Max", "A13 Bionic"),
            "iPhone13,1": ("iPhone 12 mini", "A14 Bionic"),
            "iPhone13,2": ("iPhone 12", "A14 Bionic"),
            "iPhone13,3": ("iPhone 12 Pro", "A14 Bionic"),
            "iPhone13,4": ("iPhone 12 Pro Max", "A14 Bionic"),
            "iPhone14,4": ("iPhone 13 mini", "A15 Bionic"),
            "iPhone14,5": ("iPhone 13", "A15 Bionic"),
            "iPhone14,2": ("iPhone 13 Pro", "A15 Bionic"),
            "iPhone14,3": ("iPhone 13 Pro Max", "A15 Bionic"),
            "iPhone14,6": ("iPhone SE (3rd generation)", "A15 Bionic"),
            "iPhone15,2": ("iPhone 14 Pro", "A16 Bionic"),
            "iPhone15,3": ("iPhone 14 Pro Max", "A16 Bionic"),
            "iPhone14,7": ("iPhone 14", "A15 Bionic"),
            "iPhone14,8": ("iPhone 14 Plus", "A15 Bionic"),
            "iPhone16,1": ("iPhone 15", "A16 Bionic"),
            "iPhone16,2": ("iPhone 15 Plus", "A16 Bionic"),
            "iPhone16,3": ("iPhone 15 Pro", "A17 Pro"),
            "iPhone16,4": ("iPhone 15 Pro Max", "A17 Pro"),
            "iPhone17,1": ("iPhone 16", "A18"),
            "iPhone17,2": ("iPhone 16 Plus", "A18"),
            "iPhone17,3": ("iPhone 16 Pro", "A18 Pro"),
            "iPhone17,4": ("iPhone 16 Pro Max", "A18 Pro"),
            
            // iPad 设备
            "iPad6,11": ("iPad (5th generation)", "A9"),
            "iPad6,12": ("iPad (5th generation)", "A9"),
            "iPad7,5": ("iPad (6th generation)", "A10 Fusion"),
            "iPad7,6": ("iPad (6th generation)", "A10 Fusion"),
            "iPad7,11": ("iPad (7th generation)", "A10 Fusion"),
            "iPad7,12": ("iPad (7th generation)", "A10 Fusion"),
            "iPad11,6": ("iPad (8th generation)", "A12 Bionic"),
            "iPad11,7": ("iPad (8th generation)", "A12 Bionic"),
            "iPad12,1": ("iPad (9th generation)", "A13 Bionic"),
            "iPad12,2": ("iPad (9th generation)", "A13 Bionic"),
            "iPad13,18": ("iPad (10th generation)", "A14 Bionic"),
            "iPad13,19": ("iPad (10th generation)", "A14 Bionic"),
            
            // iPad Air 设备
            "iPad5,3": ("iPad Air 2", "A8X"),
            "iPad5,4": ("iPad Air 2", "A8X"),
            "iPad11,3": ("iPad Air (3rd generation)", "A12 Bionic"),
            "iPad11,4": ("iPad Air (3rd generation)", "A12 Bionic"),
            "iPad13,1": ("iPad Air (4th generation)", "A14 Bionic"),
            "iPad13,2": ("iPad Air (4th generation)", "A14 Bionic"),
            "iPad13,16": ("iPad Air (5th generation)", "M1"),
            "iPad13,17": ("iPad Air (5th generation)", "M1"),
            
            // iPad Pro 设备
            "iPad6,3": ("iPad Pro (9.7-inch)", "A9X"),
            "iPad6,4": ("iPad Pro (9.7-inch)", "A9X"),
            "iPad6,7": ("iPad Pro (12.9-inch) (1st generation)", "A9X"),
            "iPad6,8": ("iPad Pro (12.9-inch) (1st generation)", "A9X"),
            "iPad7,1": ("iPad Pro (12.9-inch) (2nd generation)", "A10X Fusion"),
            "iPad7,2": ("iPad Pro (12.9-inch) (2nd generation)", "A10X Fusion"),
            "iPad7,3": ("iPad Pro (10.5-inch)", "A10X Fusion"),
            "iPad7,4": ("iPad Pro (10.5-inch)", "A10X Fusion"),
            "iPad8,1": ("iPad Pro (11-inch) (1st generation)", "A12X Bionic"),
            "iPad8,2": ("iPad Pro (11-inch) (1st generation)", "A12X Bionic"),
            "iPad8,3": ("iPad Pro (11-inch) (1st generation)", "A12X Bionic"),
            "iPad8,4": ("iPad Pro (11-inch) (1st generation)", "A12X Bionic"),
            "iPad8,5": ("iPad Pro (12.9-inch) (3rd generation)", "A12X Bionic"),
            "iPad8,6": ("iPad Pro (12.9-inch) (3rd generation)", "A12X Bionic"),
            "iPad8,7": ("iPad Pro (12.9-inch) (3rd generation)", "A12X Bionic"),
            "iPad8,8": ("iPad Pro (12.9-inch) (3rd generation)", "A12X Bionic"),
            "iPad8,9": ("iPad Pro (11-inch) (2nd generation)", "A12Z Bionic"),
            "iPad8,10": ("iPad Pro (11-inch) (2nd generation)", "A12Z Bionic"),
            "iPad8,11": ("iPad Pro (12.9-inch) (4th generation)", "A12Z Bionic"),
            "iPad8,12": ("iPad Pro (12.9-inch) (4th generation)", "A12Z Bionic"),
            "iPad13,4": ("iPad Pro (11-inch) (3rd generation)", "M1"),
            "iPad13,5": ("iPad Pro (11-inch) (3rd generation)", "M1"),
            "iPad13,6": ("iPad Pro (11-inch) (3rd generation)", "M1"),
            "iPad13,7": ("iPad Pro (11-inch) (3rd generation)", "M1"),
            "iPad13,8": ("iPad Pro (12.9-inch) (5th generation)", "M1"),
            "iPad13,9": ("iPad Pro (12.9-inch) (5th generation)", "M1"),
            "iPad13,10": ("iPad Pro (12.9-inch) (5th generation)", "M1"),
            "iPad13,11": ("iPad Pro (12.9-inch) (5th generation)", "M1"),
            "iPad14,3": ("iPad Pro (11-inch) (4th generation)", "M2"),
            "iPad14,4": ("iPad Pro (11-inch) (4th generation)", "M2"),
            "iPad14,5": ("iPad Pro (12.9-inch) (6th generation)", "M2"),
            "iPad14,6": ("iPad Pro (12.9-inch) (6th generation)", "M2"),
            
            // 模拟器
            "arm64": ("Simulator", "Simulator")
        ]
        
        if let device = deviceMapping[identifier] {
            return "\(device.model),\(device.chip),\(getCPUArchitecture())"
        } else {
            return "Unknown Device"
        }
        
        func getCPUInstructionSet() -> String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machine = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
                return String(cString: ptr)
            }
            return machine
        }
        
        // 获取 CPU 指令集信息
        func getCPUArchitecture() -> String {
            if let archInfo = NXGetLocalArchInfo() {
                return String(cString: archInfo.pointee.name)
            }
            return "Unknown"
        }
    }
    
    // 获取网络信息
    private static func getNetworkStatus() async -> PhoneInfoNetworkStatus {
        return await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetworkMonitor")
            
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    if path.usesInterfaceType(.wifi) {
                        continuation.resume(returning: .wifi)
                    } else if path.usesInterfaceType(.cellular) {
                        continuation.resume(returning: .cellular)
                    } else {
                        continuation.resume(returning: .other)
                    }
                } else {
                    continuation.resume(returning: .noConnection)
                }
                
                monitor.cancel() // 取消监控
            }
            
            monitor.start(queue: queue)
        }
    }
    
    // 获取运动信息，加速度、陀螺仪、磁强计
    private static func getDeviceMotionData() async -> (Double?, Double?, Double?, PhoneInfoMotionStatus, PhoneInfoMotionStatus, PhoneInfoMotionStatus) {
        let motion_manager = CMMotionManager()
        let motion_data = MotionData()
        
        let accelerometer_available = motion_manager.isAccelerometerAvailable
        let gyro_available = motion_manager.isGyroAvailable
        let magnetometer_available = motion_manager.isMagnetometerAvailable
        
        // 开始获取数据
        if accelerometer_available {
            motion_manager.startAccelerometerUpdates()
        }
        if gyro_available {
            motion_manager.startGyroUpdates()
        }
        if magnetometer_available {
            motion_manager.startMagnetometerUpdates()
        }
        
        let startTime = Date()
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                while Date().timeIntervalSince(startTime) < 3 {
                    if accelerometer_available, let accelerometer_data = motion_manager.accelerometerData {
                        let magnitude = sqrt(pow(accelerometer_data.acceleration.x, 2) +
                                             pow(accelerometer_data.acceleration.y, 2) +
                                             pow(accelerometer_data.acceleration.z, 2))
                        Task {
                            await motion_data.updateAccelerometerMax(magnitude)
                        }
                    }
                    
                    if gyro_available, let gyro_data = motion_manager.gyroData {
                        let magnitude = sqrt(pow(gyro_data.rotationRate.x, 2) +
                                             pow(gyro_data.rotationRate.y, 2) +
                                             pow(gyro_data.rotationRate.z, 2))
                        Task {
                            await motion_data.updateGyroMax(magnitude)
                        }
                    }
                    
                    if magnetometer_available, let magnetometer_data = motion_manager.magnetometerData {
                        let magnitude = sqrt(pow(magnetometer_data.magneticField.x, 2) +
                                             pow(magnetometer_data.magneticField.y, 2) +
                                             pow(magnetometer_data.magneticField.z, 2))
                        Task {
                            await motion_data.updateMagnetometerMax(magnitude)
                        }
                    }
                    
                    // 降低 CPU 使用率
                    Thread.sleep(forTimeInterval: 0.1)
                }
                
                // 停止更新
                motion_manager.stopAccelerometerUpdates()
                motion_manager.stopGyroUpdates()
                motion_manager.stopMagnetometerUpdates()
                
                Task {
                    let accelerometerMax = await motion_data.accelerometerMax
                    let gyroMax = await motion_data.gyroMax
                    let magnetometerMax = await motion_data.magnetometerMax
                    
                    let accelerometerStatus: PhoneInfoMotionStatus = accelerometer_available ? .active : .inactive
                    let gyroStatus: PhoneInfoMotionStatus = gyro_available ? .active : .inactive
                    let magnetometerStatus: PhoneInfoMotionStatus = magnetometer_available ? .active : .inactive
                    
                    continuation.resume(returning: (accelerometerMax, gyroMax, magnetometerMax, accelerometerStatus, gyroStatus, magnetometerStatus))
                }
            }
        }
    }
}

extension LFPhoneInfo {
    private enum PhoneInfoBatteryStatus: String {
        /// 未知
        case unknown    = "0"
        /// 未插电
        case unplugged  = "1"
        /// 充电中
        case charging   = "2"
        /// 已充满
        case full       = "3"
    }
    
    private enum PhoneInfoNetworkStatus: String {
        case noConnection   = "0"
        case wifi           = "1"
        case cellular       = "2"
        case other          = "3"
    }
    
    private enum PhoneInfoMotionStatus: String {
        case inactive      = "0"
        case active        = "1"
    }
    
    actor MotionData {
        var accelerometerMax: Double? = nil
        var gyroMax: Double? = nil
        var magnetometerMax: Double? = nil
        
        func updateAccelerometerMax(_ value: Double) {
            accelerometerMax = max(accelerometerMax ?? 0, value)
        }
        
        func updateGyroMax(_ value: Double) {
            gyroMax = max(gyroMax ?? 0, value)
        }
        
        func updateMagnetometerMax(_ value: Double) {
            magnetometerMax = max(magnetometerMax ?? 0, value)
        }
    }
    
    
    private static func doubleToString(_ value: Double) -> String {
        return "\(value)"
    }
    
    private static func floatToString(_ value: Float) -> String {
        return "\(value)"
    }
}

