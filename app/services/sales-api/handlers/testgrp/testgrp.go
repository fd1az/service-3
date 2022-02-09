// Package checkgrp maintains the group of handlers for health checking.
package testgrp

import (
	"context"
	"net/http"

	"github.com/fd1az/service-3/foundation/web"
	"go.uber.org/zap"
)

// Handlers manages the set of check endpoints.
type Handlers struct {
	Build string
	Log   *zap.SugaredLogger
}

func (h Handlers) Test(contex context.Context, w http.ResponseWriter, r *http.Request) error {
	status := struct {
		Status string
	}{
		Status: "ok",
	}

	statusCode := http.StatusOK
	h.Log.Infow("readiness", "statusCode", statusCode, "method", r.Method, "path", r.URL.Path, "remoteaddr", r.RemoteAddr)

	return web.Respond(contex, w, status, statusCode)
}
