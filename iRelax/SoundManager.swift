import Foundation
import AVFoundation
import AppKit

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    // 预加载声音
    func preloadSounds() {
        loadSound(name: "start_rest", type: "mp3")
        loadSound(name: "end_rest", type: "mp3")
    }
    
    // 加载声音文件
    private func loadSound(name: String, type: String) {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                player.prepareToPlay()
                audioPlayers[name] = player
            } catch {
                print("无法加载声音文件: \(name).\(type), 错误: \(error)")
            }
        } else {
            // 如果文件不存在，使用系统声音
            print("声音文件不存在: \(name).\(type)")
        }
    }
    
    // 播放声音
    func playSound(name: String) {
        // 如果预加载声音存在，则播放
        if let player = audioPlayers[name] {
            player.currentTime = 0
            player.play()
        } else {
            // 否则播放系统声音
            NSSound.beep()
        }
    }
    
    // 播放开始休息声音
    func playStartRestSound() {
        if let sound = UserDefaults.standard.string(forKey: "workSoundOption") {
            switch sound {
            case "放松":
                playSound(name: "start_rest")
            case "叮咚":
                NSSound.beep()
            case "铃声":
                NSSound.beep()
            default:
                NSSound.beep()
            }
        } else {
            playSound(name: "start_rest")
        }
    }
    
    // 播放结束休息声音
    func playEndRestSound() {
        if let sound = UserDefaults.standard.string(forKey: "restSoundOption") {
            switch sound {
            case "清脆":
                playSound(name: "end_rest")
            case "滴答":
                NSSound.beep()
            case "静音":
                break // 不播放声音
            default:
                NSSound.beep()
            }
        } else {
            playSound(name: "end_rest")
        }
    }
} 