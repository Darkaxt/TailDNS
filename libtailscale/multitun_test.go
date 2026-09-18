// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

package libtailscale

import (
	"errors"
	"os"
	"sync"
	"testing"

	"github.com/tailscale/wireguard-go/tun"
)

func TestMultiTUNRetriesWriteOnReplacementDevice(t *testing.T) {
	old := newReplacementTestTUN(true)
	next := newReplacementTestTUN(false)
	d := newTUNDevices()
	d.add(old)
	d.Up()

	writeDone := make(chan error, 1)
	go func() {
		_, err := d.Write([][]byte{{1, 2, 3}}, 0)
		writeDone <- err
	}()

	<-old.writeStarted
	close(old.invalidated)
	d.add(next)

	if err := <-writeDone; err != nil {
		t.Fatalf("Write during device replacement: %v", err)
	}
	if got := old.writeCount(); got != 1 {
		t.Fatalf("old device write count = %d, want 1", got)
	}
	if got := next.writeCount(); got != 1 {
		t.Fatalf("replacement device write count = %d, want 1", got)
	}
}

type replacementTestTUN struct {
	invalidated  chan struct{}
	writeStarted chan struct{}
	closed       chan struct{}
	events       chan tun.Event
	closeOnce    sync.Once
	writeOnce    sync.Once
	mu           sync.Mutex
	writes       int
	blockWrite   bool
}

func newReplacementTestTUN(blockWrite bool) *replacementTestTUN {
	return &replacementTestTUN{
		invalidated:  make(chan struct{}),
		writeStarted: make(chan struct{}),
		closed:       make(chan struct{}),
		events:       make(chan tun.Event),
		blockWrite:   blockWrite,
	}
}

func (d *replacementTestTUN) File() *os.File { return nil }

func (d *replacementTestTUN) Close() error {
	d.closeOnce.Do(func() { close(d.closed) })
	return nil
}

func (d *replacementTestTUN) Read([]byte, []tun.ReadPacket) (int, error) {
	<-d.closed
	return 0, os.ErrClosed
}

func (d *replacementTestTUN) Write(_ [][]byte, _ int) (int, error) {
	d.mu.Lock()
	d.writes++
	d.mu.Unlock()
	d.writeOnce.Do(func() { close(d.writeStarted) })

	if d.blockWrite {
		<-d.invalidated
		return 0, errors.New("input/output error")
	}
	return 1, nil
}

func (d *replacementTestTUN) Flush() error             { return nil }
func (d *replacementTestTUN) MTU() (int, error)        { return 1280, nil }
func (d *replacementTestTUN) Name() (string, error)    { return "test", nil }
func (d *replacementTestTUN) Events() <-chan tun.Event { return d.events }
func (d *replacementTestTUN) BatchSize() int           { return 1 }

func (d *replacementTestTUN) writeCount() int {
	d.mu.Lock()
	defer d.mu.Unlock()
	return d.writes
}
