package streamer

type Response struct {
	ID string `json:"id"`
	// Recognition result or error message
	Message string `json:"text"`
	// True if recognition is final
	Final bool `json:"final"`
	// Event type (recognition, start, end)
	Event string `json:"event"`
}
