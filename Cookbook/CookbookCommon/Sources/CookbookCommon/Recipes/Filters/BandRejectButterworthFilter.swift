import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class BandRejectButterworthFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: BandRejectButterworthFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = BandRejectButterworthFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct BandRejectButterworthFilterView: View {
    @StateObject var conductor = BandRejectButterworthFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.filter.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.filter,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Band Reject Butterworth Filter")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct BandRejectButterworthFilter_Previews: PreviewProvider {
    static var previews: some View {
        BandRejectButterworthFilterView()
    }
}