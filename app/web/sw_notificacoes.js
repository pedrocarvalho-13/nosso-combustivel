self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (evento) => {
  evento.waitUntil((async () => {
    const nomes = await caches.keys();
    await Promise.all(nomes.filter((nome) => nome.startsWith('flutter')).map((nome) => caches.delete(nome)));
    await self.clients.claim();
  })());
});

self.addEventListener('push', (evento) => {
  let dados = {};
  try {
    dados = evento.data ? evento.data.json() : {};
  } catch (_) {
    dados = { corpo: evento.data ? evento.data.text() : '' };
  }
  evento.waitUntil(self.registration.showNotification(dados.titulo || 'Pit Garage', {
    body: dados.corpo || '',
    icon: 'icons/Icon-192.png',
    tag: dados.tag,
    data: { rota: dados.rota || '/inicio' },
  }));
});

self.addEventListener('notificationclick', (evento) => {
  evento.notification.close();
  const rota = (evento.notification.data && evento.notification.data.rota) || '/inicio';
  const destino = new URL(`#${rota}`, self.registration.scope).href;
  evento.waitUntil((async () => {
    const janelas = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const janela of janelas) {
      if ('focus' in janela) {
        await janela.focus();
        if ('navigate' in janela) {
          try {
            await janela.navigate(destino);
          } catch (_) {}
        }
        return;
      }
    }
    await self.clients.openWindow(destino);
  })());
});
