package piper

// #cgo CXXFLAGS: -I${SRCDIR}/piper/src/cpp/ -I${SRCDIR}/piper-phonemize/pi/include -std=c++17
// #cgo LDFLAGS: -L${SRCDIR}/espeak/ei/lib/ -L${SRCDIR}/piper-phonemize/pi/lib/ -lpiper_binding -lspdlog -lonnxruntime -lespeak-ng -lpiper_phonemize -lucd
// #include <stdlib.h>
// #include <gopiper.h>
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

func TextToWavSpeaker(text, model, espeek, tas, dst string, speakerId int64) error {
	t := C.CString(text)
	m := C.CString(model)
	ee := C.CString(espeek)
	tt := C.CString(tas)
	d := C.CString(dst)
	sid := C.int64_t(speakerId)

	ret := C.piper_tts_speaker(t, m, ee, tt, d, sid)
	if ret != 0 {
		return fmt.Errorf("failed")
	}
	return nil
}
