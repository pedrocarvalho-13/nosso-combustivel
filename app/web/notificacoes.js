(() => {
  const suportado = () => 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window;
  const ios = () => /iPhone|iPad|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
  const instalado = () => window.matchMedia('(display-mode: standalone)').matches || navigator.standalone === true;
  const registrar = () => navigator.serviceWorker.register('sw_notificacoes.js');

  const chaveEmBytes = (texto) => {
    const base64 = (texto + '='.repeat((4 - (texto.length % 4)) % 4)).replace(/-/g, '+').replace(/_/g, '/');
    return Uint8Array.from(atob(base64), (letra) => letra.charCodeAt(0));
  };

  const inscricaoAtual = async () => {
    const registro = await navigator.serviceWorker.getRegistration();
    return registro ? registro.pushManager.getSubscription() : null;
  };

  window.pitNotificacoes = {
    estado: async () => {
      if (!suportado()) return ios() && !instalado() ? 'instalar' : 'semSuporte';
      if (Notification.permission === 'denied') return 'bloqueado';
      return (await inscricaoAtual()) ? 'ativo' : 'desativado';
    },

    ativar: async (chave) => {
      const permissao = await Notification.requestPermission();
      if (permissao !== 'granted') return JSON.stringify({ erro: permissao === 'denied' ? 'bloqueado' : 'recusado' });
      await registrar();
      const registro = await navigator.serviceWorker.ready;
      let inscricao = await registro.pushManager.getSubscription();
      if (!inscricao) {
        inscricao = await registro.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: chaveEmBytes(chave) });
      }
      return JSON.stringify(inscricao.toJSON());
    },

    desativar: async () => {
      const inscricao = await inscricaoAtual();
      if (!inscricao) return '';
      const endpoint = inscricao.endpoint;
      await inscricao.unsubscribe();
      return endpoint;
    },

    aparelho: () => {
      const agente = navigator.userAgent;
      const sistema = ios() ? 'iPhone' : /Android/.test(agente) ? 'Android' : /Windows/.test(agente) ? 'Windows' : /Mac/.test(agente) ? 'Mac' : 'Computador';
      const navegador = /Edg\//.test(agente) ? 'Edge' : /SamsungBrowser/.test(agente) ? 'Samsung Internet' : /Firefox/.test(agente) ? 'Firefox'
        : /Chrome/.test(agente) ? 'Chrome' : /Safari/.test(agente) ? 'Safari' : 'navegador';
      return `${navegador} no ${sistema}`;
    },
  };

  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      registrar().catch(() => {});
    });
  }
})();
