#ifdef __cplusplus
extern "C" {
#endif
int piper_tts(char *text, char *model, char *espeakData, char *tashkeelPath, char *dst);
int piper_tts_speaker(char *text, char *model, char *espeakData, char *tashkeelPath, char *dst, int64_t speakerId);
#ifdef __cplusplus
}
#endif
