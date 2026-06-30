import { useState } from 'react';
import { c, serif } from '../theme';
import { Logo } from '../icons';
import { useNav, StatusBar } from '../shell';
import { api, setAuthToken } from '../api';

type Step = 'phone' | 'otp';

const DEL_ICON = (
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
    strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M21 5H8l-5 7 5 7h13a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1z" />
    <path d="M16 9l-5 6M11 9l5 6" />
  </svg>
);

export const LoginScreen = () => {
  const { navigate } = useNav();
  const [step, setStep] = useState<Step>('phone');
  const [phone, setPhone] = useState('');  // 9 digits after +998
  const [code, setCode] = useState('');    // 6 digits
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fullPhone = `+998${phone}`;

  const tapPhone = (d: string) => {
    setError(null);
    if (d === 'del') { setPhone(p => p.slice(0, -1)); return; }
    setPhone(p => (p + d).slice(0, 9));
  };

  const tapOtp = (d: string) => {
    setError(null);
    if (d === 'del') { setCode(v => v.slice(0, -1)); return; }
    setCode(v => (v + d).slice(0, 6));
  };

  const handleRequestOtp = async () => {
    if (phone.length !== 9 || loading) return;
    setLoading(true);
    setError(null);
    try {
      await api.requestOtp(fullPhone);
      setStep('otp');
      setCode('');
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async () => {
    if (code.length !== 6 || loading) return;
    setLoading(true);
    setError(null);
    try {
      const data = await api.verifyOtp(fullPhone, code);
      setAuthToken(data.accessToken);
      navigate('lang');
    } catch (e: any) {
      setError(e.message);
      setCode('');
    } finally {
      setLoading(false);
    }
  };

  const isPhone = step === 'phone';

  // Format phone display: XX XXX XX XX
  const phoneFmt = phone.padEnd(9, ' ')
    .replace(/^(.{2})(.{3})(.{2})(.{2})$/, '$1 $2 $3 $4').trimEnd();

  const phoneDigits = [0, 1, 2, 3, 4, 5, 6, 7, 8].map(i => phone[i] || '');
  const codeDigits  = [0, 1, 2, 3, 4, 5].map(i => code[i] || '');
  const filled = isPhone ? phone.length : code.length;
  const total  = isPhone ? 9 : 6;

  const confirm = isPhone ? handleRequestOtp : handleVerifyOtp;
  const canConfirm = filled === total && !loading;

  return (
    <>
      <StatusBar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '32px 24px 24px' }}>

        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
          <Logo size={56} arch={c.accent} inner={c.bg} dot={c.gold} />
          <div style={{ fontFamily: serif, fontSize: 30, fontWeight: 800, color: c.ink,
            letterSpacing: '-.01em', marginTop: 16 }}>
            Ravoq<span style={{ color: c.accent }}>.</span>
          </div>

          {isPhone ? (
            <div style={{ fontSize: 12.5, color: c.muted, marginTop: 7, lineHeight: 1.5, maxWidth: 240 }}>
              Telefon raqamingizni kiriting.<br />Kodni SMS orqali yuboramiz.
            </div>
          ) : (
            <div style={{ fontSize: 12.5, color: c.muted, marginTop: 7, lineHeight: 1.5, maxWidth: 240 }}>
              Tasdiqlash kodi{' '}
              <b style={{ color: c.ink }}>{fullPhone}</b> raqamiga yuborildi
            </div>
          )}
        </div>

        {/* digit boxes */}
        {isPhone ? (
          /* phone: show prefix + 9 boxes */
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center',
            gap: 4, marginTop: 34 }}>
            <span style={{ fontFamily: serif, fontSize: 20, fontWeight: 700, color: c.muted,
              marginRight: 4 }}>+998</span>
            {phoneDigits.map((d, i) => {
              const active = i === phone.length;
              return (
                <div key={i} style={{
                  width: 26, height: 44, borderRadius: 10, background: c.card,
                  border: `${d || active ? 2 : 1.5}px solid ${d || active ? c.accent : c.line}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: serif, fontSize: 20, fontWeight: 700, color: c.ink,
                }}>
                  {d || (active
                    ? <span style={{ width: 2, height: 20, background: c.accent }} />
                    : '')}
                </div>
              );
            })}
          </div>
        ) : (
          /* otp: 6 boxes */
          <div style={{ display: 'flex', gap: 9, justifyContent: 'center', marginTop: 34 }}>
            {codeDigits.map((d, i) => {
              const active = i === code.length;
              return (
                <div key={i} style={{
                  width: 42, height: 54, borderRadius: 13, background: c.card,
                  border: `${d || active ? 2 : 1.5}px solid ${d || active ? c.accent : c.line}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: serif, fontSize: 22, fontWeight: 700, color: c.ink,
                }}>
                  {d || (active
                    ? <span style={{ width: 2, height: 22, background: c.accent }} />
                    : '')}
                </div>
              );
            })}
          </div>
        )}

        {/* error */}
        {error && (
          <div style={{ textAlign: 'center', marginTop: 14, fontSize: 12, color: '#c0392b',
            fontWeight: 600, lineHeight: 1.4, padding: '0 8px' }}>
            {error}
          </div>
        )}

        {/* resend / back hint */}
        <div style={{ textAlign: 'center', marginTop: 16, fontSize: 12, color: c.muted }}>
          {isPhone ? (
            <span style={{ color: c.muted }}>Raqam: +998 {phoneFmt}</span>
          ) : (
            <>Kod kelmadimi?{' '}
              <span onClick={() => { setStep('phone'); setCode(''); setError(null); }}
                style={{ color: c.accent, fontWeight: 700, cursor: 'pointer' }}>
                Qayta yuborish
              </span>
            </>
          )}
        </div>

        {/* confirm button */}
        <button
          onClick={confirm}
          disabled={!canConfirm}
          style={{
            marginTop: 20, height: 52, border: 'none', borderRadius: 15,
            background: canConfirm ? c.accent : '#e5d8cc',
            color: canConfirm ? '#fff' : '#b5a08a',
            fontSize: 14, fontWeight: 700, cursor: canConfirm ? 'pointer' : 'default',
            boxShadow: canConfirm ? '0 10px 20px rgba(194,97,59,.3)' : 'none',
            transition: 'background .15s, box-shadow .15s',
          }}
        >
          {loading
            ? 'Yuklanmoqda…'
            : isPhone ? 'Kodni yuborish' : 'Tasdiqlash'}
        </button>

        <div style={{ flex: 1 }} />

        {/* numpad */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 11 }}>
          {['1','2','3','4','5','6','7','8','9','','0','del'].map((k, i) => {
            if (k === '') return <div key={i} style={{ height: 46 }} />;
            if (k === 'del') return (
              <button key={i} onClick={() => isPhone ? tapPhone('del') : tapOtp('del')}
                style={{ height: 46, borderRadius: 12, background: 'transparent', border: 'none',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  color: c.muted, cursor: 'pointer' }}>
                {DEL_ICON}
              </button>
            );
            return (
              <button key={i} onClick={() => isPhone ? tapPhone(k) : tapOtp(k)}
                style={{ height: 46, borderRadius: 12, background: c.card,
                  border: `1px solid ${c.line}`, fontFamily: serif, fontSize: 21,
                  fontWeight: 600, color: c.ink, cursor: 'pointer' }}>
                {k}
              </button>
            );
          })}
        </div>
      </div>
    </>
  );
};
