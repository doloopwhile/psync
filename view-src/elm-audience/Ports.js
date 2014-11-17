var audience = Elm.worker(Elm.Audience, {
  polling: 0,
});

audience.ports.polling.send(2);
