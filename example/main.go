package main

import (
	"fmt"

	"github.com/mudler/go-piper"
)

func main() {

	fmt.Println(piper.TextToWav("Ciao a tutti, mi chiamo riccardo", "it-riccardo_fasol-x-low.onnx", "/build/lib/Linux-x86_64/piper_phonemize/lib/espeak-ng-data/", "", "ciao.wav"))
}
