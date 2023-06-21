package piper

// #cgo CXXFLAGS: -I${SRCDIR}/piper/src/cpp/ -std=c++17
// #cgo LDFLAGS: -lpiper_binding -lspdlog -lonnxruntime -lespeak-ng -lpiper_phonemize
// #include <stdlib.h>
// int piper_tts(char *text, char *model, char *espeakData, char *tashkeelPath, char *dst);
import "C"
import (
	"fmt"
)

func TextToWav(text, model, espeek, tas, dst string) error {
	t := C.CString(text)
	m := C.CString(model)
	ee := C.CString(espeek)
	tt := C.CString(tas)
	d := C.CString(dst)

	ret := C.piper_tts(t, m, ee, tt, d)
	if ret != 0 {
		return fmt.Errorf("failed")
	}
	return nil
}
