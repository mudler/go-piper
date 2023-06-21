#ifdef __cplusplus
#include <vector>
#include <string>
extern "C" {
#endif

#include <stdbool.h>

int piper_tts(char *text, char *model, char *espeakData, char *tashkeelPath, char *dst);

#ifdef __cplusplus
}
#endif
