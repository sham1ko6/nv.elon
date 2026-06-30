import { c, serif } from '../theme';
import { Logo } from '../icons';
import { useNav, StatusBar } from '../shell';

export const OnboardingScreen = () => {
  const { navigate } = useNav();
  return (
    <>
      <StatusBar color="#fff" />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: c.accent, position: 'relative', overflow: 'hidden' }}>
        <div style={{ position: 'absolute', right: -50, top: -40, width: 200, height: 200, borderRadius: '50%', background: 'rgba(255,255,255,.08)' }} />
        <div style={{ position: 'absolute', left: -40, bottom: 180, width: 140, height: 140, borderRadius: '50%', background: 'rgba(255,255,255,.06)' }} />
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 28px', position: 'relative', zIndex: 5 }}>
          <Logo size={78} arch="#fff" inner={c.accent} dot={c.gold} />
          <div style={{ fontFamily: serif, fontSize: 42, fontWeight: 800, color: '#fff', letterSpacing: '-.02em', marginTop: 22 }}>Ravoq</div>
          <div style={{ fontFamily: serif, fontSize: 23, fontWeight: 600, color: '#fff', textAlign: 'center', lineHeight: 1.3, marginTop: 18 }}>O'zbekistonning<br />ishonchli bozori</div>
          <div style={{ fontSize: 13, color: 'rgba(255,255,255,.85)', textAlign: 'center', lineHeight: 1.55, marginTop: 14, maxWidth: 250 }}>Texnika, uy-joy, chorva va elektronika — xavfsiz savdo va yetkazib berish bilan.</div>
          <div style={{ display: 'flex', gap: 7, marginTop: 26 }}>
            <span style={{ width: 22, height: 6, borderRadius: 3, background: '#fff' }} />
            <span style={{ width: 6, height: 6, borderRadius: 3, background: 'rgba(255,255,255,.45)' }} />
            <span style={{ width: 6, height: 6, borderRadius: 3, background: 'rgba(255,255,255,.45)' }} />
          </div>
        </div>
        <div style={{ flexShrink: 0, padding: '0 24px 26px', position: 'relative', zIndex: 5 }}>
          <button onClick={() => navigate('login')} style={{ width: '100%', height: 54, border: 'none', borderRadius: 16, background: '#fff', color: c.accent, fontSize: 14.5, fontWeight: 800, cursor: 'pointer', boxShadow: '0 12px 24px rgba(0,0,0,.18)' }}>Telefon orqali boshlash</button>
          <button onClick={() => navigate('home')} style={{ width: '100%', height: 50, border: '1.5px solid rgba(255,255,255,.5)', borderRadius: 16, background: 'transparent', color: '#fff', fontSize: 13.5, fontWeight: 700, cursor: 'pointer', marginTop: 11 }}>Mehmon sifatida ko'rish</button>
        </div>
      </div>
    </>
  );
};
