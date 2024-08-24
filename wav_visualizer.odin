package wav_visualizer

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"
import rl "vendor:raylib"

FPS :: 60
WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
WAVE_HEIGHT_PADDING :: 100

AudioSampleDepth :: union {
	u8,
	i16,
	f32,
}

main :: proc() {

	if len(os.args) < 2 {
		fmt.println("Usage: program <path_to_audio_file>")
		os.exit(1)
	}

	audioFilePath := os.args[1]

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	sample_slice, total_samples := load_sample(strings.clone_to_cstring(audioFilePath))

	rl.SetTargetFPS(FPS)

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Audio Waveform Visualization")
	defer rl.CloseWindow()

	wave_heights, wave_num := compute_wave_height(
		sample_slice,
		total_samples,
		cast(int)rl.GetScreenWidth(),
		cast(int)rl.GetScreenHeight(),
	)

	delete(sample_slice)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		draw_waveform(wave_heights, wave_num)

		rl.DrawText("Audio Waveform Visualization", 10, 10, 20, rl.DARKGRAY)
	}

}

load_sample :: proc(filePath: cstring) -> ([]AudioSampleDepth, u32) {
	audioWave := rl.LoadWave(filePath)
	defer rl.UnloadWave(audioWave)

	totalSamples := audioWave.frameCount * audioWave.channels
	fmt.printfln(
		"[INFO][Audio] Channels: %d | Frame Count: %d | Total samples: %d",
		audioWave.channels,
		audioWave.frameCount,
		totalSamples,
	)

	sampleSlice: []AudioSampleDepth

	// Create a slice based on the sample size
	switch audioWave.sampleSize {
	case 8:
		slice8 := mem.slice_ptr(cast(^u8)audioWave.data, cast(int)totalSamples)
		sampleSlice = make([]AudioSampleDepth, totalSamples)
		for i in 0 ..< totalSamples {
			sampleSlice[i] = slice8[i]
		}
	case 16:
		slice16 := mem.slice_ptr(cast(^i16)audioWave.data, cast(int)totalSamples)
		sampleSlice = make([]AudioSampleDepth, totalSamples)
		for i in 0 ..< totalSamples {
			sampleSlice[i] = slice16[i]
		}
	case 32:
		slice32 := mem.slice_ptr(cast(^f32)audioWave.data, cast(int)totalSamples)
		sampleSlice = make([]AudioSampleDepth, totalSamples)
		for i in 0 ..< totalSamples {
			sampleSlice[i] = slice32[i]
		}
	case:
		fmt.println("Unsupported sample size:", audioWave.sampleSize)
	}

	if len(sampleSlice) > 0 {
		fmt.println("First sample:", sampleSlice[0])
	}

	return sampleSlice, totalSamples
}

compute_wave_height :: proc(
	samples: []AudioSampleDepth,
	sampleSize: u32,
	window_width: int,
	window_height: int,
) -> (
	[]i32,
	int,
) {
	wave_heights := make([]i32, window_width)

	waveform_height := window_height - WAVE_HEIGHT_PADDING
	waveform_y := (window_height - waveform_height) / 2

	sample_count := len(samples)
	samples_per_pixel := max(1, sample_count / window_width)

	for x := 0; x < window_width; x += 1 {
		start_sample := x * samples_per_pixel
		end_sample := min((x + 1) * samples_per_pixel, sample_count)

		// Only the max normalized amplitude will be used in rendering.
		max_amplitude: f32 = 0
		for i := start_sample; i < end_sample; i += 1 {

			amplitude: f32
			switch v in samples[i] {
			case u8:
				amplitude = f32(v) / 255.0 * 2 - 1
			case i16:
				amplitude = f32(v) / 32768.0
			case f32:
				amplitude = v
			}

			max_amplitude = max(max_amplitude, abs(amplitude))
		}

		wave_heights[x] = cast(i32)(max_amplitude * f32(waveform_height) / 2)
	}

	return wave_heights, window_width
}

draw_waveform :: proc(wave_heights: []i32, wave_num: int) {
	windowWidth := rl.GetScreenWidth()
	windowHeight := rl.GetScreenHeight()
	waveformHeight := windowHeight - 100
	waveformY := (windowHeight - waveformHeight) / 2

	for x: i32 = 0; x < windowWidth; x += 1 {
		rl.DrawLine(
			x,
			(waveformY + waveformHeight / 2 - wave_heights[x]),
			x,
			(waveformY + waveformHeight / 2 + wave_heights[x]),
			rl.BLUE,
		)
	}
}
