package config

type Config struct {
	// Enable partial recognition (closer to real-time)
	PartialRecognize bool
	// The number of seconds to wait for recognition results
	WaitResults int
	// Enable fake RPC (for testing purposes)
	FakeRPC bool
}

func NewConfig() *Config {
	return &Config{
		FakeRPC:     false,
		WaitResults: 2 * 60,
	}
}
