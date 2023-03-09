package config

type Config struct {
	// Enable partial recognition (closer to real-time)
	PartialRecognize bool
	// The number of seconds to wait for recognition results
	WaitResults int
	// Enable fake RPC (for testing purposes)
	FakeRPC bool
	// Vosk gRPC server address
	VoskRPC string
}

func NewConfig() *Config {
	return &Config{
		FakeRPC:     false,
		WaitResults: 2 * 60,
		VoskRPC:     "localhost:5001",
	}
}
