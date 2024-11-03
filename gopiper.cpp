#include <chrono>
#include <condition_variable>
#include <filesystem>
#include <fstream>
#include <functional>
#include <iostream>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>
#include <gopiper.h>
#include <spdlog/spdlog.h>
#ifdef _MSC_VER
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#endif

#ifdef __APPLE__
#include <mach-o/dyld.h>
#endif

#include "piper.hpp"

using namespace std;

int _piper_tts(char *text, char *model, char *espeakData, char *tashkeelPath, char *dst, optional<piper::SpeakerId> speakerId) {
  filesystem::path model_path;
  filesystem::path config_path;
  model_path = filesystem::path(std::string(model));
  config_path = filesystem::path(std::string(model) + ".json");

  piper::PiperConfig piperConfig;
  piper::Voice voice;

  loadVoice(piperConfig, model_path.string(),
            config_path.string(), voice, speakerId);

 if (voice.phonemizeConfig.phonemeType == piper::eSpeakPhonemes) {
    spdlog::debug("Voice uses eSpeak phonemes ({})",
                  voice.phonemizeConfig.eSpeak.voice);
      piperConfig.eSpeakDataPath = espeakData;
  } else {
    // Not using eSpeak
    piperConfig.useESpeak = false;
  }

  // Enable libtashkeel for Arabic
  if (voice.phonemizeConfig.eSpeak.voice == "ar") {
    piperConfig.useTashkeel = true;
    piperConfig.tashkeelModelPath =tashkeelPath;
  }

  piper::initialize(piperConfig);

  // Scales
  // if (runConfig.noiseScale) {
  //   voice.synthesisConfig.noiseScale = runConfig.noiseScale.value();
  // }

  // if (runConfig.lengthScale) {
  //   voice.synthesisConfig.lengthScale = runConfig.lengthScale.value();
  // }

  // if (runConfig.noiseW) {
  //   voice.synthesisConfig.noiseW = runConfig.noiseW.value();
  // }

  // if (runConfig.sentenceSilenceSeconds) {
  //   voice.synthesisConfig.sentenceSilenceSeconds =
  //       runConfig.sentenceSilenceSeconds.value();
  // }

  piper::SynthesisResult result;
  ofstream audioFile(dst, ios::binary);
  piper::textToWavFile(piperConfig, voice, text, audioFile, result);
  piper::terminate(piperConfig);

  return EXIT_SUCCESS;
}

int piper_tts(char *text, char *model, char *espeakData, char *tashkeelPath, char *dst) {
  optional<piper::SpeakerId> speakerId;
  return _piper_tts(text, model, espeakData, tashkeelPath, dst, speakerId);
}

int piper_tts_speaker(char *text, char *model, char *espeakData, char *tashkeelPath, char *dst, int64_t speakerId) {
  return _piper_tts(text, model, espeakData, tashkeelPath, dst, speakerId);
}
