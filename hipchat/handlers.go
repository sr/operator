package breadhipchat

import "git.dev.pardot.com/Pardot/bread"

func LogHandler(logger bread.Logger) MessageHandler {
	return func(payload *Item) error {
		logger.Printf("received message: %s", payload.Message.Message)
		return nil
	}
}
