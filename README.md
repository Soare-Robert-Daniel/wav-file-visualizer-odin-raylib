# Simple `.wav` file visualizer

Made with Odin and Raylib.

![The image is a screenshot of an audio waveform visualization. The waveform is centered on a horizontal axis and displayed in blue against a light gray background. The waveform represents the amplitude of the audio signal over time, with higher peaks indicating louder parts of the sound and lower sections indicating quieter parts. The title "Audio WaveForm Visualization" is displayed at the top left in a pixelated font. The window's title bar is visible, with the application titled "Audio Waveform Visualization."](screenshot.png)

## Usage

With Odin installed, run the following command to build the project:

```bash
$ odin run . -- <path_to_wav_file>
```

```bash
$ odin run . -- test.wav
```

#### Windows

Build the executable with the following command:

```bash
$ odin build . --out:wav-visualizer.exe
```

Run it with the following command:

```bash
$ ./wav-visualizer.exe <path_to_wav_file>
```

```bash
$ ./wav-visualizer.exe test.wav
```