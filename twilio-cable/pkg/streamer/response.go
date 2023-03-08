package streamer

type Response struct {
	Status    string `json:"status"`         // status of the response. Could be success or error
	Track     string `json:"track"`          // inbound and outbound track of call
	AudioSize int    `json:"audio_size"`     // bytes size of audio content
	Message   string `json:"system_message"` // system_message we need to report to Rails Application
}

func NewResponse(msg *Packet) *Response {
	return &Response{
		Status:    "Success",
		Track:     msg.Track,
		AudioSize: len(msg.Audio),
	}
}

func (r *Response) IsError() bool {
	return r.Status == "error"
}
