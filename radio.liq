#!~/.opam/4.13.1/bin/liquidsoap
#
# Basic radio.liq file on which too build

settings.init.allow_root.set(true)

# Clock Settings
#

settings.root.max_latency.set(5.)
settings.clock.allow_streaming_errors.set(false)

# Telnet Settings
#

settings.server.telnet.bind_addr.set("0.0.0.0")
settings.server.telnet.port.set(4321)
settings.server.telnet.set(true)

default = single("~/Music/jingles/dragon_fire_snort.wav.mp3")

day     = playlist("~/Music/day")
night   = playlist("~/Music/night")
jingles = playlist("~/Music/jingles")
clock   = single("~/Music/jingles/dannys_monk_bong_ambi.wav.mp3")

radio = fallback([ request.queue(id="request"),
		switch([({ 6h-24h }, day),
                      ({ 24h-6h }, night)]),
                    default])

# Add the normal jingles

radio = random(weights=[1,10],[ jingles, radio ])

# And the clock jingle

radio = add([radio, switch([({0m0s},clock)])])

# Implement cross fade
# radio = crossfade(fade_out=3., fade_in=3., duration=5., radio)

# Harbor Config
# -------------

settings.harbor.bind_addrs.set(["0.0.0.0"])
settings.harbor.max_connections.set(5)
settings.harbor.timeout.set(10.)
settings.harbor.verbose.set(false)
pass = "*******"

# Harbor Input
#-------------

live = input.harbor("stone", port=8001, password=pass)

# Live Stream
# -----------------

full = fallback(track_sensitive=false, [live,radio])

# Stream it.
output.icecast(%mp3.cbr(bitrate=320, samplerate=48000),
  host = "192.168.1.200", port = 8000,
  password = "******", mount = "*********",
  name = "Gargoyle -  1287 kHz AM - 320k MP3",
  genre = "Eclectic",
  timeout = 10.0,
  url = "http://gargoyle.co.za",
  description = "Set in stone",
  full)
