
import { StrictMode, useEffect, useMemo, useState, type Dispatch, type SetStateAction } from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Navigate, Route, Routes, useNavigate } from 'react-router-dom';
import './index.css';

type Lang = 'ar' | 'fr' | 'en';
type Role = 'elder' | 'family' | 'caregiver' | 'admin';
type Med = { id: string; name: string; dose: string; time: string; remaining: number };
type AppState = {
  role: Role | null;
  phone: string;
  familyPhone: string;
  elderName: string;
  elderAge: string;
  consent: boolean;
  language: Lang;
  fontScale: number;
  privacyMode: boolean;
  emergencyOrder: string[];
  taken: string[];
};

const ORDER_KEYS = ['first', 'second', 'neighbor'];

const defaultState: AppState = {
  role: null,
  phone: '',
  familyPhone: '',
  elderName: '',
  elderAge: '',
  consent: false,
  language: 'ar',
  fontScale: 1,
  privacyMode: false,
  emergencyOrder: ORDER_KEYS,
  taken: [],
};

const ar = {
  appName: 'سَنَد',
  splashTitle: 'بقاء مستقل، طمأنينة للعائلة',
  roleTitle: 'اختر دورك',
  elder: 'المسن',
  family: 'فرد العائلة',
  caregiver: 'مقدم رعاية',
  admin: 'مشرف',
  phoneTitle: 'تسجيل بالهاتف',
  phoneHint: 'أدخل رقم الهاتف',
  invalidPhone: 'أدخل 9 أرقام بعد +213',
  continue: 'متابعة',
  otpNote: 'رمز التأكيد (OTP) سيُضاف لاحقاً',
  elderCreateTitle: 'ملف المسن',
  elderName: 'اسم المسن',
  elderAge: 'العمر',
  create: 'إنشاء الملف',
  inviteNote: 'دعوة المسن برابط ستُضاف لاحقاً. موافقته على التتبع تتم من جهازه.',
  consentTitle: 'موافقة على التتبع',
  consentText: 'لا يُفعّل أي تتبع إلا بعد موافقة صريحة. يمكنك إيقاف التتبع في أي وقت.',
  accept: 'أوافق',
  decline: 'لا أوافق',
  welcome: 'مرحباً',
  sos: 'استغاثة',
  quickCall: 'اتصال سريع',
  medications: 'أدويتي',
  chat: 'تحدث مع سَنَد',
  settings: 'الإعدادات',
  familyDashboard: 'لوحة العائلة',
  medicationTitle: 'أدويتي',
  medicineTaken: 'أخذت الدواء',
  tookIt: 'تم التسجيل ✔',
  lowStock: 'المخزون قليل',
  remaining: 'المتبقي',
  medNote: 'التذكير التلقائي يحتاج الخادم وسيُضاف لاحقاً.',
  aiChat: 'مساعد نصي',
  aiPlaceholder: 'اكتب سؤالاً موجزاً',
  send: 'إرسال',
  notDiagnose: 'لا أُشخّص، ولا أغيّر جرعة.',
  chatDefault: 'أستطيع ذكر جرعات اليوم، أو شرح الاستعمال، أو كلمات طمأنة.',
  chatUrgent: 'إن كان طارئاً، اضغط الاستغاثة أو اتصل بـ 14 الآن. لا أُشخّص الأعراض.',
  chatDoses: 'جرعات اليوم:',
  chatDhikr: 'اللهم احفظك وأتمّ عليك الصحة والعافية.',
  chatHelp: 'من الرئيسية اضغط الاستغاثة، أو الأدوية، أو اتصال سريع، أو تحدث مع سَنَد.',
  language: 'اللغة',
  fontSize: 'حجم الخط',
  privacy: 'وضع الخصوصية',
  familyPhone: 'رقم أول فرد من العائلة',
  emergencyOrder: 'ترتيب جهات الطوارئ',
  first: 'الابن الأول',
  second: 'الابن الثاني',
  neighbor: 'الجار الموثوق',
  up: 'أعلى',
  down: 'أسفل',
  noFamilyPhone: 'أضف رقم العائلة أولاً من الإعدادات',
  sosHeadline: 'لا تقلق، ابقَ هادئاً',
  sosCountdown: 'يمكنك الإلغاء خلال',
  sosOpenSms: 'افتح رسالة التنبيه للعائلة',
  sosCall14: 'اتصال مباشر بـ 14',
  sosHonest: 'اضغط «إرسال» داخل تطبيق الرسائل. الإرسال التلقائي يحتاج الخادم وسيُضاف لاحقاً.',
  sosSmsBody: 'استغاثة من سَنَد. أحتاج مساعدة. موقعي:',
  cancel: 'إلغاء',
  demo: 'بيانات تجريبية',
  familyStatus: 'حالة المسن',
  stable: 'مستقر',
  lastActivity: 'آخر نشاط',
  minutesAgo: 'قبل 10 دقائق',
  battery: 'بطارية الهاتف',
  manualVitals: 'مؤشرات بإدخال يدوي',
  bp: 'الضغط',
  sugar: 'السكر',
  pulse: 'النبض',
  drugCompliance: 'التزام الأدوية',
};
type Key = keyof typeof ar;
type Dict = Record<Key, string>;

const fr: Dict = {
  appName: 'Sanad',
  splashTitle: 'Vie autonome, sérénité pour la famille',
  roleTitle: 'Choisissez votre rôle',
  elder: 'Personne âgée',
  family: 'Membre de la famille',
  caregiver: 'Aidant',
  admin: 'Modérateur',
  phoneTitle: 'Connexion par téléphone',
  phoneHint: 'Entrez le numéro',
  invalidPhone: 'Entrez 9 chiffres après +213',
  continue: 'Continuer',
  otpNote: 'Le code de vérification (OTP) sera ajouté plus tard',
  elderCreateTitle: 'Profil de la personne âgée',
  elderName: 'Nom',
  elderAge: 'Âge',
  create: 'Créer le profil',
  inviteNote: 'L’invitation par lien sera ajoutée plus tard. Le consentement se fait sur son appareil.',
  consentTitle: 'Consentement au suivi',
  consentText: 'Aucun suivi sans accord explicite. Vous pouvez l’arrêter à tout moment.',
  accept: 'J’accepte',
  decline: 'Je refuse',
  welcome: 'Bienvenue',
  sos: 'SOS',
  quickCall: 'Appel rapide',
  medications: 'Mes médicaments',
  chat: 'Parler à Sanad',
  settings: 'Paramètres',
  familyDashboard: 'Tableau de bord',
  medicationTitle: 'Mes médicaments',
  medicineTaken: 'J’ai pris le médicament',
  tookIt: 'Enregistré ✔',
  lowStock: 'Stock faible',
  remaining: 'Restant',
  medNote: 'Le rappel automatique nécessite le serveur (à venir).',
  aiChat: 'Assistant textuel',
  aiPlaceholder: 'Écrivez une question courte',
  send: 'Envoyer',
  notDiagnose: 'Je ne diagnostique pas et je ne modifie pas les doses.',
  chatDefault: 'Je peux citer les doses du jour, expliquer l’appli ou rassurer.',
  chatUrgent: 'En cas d’urgence, appuyez sur SOS ou appelez le 14 maintenant. Je ne diagnostique pas.',
  chatDoses: 'Doses du jour :',
  chatDhikr: 'Que Dieu vous protège et vous accorde santé et bien-être.',
  chatHelp: 'Sur l’accueil : SOS, médicaments, appel rapide ou parler à Sanad.',
  language: 'Langue',
  fontSize: 'Taille du texte',
  privacy: 'Mode confidentialité',
  familyPhone: 'Numéro du premier proche',
  emergencyOrder: 'Ordre des urgences',
  first: 'Premier enfant',
  second: 'Deuxième enfant',
  neighbor: 'Voisin de confiance',
  up: 'Haut',
  down: 'Bas',
  noFamilyPhone: 'Ajoutez d’abord le numéro dans les paramètres',
  sosHeadline: 'Pas d’inquiétude, restez calme',
  sosCountdown: 'Vous pouvez annuler dans',
  sosOpenSms: 'Ouvrir le SMS d’alerte famille',
  sosCall14: 'Appel direct 14',
  sosHonest: 'Appuyez sur « Envoyer » dans l’appli SMS. L’envoi automatique nécessite le serveur (à venir).',
  sosSmsBody: 'SOS de Sanad. J’ai besoin d’aide. Ma position :',
  cancel: 'Annuler',
  demo: 'Données de démonstration',
  familyStatus: 'État du bénéficiaire',
  stable: 'Stable',
  lastActivity: 'Dernière activité',
  minutesAgo: 'il y a 10 minutes',
  battery: 'Batterie',
  manualVitals: 'Indicateurs saisis à la main',
  bp: 'Tension',
  sugar: 'Glycémie',
  pulse: 'Pouls',
  drugCompliance: 'Respect des doses',
};

const en: Dict = {
  appName: 'Sanad',
  splashTitle: 'Independent living, peace for the family',
  roleTitle: 'Select your role',
  elder: 'Elder',
  family: 'Family member',
  caregiver: 'Caregiver',
  admin: 'Admin',
  phoneTitle: 'Phone registration',
  phoneHint: 'Enter phone number',
  invalidPhone: 'Enter 9 digits after +213',
  continue: 'Continue',
  otpNote: 'The verification code (OTP) will be added later',
  elderCreateTitle: 'Elder profile',
  elderName: 'Elder name',
  elderAge: 'Age',
  create: 'Create profile',
  inviteNote: 'Invite by link will be added later. Consent happens on the elder’s device.',
  consentTitle: 'Tracking consent',
  consentText: 'Tracking is activated only after explicit consent. You may stop it at any time.',
  accept: 'I accept',
  decline: 'I decline',
  welcome: 'Welcome',
  sos: 'SOS',
  quickCall: 'Quick call',
  medications: 'My medicines',
  chat: 'Talk to Sanad',
  settings: 'Settings',
  familyDashboard: 'Family dashboard',
  medicationTitle: 'My medicines',
  medicineTaken: 'I took it',
  tookIt: 'Recorded ✔',
  lowStock: 'Low stock',
  remaining: 'Left',
  medNote: 'Automatic reminders need the server (coming later).',
  aiChat: 'Text assistant',
  aiPlaceholder: 'Type a short question',
  send: 'Send',
  notDiagnose: 'I do not diagnose or change doses.',
  chatDefault: 'I can list today’s doses, explain the app, or offer kind words.',
  chatUrgent: 'If this is an emergency, press SOS or call 14 now. I do not diagnose symptoms.',
  chatDoses: 'Today’s doses:',
  chatDhikr: 'May God keep you safe and grant you health and well-being.',
  chatHelp: 'On the home screen press SOS, medicines, quick call, or talk to Sanad.',
  language: 'Language',
  fontSize: 'Font size',
  privacy: 'Privacy mode',
  familyPhone: 'First family member’s number',
  emergencyOrder: 'Emergency order',
  first: 'First child',
  second: 'Second child',
  neighbor: 'Trusted neighbor',
  up: 'Up',
  down: 'Down',
  noFamilyPhone: 'Add the family number in Settings first',
  sosHeadline: 'Don’t worry, stay calm',
  sosCountdown: 'You can cancel within',
  sosOpenSms: 'Open the family alert SMS',
  sosCall14: 'Direct call 14',
  sosHonest: 'Press “Send” in your messaging app. Automatic sending needs the server (coming later).',
  sosSmsBody: 'SOS from Sanad. I need help. My location:',
  cancel: 'Cancel',
  demo: 'Demo data',
  familyStatus: 'Elder status',
  stable: 'Stable',
  lastActivity: 'Last activity',
  minutesAgo: '10 minutes ago',
  battery: 'Phone battery',
  manualVitals: 'Manually entered indicators',
  bp: 'Blood pressure',
  sugar: 'Sugar',
  pulse: 'Pulse',
  drugCompliance: 'Medication compliance',
};

const translations: Record<Lang, Dict> = { ar, fr, en };
type TFn = (k: Key) => string;
type P = { t: TFn; state: AppState; setState: Dispatch<SetStateAction<AppState>> };

const medList: Med[] = [
  { id: '1', name: 'دواء الضغط', dose: '1', time: '08:00', remaining: 7 },
  { id: '2', name: 'دواء السكر', dose: '1', time: '13:00', remaining: 2 },
  { id: '3', name: 'فيتامين', dose: '1', time: '20:00', remaining: 12 },
];

const vitals = { bp: '12/8', sugar: '1.2 g/l', pulse: '72' };

// يحوّل رقماً محلياً أو دولياً إلى صيغة +213...
function toIntl(p: string) {
  const d = p.replace(/\D/g, '');
  if (!d) return '';
  if (d.startsWith('00')) return '+' + d.slice(2);
  if (d.startsWith('0')) return '+213' + d.slice(1);
  if (d.length === 9) return '+213' + d;
  return '+' + d;
}

const inputCls =
  'w-full rounded-xl border-2 border-[#0F5560] bg-white px-4 py-3 text-xl outline-none focus:ring-4 focus:ring-[#F2A541]';
const cardCls = 'rounded-2xl bg-white p-5 shadow-md';
const pageCls = 'mx-auto min-h-screen max-w-md p-5';

function Button({
  onClick,
  label,
  variant = 'primary',
}: {
  onClick?: () => void;
  label: string;
  variant?: 'primary' | 'danger' | 'secondary';
}) {
  const v =
    variant === 'danger'
      ? 'bg-[#C8102E] text-white'
      : variant === 'secondary'
        ? 'bg-white text-[#0F5560] border-2 border-[#0F5560]'
        : 'bg-[#0F5560] text-white';
  return (
    <button
      type="button"
      onClick={onClick}
      className={`min-h-[64px] w-full rounded-2xl px-5 py-3 text-xl font-bold shadow-md ${v}`}
    >
      {label}
    </button>
  );
}

function LinkButton({ href, label, variant = 'secondary' }: { href: string; label: string; variant?: 'primary' | 'secondary' }) {
  const v = variant === 'primary' ? 'bg-white text-[#C8102E]' : 'border-2 border-white text-white';
  return (
    <a href={href} className={`flex min-h-[64px] w-full items-center justify-center rounded-2xl px-5 py-3 text-center text-xl font-bold ${v}`}>
      {label}
    </a>
  );
}

function load(): AppState {
  try {
    const raw = localStorage.getItem('sanad_state');
    if (!raw) return defaultState;
    const m = { ...defaultState, ...JSON.parse(raw) } as AppState;
    if (!Array.isArray(m.emergencyOrder) || m.emergencyOrder.length !== 3 || !ORDER_KEYS.every((k) => m.emergencyOrder.includes(k))) {
      m.emergencyOrder = ORDER_KEYS;
    }
    if (!Array.isArray(m.taken)) m.taken = [];
    return m;
  } catch {
    return defaultState;
  }
}

function App() {
  const [state, setState] = useState<AppState>(load);

  useEffect(() => {
    try {
      localStorage.setItem('sanad_state', JSON.stringify(state));
    } catch {
      /* التخزين غير متاح */
    }
  }, [state]);

  useEffect(() => {
    document.documentElement.lang = state.language;
    document.documentElement.dir = state.language === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.style.fontSize = `${16 * state.fontScale}px`;
  }, [state.language, state.fontScale]);

  const t = useMemo<TFn>(() => (k) => translations[state.language][k], [state.language]);
  const p: P = { t, state, setState };

  return (
    <div className="min-h-screen bg-[#D3EAE6] text-[#0B2530]">
      <Routes>
        <Route path="/" element={<Navigate to="/splash" replace />} />
        <Route path="/splash" element={<Splash {...p} />} />
        <Route path="/role" element={<RoleScreen {...p} />} />
        <Route path="/phone" element={<PhoneScreen {...p} />} />
        <Route path="/elder/create" element={<ElderCreate {...p} />} />
        <Route path="/consent" element={<Consent {...p} />} />
        <Route path="/elder/home" element={state.consent ? <ElderHome {...p} /> : <Navigate to="/consent" replace />} />
        <Route path="/sos" element={<Sos {...p} />} />
        <Route path="/medications" element={<Meds {...p} />} />
        <Route path="/family" element={<Family {...p} />} />
        <Route path="/chat" element={<Chat {...p} />} />
        <Route path="/settings" element={<Settings {...p} />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </div>
  );
}

function Splash({ t, state }: P) {
  const navigate = useNavigate();
  useEffect(() => {
    const id = setTimeout(() => {
      if (state.role === 'elder' && state.consent) navigate('/elder/home', { replace: true });
      else if (state.role && state.role !== 'elder' && state.elderName) navigate('/family', { replace: true });
      else navigate('/role', { replace: true });
    }, 1000);
    return () => clearTimeout(id);
  }, [navigate, state.role, state.consent, state.elderName]);

  return (
    <div className="flex min-h-screen items-center justify-center bg-white">
      <div className="text-center">
        <div className="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-3xl bg-[#0F5560] shadow-lg">
          <span className="text-5xl text-[#D3EAE6]">❤</span>
        </div>
        <h1 className="text-4xl font-bold text-[#0F5560]">{t('appName')}</h1>
        <p className="mt-3 text-xl">{t('splashTitle')}</p>
      </div>
    </div>
  );
}

function RoleScreen({ t, setState }: P) {
  const navigate = useNavigate();
  const pick = (role: Role) => {
    setState((s) => ({ ...s, role }));
    navigate('/phone');
  };
  return (
    <div className={pageCls + ' flex flex-col justify-center'}>
      <h1 className="mb-8 text-3xl font-bold text-[#0F5560]">{t('roleTitle')}</h1>
      <div className="space-y-4">
        <Button label={t('elder')} onClick={() => pick('elder')} />
        <Button label={t('family')} onClick={() => pick('family')} />
        <Button label={t('caregiver')} onClick={() => pick('caregiver')} variant="secondary" />
        <Button label={t('admin')} onClick={() => pick('admin')} variant="secondary" />
      </div>
    </div>
  );
}

function PhoneScreen({ t, state, setState }: P) {
  const navigate = useNavigate();
  const [error, setError] = useState(false);

  const submit = () => {
    const d = state.phone.replace(/\D/g, '').replace(/^0/, '');
    if (d.length !== 9) {
      setError(true);
      return;
    }
    setError(false);
    setState((s) => ({ ...s, phone: d }));
    if (state.role === 'elder') navigate('/consent');
    else if (state.role === 'family') navigate('/elder/create');
    else navigate('/family');
  };

  return (
    <div className={pageCls + ' flex flex-col justify-center'}>
      <h1 className="text-3xl font-bold text-[#0F5560]">{t('phoneTitle')}</h1>
      <div className={cardCls + ' mt-8'}>
        <label htmlFor="phone" className="mb-2 block text-lg font-semibold">{t('phoneHint')}</label>
        <div className="flex items-center gap-3" dir="ltr">
          <span className="rounded-xl bg-[#D3EAE6] px-4 py-3 text-xl">+213</span>
          <input
            id="phone"
            value={state.phone}
            onChange={(e) => setState((s) => ({ ...s, phone: e.target.value }))}
            className={inputCls}
            placeholder="555123456"
            inputMode="numeric"
            autoComplete="tel-national"
          />
        </div>
        {error && <p role="alert" className="mt-3 text-lg font-bold text-[#C8102E]">{t('invalidPhone')}</p>}
      </div>
      <div className="mt-6"><Button label={t('continue')} onClick={submit} /></div>
      <p className="mt-4 text-center text-lg">{t('otpNote')}</p>
    </div>
  );
}

function ElderCreate({ t, state, setState }: P) {
  const navigate = useNavigate();
  const next = () => {
    if (!state.elderName.trim()) return;
    navigate('/family');
  };
  return (
    <div className={pageCls + ' flex flex-col justify-center'}>
      <h1 className="text-3xl font-bold text-[#0F5560]">{t('elderCreateTitle')}</h1>
      <div className="mt-8 space-y-4">
        <input value={state.elderName} onChange={(e) => setState((s) => ({ ...s, elderName: e.target.value }))} className={inputCls} placeholder={t('elderName')} aria-label={t('elderName')} />
        <input value={state.elderAge} onChange={(e) => setState((s) => ({ ...s, elderAge: e.target.value.replace(/\D/g, '') }))} className={inputCls} placeholder={t('elderAge')} aria-label={t('elderAge')} inputMode="numeric" />
      </div>
      <p className="mt-4 text-lg">{t('inviteNote')}</p>
      <div className="mt-6"><Button label={t('create')} onClick={next} /></div>
    </div>
  );
}

function Consent({ t, setState }: P) {
  const navigate = useNavigate();
  const accept = () => {
    setState((s) => ({ ...s, consent: true }));
    navigate('/elder/home');
  };
  const decline = () => {
    setState((s) => ({ ...s, consent: false }));
    navigate('/role');
  };
  return (
    <div className={pageCls + ' flex flex-col justify-center'}>
      <h1 className="text-3xl font-bold text-[#0F5560]">{t('consentTitle')}</h1>
      <div className={cardCls + ' mt-8'}><p className="text-xl leading-8">{t('consentText')}</p></div>
      <div className="mt-8 space-y-3">
        <Button label={t('accept')} onClick={accept} />
        <Button label={t('decline')} onClick={decline} variant="secondary" />
      </div>
    </div>
  );
}

function ElderHome({ t, state }: P) {
  const navigate = useNavigate();
  const tile = 'flex min-h-[144px] flex-col justify-between rounded-2xl border border-[#D3EAE6] bg-white p-5 text-start shadow-md';

  const quickCall = () => {
    if (!state.familyPhone) {
      alert(t('noFamilyPhone'));
      navigate('/settings');
      return;
    }
    window.location.href = `tel:${toIntl(state.familyPhone)}`;
  };

  return (
    <div className={pageCls}>
      <header className="mb-5">
        <p className="text-lg">{t('welcome')}</p>
        <h1 className="text-3xl font-bold text-[#0F5560]">{state.elderName || t('elder')}</h1>
      </header>
      <div className="space-y-4">
        <button type="button" className="min-h-[96px] w-full rounded-3xl bg-[#C8102E] p-6 text-center text-3xl font-black text-white shadow-lg" onClick={() => navigate('/sos')}>
          🆘 {t('sos')}
        </button>
        <div className="grid grid-cols-2 gap-4">
          <button type="button" className={tile} onClick={quickCall}>
            <span className="text-2xl font-bold">{t('quickCall')}</span><span className="text-4xl">📞</span>
          </button>
          <button type="button" className={tile} onClick={() => navigate('/medications')}>
            <span className="text-2xl font-bold">{t('medications')}</span><span className="text-4xl">💊</span>
          </button>
          <button type="button" className={tile + ' col-span-2'} onClick={() => navigate('/chat')}>
            <span className="text-2xl font-bold">{t('chat')}</span><span className="text-4xl">🗣️</span>
          </button>
        </div>
        <div className="flex gap-3">
          <button type="button" className="min-h-[56px] flex-1 rounded-xl bg-[#0F5560] px-4 py-3 text-lg text-white" onClick={() => navigate('/settings')}>{t('settings')}</button>
          <button type="button" className="min-h-[56px] flex-1 rounded-xl border-2 border-[#0F5560] bg-white px-4 py-3 text-lg text-[#0F5560]" onClick={() => navigate('/family')}>{t('familyDashboard')}</button>
        </div>
      </div>
    </div>
  );
}

function Sos({ t, state }: P) {
  const navigate = useNavigate();
  const [left, setLeft] = useState(5);
  const [map, setMap] = useState('');

  useEffect(() => {
    if (left <= 0) return;
    const id = setTimeout(() => setLeft((l) => l - 1), 1000);
    return () => clearTimeout(id);
  }, [left]);

  useEffect(() => {
    if (!('geolocation' in navigator)) return;
    navigator.geolocation.getCurrentPosition(
      (pos) => setMap(`https://maps.google.com/?q=${pos.coords.latitude},${pos.coords.longitude}`),
      () => setMap(''),
      { enableHighAccuracy: true, timeout: 8000 },
    );
  }, []);

  const to = toIntl(state.familyPhone);
  const body = encodeURIComponent(`${t('sosSmsBody')} ${map}`.trim());
  const smsHref = `sms:${to}?body=${body}`;

  return (
    <div className="flex min-h-screen flex-col bg-[#C8102E] p-5 text-white">
      <p className="mt-4 text-center text-3xl font-bold">{t('sosHeadline')}</p>
      <div className="flex flex-1 flex-col items-center justify-center">
        {left > 0 ? (
          <>
            <p className="text-xl">{t('sosCountdown')}</p>
            <div className="my-4 rounded-full bg-white/15 px-8 py-4 text-6xl font-black" aria-live="polite">{left}</div>
          </>
        ) : (
          <p className="mb-4 text-center text-xl">{t('sosHonest')}</p>
        )}
        <div className="mt-4 w-full space-y-4">
          {left <= 0 && (to ? <LinkButton href={smsHref} label={t('sosOpenSms')} variant="primary" /> : <Button label={t('noFamilyPhone')} onClick={() => navigate('/settings')} variant="secondary" />)}
          <LinkButton href="tel:14" label={t('sosCall14')} />
          <button type="button" className="min-h-[64px] w-full rounded-2xl bg-[#F2A541] px-5 py-3 text-xl font-bold text-[#0B2530]" onClick={() => navigate('/elder/home')}>
            {t('cancel')}
          </button>
        </div>
      </div>
    </div>
  );
}

function Meds({ t, state, setState }: P) {
  const toggle = (id: string) =>
    setState((s) => ({ ...s, taken: s.taken.includes(id) ? s.taken.filter((x) => x !== id) : [...s.taken, id] }));
  return (
    <div className={pageCls}>
      <h1 className="text-3xl font-bold text-[#0F5560]">{t('medicationTitle')}</h1>
      <div className="mt-5 space-y-4">
        {medList.map((m) => {
          const done = state.taken.includes(m.id);
          return (
            <div key={m.id} className={cardCls}>
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-2xl font-bold">{m.name}</h2>
                  <p className="text-lg">{t('remaining')}: {m.remaining}{m.remaining <= 3 && <span className="ms-2 font-bold text-[#C8102E]">⚠ {t('lowStock')}</span>}</p>
                </div>
                <span className="rounded-full bg-[#D3EAE6] px-3 py-1 text-base">{m.time}</span>
              </div>
              <div className="mt-4">
                <Button label={done ? t('tookIt') : t('medicineTaken')} onClick={() => toggle(m.id)} variant={done ? 'secondary' : 'primary'} />
              </div>
            </div>
          );
        })}
      </div>
      <p className="mt-4 text-base">{t('medNote')}</p>
    </div>
  );
}

function Family({ t, state }: P) {
  const pct = Math.round((state.taken.length / medList.length) * 100);
  return (
    <div className={pageCls}>
      <h1 className="text-3xl font-bold text-[#0F5560]">{t('familyDashboard')}</h1>
      <p className="mt-2 inline-block rounded-full bg-[#F2A541] px-3 py-1 text-base font-bold">{t('demo')}</p>
      <div className="mt-4 space-y-4">
        <div className={cardCls}>
          <p className="text-lg">{state.elderName || t('elder')}</p>
          <p className="text-lg">{t('familyStatus')}: <span className="font-bold text-[#2E9E5B]">{t('stable')}</span></p>
          <p className="mt-2">{t('lastActivity')}: {t('minutesAgo')}</p>
          <p>{t('battery')}: 82%</p>
        </div>
        <div className={cardCls}>
          <p className="text-xl font-bold">{t('manualVitals')}</p>
          <ul className="mt-3 space-y-2 text-lg">
            <li>{t('bp')}: {vitals.bp}</li>
            <li>{t('sugar')}: {vitals.sugar}</li>
            <li>{t('pulse')}: {vitals.pulse}</li>
          </ul>
        </div>
        <div className={cardCls}>
          <p className="text-xl font-bold">{t('drugCompliance')}</p>
          <div className="mt-3 h-3 overflow-hidden rounded-full bg-[#C5D9D5]"><div className="h-full bg-[#2E9E5B]" style={{ width: `${pct}%` }} /></div>
          <p className="mt-2 text-lg">{pct}%</p>
        </div>
      </div>
    </div>
  );
}

const URGENT = /استغاث|طارئ|ألم|ضيق|سقط|وقع|نزيف|صدر|تنفس|دوخ|douleur|urgence|aide|chute|poitrine|pain|help|emergency|fall|chest/i;
const MED = /دواء|جرعة|أدوي|حبة|médicament|dose|medic|pill/i;
const DHIKR = /أذكار|ذكر|دعاء|prière|dhikr|prayer/i;
const HOWTO = /كيف|طريقة|استعمال|تطبيق|comment|utilis|how/i;

function Chat({ t }: P) {
  const [input, setInput] = useState('');
  const [reply, setReply] = useState(t('chatDefault'));
  const [urgent, setUrgent] = useState(false);
  const navigate = useNavigate();

  const ask = () => {
    const v = input.trim();
    if (!v) return;
    setUrgent(false);
    // الطوارئ أولاً دائماً، قبل أي موضوع آخر
    if (URGENT.test(v)) {
      setUrgent(true);
      setReply(t('chatUrgent'));
    } else if (MED.test(v)) setReply(`${t('chatDoses')} ${medList.map((m) => `${m.time} ${m.name}`).join(' · ')}`);
    else if (DHIKR.test(v)) setReply(t('chatDhikr'));
    else if (HOWTO.test(v)) setReply(t('chatHelp'));
    else setReply(t('chatDefault'));
    setInput('');
  };

  return (
    <div className={pageCls}>
      <h1 className="text-3xl font-bold text-[#0F5560]">{t('aiChat')}</h1>
      <div className={cardCls + ' mt-5'} aria-live="polite"><p className="text-lg leading-8">{reply}</p></div>
      {urgent && (
        <div className="mt-4 space-y-3">
          <Button label={`🆘 ${t('sos')}`} onClick={() => navigate('/sos')} variant="danger" />
          <a href="tel:14" className="flex min-h-[64px] items-center justify-center rounded-2xl bg-[#0B2530] text-xl font-bold text-white">{t('sosCall14')}</a>
        </div>
      )}
      <textarea value={input} onChange={(e) => setInput(e.target.value)} placeholder={t('aiPlaceholder')} aria-label={t('aiPlaceholder')} className={inputCls + ' mt-5 min-h-[96px]'} />
      <div className="mt-4"><Button label={t('send')} onClick={ask} /></div>
      <p className="mt-4 text-base">{t('notDiagnose')}</p>
    </div>
  );
}

function Settings({ t, state, setState }: P) {
  const move = (i: number, d: number) =>
    setState((s) => {
      const a = [...s.emergencyOrder];
      const j = i + d;
      if (j < 0 || j >= a.length) return s;
      [a[i], a[j]] = [a[j], a[i]];
      return { ...s, emergencyOrder: a };
    });

  return (
    <div className={pageCls}>
      <h1 className="text-3xl font-bold text-[#0F5560]">{t('settings')}</h1>
      <div className="mt-5 space-y-4">
        <div className={cardCls}>
          <p className="mb-3 font-bold">{t('language')}</p>
          <div className="flex gap-2">
            {(['ar', 'fr', 'en'] as Lang[]).map((l) => (
              <button key={l} type="button" className={`min-h-[56px] flex-1 rounded-xl px-3 py-2 text-lg ${state.language === l ? 'bg-[#0F5560] text-white' : 'bg-[#D3EAE6] text-[#0F5560]'}`} onClick={() => setState((s) => ({ ...s, language: l }))}>
                {l.toUpperCase()}
              </button>
            ))}
          </div>
        </div>
        <div className={cardCls}>
          <label htmlFor="fs" className="mb-3 block font-bold">{t('fontSize')}</label>
          <input id="fs" type="range" min={0.9} max={1.4} step={0.1} value={state.fontScale} onChange={(e) => setState((s) => ({ ...s, fontScale: Number(e.target.value) }))} className="w-full" />
        </div>
        <div className={cardCls}>
          <label htmlFor="fp" className="mb-2 block font-bold">{t('familyPhone')}</label>
          <input id="fp" dir="ltr" value={state.familyPhone} onChange={(e) => setState((s) => ({ ...s, familyPhone: e.target.value }))} className={inputCls} placeholder="0555 12 34 56" inputMode="tel" />
        </div>
        <div className={cardCls}>
          <label className="flex items-center justify-between font-bold">
            <span>{t('privacy')}</span>
            <input type="checkbox" className="h-6 w-6" checked={state.privacyMode} onChange={(e) => setState((s) => ({ ...s, privacyMode: e.target.checked }))} />
          </label>
        </div>
        <div className={cardCls}>
          <p className="font-bold">{t('emergencyOrder')}</p>
          <div className="mt-3 space-y-2">
            {state.emergencyOrder.map((k, i) => (
              <div key={k} className="flex items-center justify-between rounded-xl bg-[#D3EAE6] px-3 py-2">
                <span>{i + 1}. {t(k as Key)}</span>
                <span className="flex gap-2">
                  <button type="button" aria-label={t('up')} className="min-h-[44px] min-w-[44px] rounded-lg bg-white" onClick={() => move(i, -1)}>▲</button>
                  <button type="button" aria-label={t('down')} className="min-h-[44px] min-w-[44px] rounded-lg bg-white" onClick={() => move(i, 1)}>▼</button>
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </StrictMode>,
);